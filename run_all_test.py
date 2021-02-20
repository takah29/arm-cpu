import sys
from pathlib import Path
import subprocess


def main():
    argvs = sys.argv
    argc = len(argvs)

    if argc == 1:
        sys.exit(f"Usage: python {Path(__file__).name} <target dirs>")

    root_dir = Path(__file__).resolve().parent
    target_dirs = argvs[1:]

    for d in target_dirs:
        testbench_path_list = (root_dir / d / "test").glob("test_*.sv")
        for testbench_path in testbench_path_list:
            cmd = f"python run_testbench.py {testbench_path}"
            print(f"Run {testbench_path.name} ")
            subprocess.run(cmd, shell=True)
            print()


if __name__ == "__main__":
    main()
