import os
from pathlib import Path
import subprocess
import argparse
from struct import unpack


def is_stm(instr):
    return (
        (instr >> 25) & 0b111 == 0b100 and (instr >> 22) & 0b1 == 0b0 and (instr >> 20) & 0b1 == 0b0
    )


def is_ldm(instr):
    return (
        (instr >> 25) & 0b111 == 0b100 and (instr >> 22) & 0b1 == 0b0 and (instr >> 20) & 0b1 == 0b1
    )


def is_branch(instr):
    if (instr >> 24) & 0b1111 == 0b1010:  # B
        return True
    elif (instr >> 24) & 0b1111 == 0b1011:  # BL
        return True
    elif (instr >> 25) & 0b1111111 == 0b1111101:  # BLX(1)
        return True

    return False


def push_to_strs(instr):
    # use only push(stm) instructions.
    result = []
    reg_list = get_register_list(instr)
    n_regs = sum(reg_list)

    # sub instruction
    bin_rep = f"1110_00_100100_1101_1101_0000_{bin(4 * n_regs)[2:].zfill(8)}"
    instr = int(bin_rep.replace("_", ""), 2)
    result.append(instr)

    # str instructions
    for i, rd in enumerate(reg_list[::-1], start=1):
        bin_rep = (
            f"1110_10_011000_1101_{bin(rd)[2:].zfill(4)}_{bin(4 * (n_regs - i))[2:].zfill(12)}"
        )
        instr = int(bin_rep.replace("_", ""), 2)
        result.append(instr)

    return result


def pop_to_ldrs(instr):
    # use only pop(ldm) instructions.
    result = []
    reg_list = get_register_list(instr)
    n_regs = sum(reg_list)

    # str instructions
    for i, rd in enumerate(reg_list, start=0):
        bin_rep = f"1110_10_011001_1101_{bin(rd)[2:].zfill(4)}_{bin(4 * i)[2:].zfill(12)}"
        instr = int(bin_rep.replace("_", ""), 2)
        result.append(instr)

    # add instruction
    bin_rep = f"1110_00_101000_1101_1101_0000_{bin(4 * n_regs)[2:].zfill(8)}"
    instr = int(bin_rep.replace("_", ""), 2)
    result.append(instr)

    return result


def to_hex_string(instr):
    return hex(instr)[2:].zfill(8)


def offset_branch_label(branch_instr, offset):
    # オーバーフローする可能性がある
    offset_imm24 = branch_instr & 0xFFFFFF + offset
    bin_rep = f"{bin(branch_instr)[:8].zfill(8)}_{bin(offset_imm24)[2:].zfill(24)}"
    return int(bin_rep.replace("_", ""), 2)


def get_register_list(instr):
    # use only push(stm) or pop(ldm) instructions.
    return [i for i in range(16) if (instr >> i) & 0b1 == 1]


def binary_to_text(from_file, to_file):
    with open(from_file, "rb") as f:
        tmp = f.read()

    data = unpack("<" + "I" * (len(tmp) // 4), tmp)
    addr_offset = 0
    with open(to_file, "w") as f:
        for instr in data:
            # push, pop命令は非対応なので、それぞれsub, addでspだけ移動する命令に置き換える
            # 複数回のstr, ldrに置き換えできるが命令回数が変わるのでコンパイラが出力したアドレスと対応が取れなくなる
            # レジスタの退避と復帰ができなくなるのでサブルーチンが使えなくなる
            if is_stm(instr):  # push命令を複数のstrに置き換えてアドレスのオフセット値を追加する
                print("Replaced push(stm) with sub and strs.")
                instr_list = push_to_strs(instr)

                for instr in instr_list:
                    f.write(f"{to_hex_string(instr)}\n")
                addr_offset += sum(instr_list) - 1
            elif is_ldm(instr):  # pop命令を複数のldrに置き換えてアドレスのオフセット値を追加する
                print("Replaced pop(ldm) with add.")
                instr_list = pop_to_ldrs(instr)

                for instr in instr_list:
                    f.write(f"{to_hex_string(instr)}\n")
                addr_offset += sum(instr_list) - 1
            elif is_branch(instr):  # branch命令にオフセットを追加する
                print("Added an offset to the branch.")
                instr = offset_branch_label(instr, addr_offset)
                f.write(f"{to_hex_string(instr)}\n")
            else:
                f.write(f"{to_hex_string(instr)}\n")


def main(args):
    filepath = Path(args.filepath)

    # clangでデバッグ情報を埋め込んでオブジェクトファイルを作成する
    cmd_clang = f"clang -O0 -target armv5 -mfloat-abi=soft -g -c {filepath}"
    # cmd_gcc = f"arm-none-eabi-gcc -O0 --specs=nosys.specs -march=armv5t -mfloat-abi=soft -g -c {filepath}"
    subprocess.run(cmd_clang.split(" "))

    try:
        if args.debug:
            # オブジェクトファイルを逆アセンブルする
            cmd = f"llvm-objdump -S {filepath.stem}.o"
            subprocess.run(cmd.split(" "))
        else:
            # オブジェクトファイルから命令部だけをテキストとして取り出す
            cmd = f"llvm-objcopy {filepath.stem}.o -O binary program.bin"
            subprocess.run(cmd.split(" "))

            binary_to_text("program.bin", "program.dat")

            print("output program.dat")
    except Exception:
        print("process failed.")
    finally:
        if os.path.exists("program.bin"):
            os.remove("program.bin")
        if os.path.exists(f"{filepath.stem}.o"):
            os.remove(f"{filepath.stem}.o")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Compile C-source with clang")
    parser.add_argument("filepath", help="C-source filepath")
    parser.add_argument("-d", "--debug", action="store_true")

    args = parser.parse_args()

    main(args)
