import os
import sys
import json
from pathlib import Path
import subprocess
from shutil import copy


class Color:
    RED = "\033[31m"  # (文字)赤
    GREEN = "\033[32m"  # (文字)緑
    END = "\033[0m"  # 終了


def run_program(program_filename, dependency_list, root_dir):
    print(f"{Color.GREEN}{f' Compilation ':=^30}{Color.END}")
    dependency_str = " ".join(
        [str(root_dir / "src" / module_filename) for module_filename in dependency_list]
    )
    cmd = (
        "iverilog -g2012 -Wall -o main "
        f"{str(root_dir / 'test' / program_filename)} {dependency_str}"
    )
    result = subprocess.run(cmd, shell=True)

    if result.returncode != 0:
        sys.exit(f"{Color.RED}Compile Error!{Color.END}")

    print(f"{Color.GREEN}{' Simulation ':=^30}{Color.END}")
    cmd = "vvp main"
    result = subprocess.run(cmd, shell=True)

    if result.returncode != 0:
        sys.exit(f"{Color.RED}Simulation Failed!{Color.END}")


def main(from_file):
    root_dir = Path(__file__).resolve().parent.parent
    test_dir = root_dir / "test"
    to_file = test_dir / "programs" / "program.dat"

    os.chdir(test_dir)
    with open(test_dir / "dependencies.json", encoding="utf-8") as f:
        dependency_list = json.load(f)["test_top"]

        print(f"{Color.GREEN}Run program{Color.END}")
        try:
            copy(str(from_file), str(to_file))
            run_program("run_program.sv", dependency_list, root_dir)
        finally:
            if to_file.exists():
                to_file.unlink(missing_ok=True)


if __name__ == "__main__":
    argvs = sys.argv
    argc = len(argvs)
    if argc != 2:
        sys.exit(f"Usage: python {argvs[0]} <program_file (hex format text)>")

    from_file = Path(argvs[1])
    main(from_file)
