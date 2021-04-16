import os
from pathlib import Path
import subprocess
import argparse
from struct import unpack


def stm_or_ldm(instr):
    return (instr >> 25) & 0b111 == 0b100 and (instr >> 22) & 0b1 == 0b0


def main(args):
    filepath = Path(args.filepath)

    # clangでデバッグ情報を埋め込んでオブジェクトファイルを作成する
    cmd_clang = f"clang -O0 -target armv5 -mfloat-abi=soft -g -c {filepath}"
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

            with open("program.bin", "rb") as f:
                tmp = f.read()

            data = unpack("<" + "I" * (len(tmp) // 4), tmp)
            with open("program.dat", "w") as f:
                for instr in data:
                    if stm_or_ldm(instr):
                        # push, pop命令は非対応なのでnopに置き換える
                        # レジスタの退避と復帰ができなくなるのでサブルーチンが使えなくなる
                        print("Replaced push(stm) and pop(ldm) instructions with nop.")
                        instr = int(
                            "1110_00_011010_0000_0000_00000_00_0_0000\n".replace("_", ""), 2
                        )
                    f.write(f"{hex(instr)[2:].zfill(8)}\n")

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
