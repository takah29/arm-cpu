from pathlib import Path
import subprocess
import argparse


def main(args):
    filepath = Path(args.filepath)
    cmd = f"clang -O0 -target arm -g -c {filepath}"
    print(cmd)
    subprocess.call(cmd)
    cmd = f"llvm-objcopy {filepath.stem}.o -O binary program.bin"
    print(cmd)
    subprocess.call(cmd)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Compile C-source with clang")
    parser.add_argument("filepath", help="C-source filepath")
    args = parser.parse_args()

    main(args)
