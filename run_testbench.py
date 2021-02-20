import sys
import os
import subprocess
from pathlib import Path
from glob import glob


def main():
    argvs = sys.argv
    argc = len(argvs)

    if argc != 2:
        sys.exit(f"python {argvs[0]} [testbench_path]")

    testbench_path = Path(argvs[1]).resolve()

    os.chdir(testbench_path.parent)
    print(f"{' Compilation ':=^30}")
    submodule_files = [fn for fn in (testbench_path.parent.parent / "src").glob("*.sv")]
    cmd = (
        "iverilog -g2012 -o main "
        f"{str(testbench_path)} {' '.join([str(s) for s in submodule_files])}"
    )
    result = subprocess.run(cmd, shell=True)

    if result.returncode != 0:
        sys.exit("Compile Error!")

    print(f"{' Simulation ':=^30}")
    cmd = "vvp main"
    result = subprocess.run(cmd, shell=True)

    if result.returncode != 0:
        sys.exit("Simulation Failed!")


if __name__ == "__main__":
    main()
