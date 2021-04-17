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


def bit_count_low16(x):
    return sum([(x >> i) & 0b1 for i in range(16)])


def sp_sub_str(n):
    bin_rep = f"1110_00_100100_1101_1101_0000_{bin(4 * n)[2:].zfill(8)}"
    return hex(int(bin_rep.replace("_", ""), 2))[2:]


def sp_add_str(n):
    bin_rep = f"1110_00_101000_1101_1101_0000_{bin(4 * n)[2:].zfill(8)}"
    return hex(int(bin_rep.replace("_", ""), 2))[2:]


def bin_to_text(from_file, to_file):
    with open(from_file, "rb") as f:
        tmp = f.read()

    data = unpack("<" + "I" * (len(tmp) // 4), tmp)
    with open(to_file, "w") as f:
        for instr in data:
            # push, pop命令は非対応なので、それぞれsub, addでspだけ移動する命令に置き換える
            # 複数回のstr, ldrに置き換えできるが命令回数が変わるのでコンパイラが出力したアドレスと対応が取れなくなる
            # レジスタの退避と復帰ができなくなるのでサブルーチンが使えなくなる
            if is_stm(instr):
                print("Replaced push(stm) with sub.")
                f.write(f"{sp_sub_str(bit_count_low16(instr))}\n")
            elif is_ldm(instr):
                print("Replaced pop(ldm) with add.")
                f.write(f"{sp_add_str(bit_count_low16(instr))}\n")
            else:
                f.write(f"{hex(instr)[2:].zfill(8)}\n")


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

            bin_to_text("program.bin", "program.dat")

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
