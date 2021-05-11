import os
from pathlib import Path
import subprocess
import argparse
from struct import unpack


def to_hex_string(instr):
    return hex(instr)[2:].zfill(8)


def binary_to_text(from_file, to_file):
    with open(from_file, "rb") as f:
        tmp = f.read()

    data = unpack("<" + "I" * (len(tmp) // 4), tmp)
    with open(to_file, "w") as f:
        for i, instr in enumerate(data):
            f.write(f"{to_hex_string(instr)}\n")


def compile_source(filepath):
    # clangでデバッグ情報を埋め込んでオブジェクトファイルを作成する
    # cmd_clang = f"clang -O0 -target armv5 -mfloat-abi=soft -g -c {filepath}"
    cmd_gcc = [
        "arm-none-eabi-gcc",
        "-O0",
        "--specs=nosys.specs",
        "-march=armv5t",
        "-mfloat-abi=soft",
        "-g",
        "-c",
        filepath,
    ]
    subprocess.run(cmd_gcc)


def main(args):
    filepath = Path(args.filepath)

    # ファイル形式チェック
    if args.exe_file:
        if filepath.suffix != ".out":  # 実行ファイル
            raise NotImplementedError("The extension must be .out.")
    else:
        if filepath.suffix != ".c":  # ソースファイル
            raise NotImplementedError("The extension must be .c.")

    if not args.exe_file:
        compile_source(str(filepath))
        filepath = Path(f"{filepath.stem}.o")

    try:
        if args.debug:
            # オブジェクトファイルを逆アセンブルしてtextセクションだけ表示する
            cmd = f"llvm-objdump -S -j .text {str(filepath)}"
            subprocess.run(cmd.split(" "))
        else:
            # オブジェクトファイルからtextセクションだけ取り出す
            cmd = f"llvm-objcopy -O binary --only-section=.text {str(filepath)} program.bin"
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
    parser = argparse.ArgumentParser(
        description="Extract and save the text section of an object file"
    )
    parser.add_argument("filepath", help="C-source filepath")
    parser.add_argument("-d", "--debug", action="store_true")
    parser.add_argument("-e", "--exe_file", action="store_true")

    args = parser.parse_args()

    main(args)
