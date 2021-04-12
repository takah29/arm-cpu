import os
from pathlib import Path
import subprocess
import argparse


def main(args):
    filepath = Path(args.filepath)

    # clangでデバッグ情報を埋め込んでオブジェクトファイルを作成する
    cmd_clang = f"clang -O0 -target armv6 -mfloat-abi=soft -g -c {filepath}"
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
            cmd = "xxd -ps -c 4 program.bin program.dat"
            ret = subprocess.run(cmd.split(" "))

            if ret.returncode == 0:
                print("output program.dat")
            else:
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
