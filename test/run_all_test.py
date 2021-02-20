import os
import sys
import json
from pathlib import Path
import subprocess


def run_test(testbench_filename, dependency_list, root_dir):
    print(f"{' Compilation ':=^30}")
    dependency_str = ' '.join([str(root_dir / 'src' / module_filename) for module_filename in dependency_list])
    cmd = (
        "iverilog -g2012 -o main "
        f"{str(root_dir / 'test' / testbench_filename)} {dependency_str}"
    )
    result = subprocess.run(cmd, shell=True)

    if result.returncode != 0:
        sys.exit("Compile Error!")

    print(f"{' Simulation ':=^30}")
    cmd = "vvp main"
    result = subprocess.run(cmd, shell=True)

    if result.returncode != 0:
        sys.exit("Simulation Failed!")


def main():
    root_dir = Path(__file__).resolve().parent.parent
    test_dir = root_dir / "test"
    os.chdir(test_dir)
    with open(test_dir / "dependencies.json", encoding="utf-8") as f:
        dependencies = json.load(f)

    for testbench_name, dependency_list in dependencies.items():
        print(f"Run {testbench_name} ")
        run_test(testbench_name + ".sv", dependency_list, root_dir)
        print()


if __name__ == "__main__":
    main()
