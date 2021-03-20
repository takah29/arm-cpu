import os
import sys
import json
from pathlib import Path
import subprocess


class Color:
    RED = "\033[31m"  # (文字)赤
    GREEN = "\033[32m"  # (文字)緑
    END = "\033[0m"  # 終了


def run_test(testbench_filename, dependency_list, root_dir):
    print(f"{Color.GREEN}{f' Compilation ':=^30}{Color.END}")
    dependency_str = " ".join(
        [str(root_dir / "src" / module_filename) for module_filename in dependency_list]
    )
    cmd = (
        "iverilog -g2012 -Wall -o main "
        f"{str(root_dir / 'test' / testbench_filename)} {dependency_str}"
    )
    result = subprocess.run(cmd, shell=True)

    if result.returncode != 0:
        sys.exit(f"{Color.RED}Compile Error!{Color.END}")

    print(f"{Color.GREEN}{' Simulation ':=^30}{Color.END}")
    cmd = "vvp main"
    result = subprocess.run(cmd, shell=True)

    if result.returncode != 0:
        sys.exit(f"{Color.RED}Simulation Failed!{Color.END}")


def main():
    root_dir = Path(__file__).resolve().parent.parent
    test_dir = root_dir / "test"
    os.chdir(test_dir)
    with open(test_dir / "dependencies.json", encoding="utf-8") as f:
        dependencies = json.load(f)

    for testbench_name, dependency_list in dependencies.items():
        print(f"{Color.GREEN}Run {testbench_name}{Color.END}")
        run_test(testbench_name + ".sv", dependency_list, root_dir)
        print()


if __name__ == "__main__":
    main()
