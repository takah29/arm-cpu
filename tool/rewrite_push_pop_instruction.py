import sys


def get_register_list(instr):
    # use only push(stm) or pop(ldm) instructions.
    return [i for i in range(16) if (instr >> i) & 0b1 == 1]


def push_to_strs(instr):
    # use only push(stm) instructions.
    result = []
    reg_list = get_register_list(instr)
    n_regs = len(reg_list)

    # sub instruction
    bin_rep = f"1110_00_100100_1101_1101_0000_{bin(4 * n_regs)[2:].zfill(8)}"
    instr = int(bin_rep.replace("_", ""), 2)
    result.append(instr)

    # str instructions
    for i, rd in enumerate(reg_list[::-1], start=1):
        bin_rep = (
            f"1110_01_011000_1101_{bin(rd)[2:].zfill(4)}_{bin(4 * (n_regs - i))[2:].zfill(12)}"
        )
        instr = int(bin_rep.replace("_", ""), 2)
        result.append(instr)

    return result


def pop_to_ldrs(instr):
    # use only pop(ldm) instructions.
    result = []
    reg_list = get_register_list(instr)
    n_regs = len(reg_list)

    # ldr instructions
    for i, rd in enumerate(reg_list, start=0):
        bin_rep = f"1110_01_011001_1101_{bin(rd)[2:].zfill(4)}_{bin(4 * i)[2:].zfill(12)}"
        instr = int(bin_rep.replace("_", ""), 2)
        result.append(instr)

    # add instruction
    bin_rep = f"1110_00_101000_1101_1101_0000_{bin(4 * n_regs)[2:].zfill(8)}"
    instr = int(bin_rep.replace("_", ""), 2)
    result.append(instr)

    return result


def is_stm(instr):
    return (
        (instr >> 25) & 0b111 == 0b100 and (instr >> 22) & 0b1 == 0b0 and (instr >> 20) & 0b1 == 0b0
    )


def is_ldm(instr):
    return (
        (instr >> 25) & 0b111 == 0b100 and (instr >> 22) & 0b1 == 0b0 and (instr >> 20) & 0b1 == 0b1
    )


def is_ldr_pc(instr):
    return (
        (instr >> 25) & 0b111 == 0b010
        and (instr >> 22) & 0b1 == 0b0
        and (instr >> 20) & 0b1 == 0b1
        and (instr >> 16) & 0b1111 == 0b1111
    )


def is_branch(instr):
    if (instr >> 24) & 0b1111 == 0b1010:  # B
        return True
    elif (instr >> 24) & 0b1111 == 0b1011:  # BL
        return True
    elif (instr >> 25) & 0b1111111 == 0b1111101:  # BLX(1)
        return True

    return False


def rewrite_ldr_pc(no, instr, target_no, target_len):
    if is_ldr_pc(instr):
        # 参照アドレス
        ref_no = (no + 2) + (-1) ** (1 - ((instr >> 23) & 0b1)) * ((instr & 0xFFF) // 4)
        print(f"(line {no}) ldr imm12: {ref_no - (no + 2)} ", end="")
        if no < target_no and ref_no > target_no:
            ref_no += target_len - 1
        elif no > target_no and ref_no < target_no:
            no += target_len - 1
        rel_no = ref_no - (no + 2)
        print(f" -> {ref_no - (no + 2)}")
        instr = (instr & 0xFF7FF000) | ((rel_no >= 0) << 23) | ((abs(rel_no) * 4) & 0xFFF)

    return instr


def rewrite_b(no, instr, target_no, target_len):
    if is_branch(instr):
        sig = (-1) ** ((instr >> 23) & 0b1 == 0b1)
        num = (0x7FFFFF - (instr & 0x7FFFFF)) + 1 if sig == -1 else (instr & 0x7FFFFF)
        ref_no = (no + 2) + sig * num
        print(f"(line {no}) branch imm24: {ref_no - (no + 2)} ", end="")
        if no < target_no and ref_no > target_no:
            ref_no += target_len - 1
        elif no > target_no and ref_no < target_no:
            no += target_len - 1

        rel_no = ref_no - (no + 2)
        sig = (-1) ** (rel_no < 0)
        print(f" -> {ref_no - (no + 2)}")
        instr = (
            (instr & 0xFF000000)
            | ((sig == -1) << 23)
            | (
                ((0x7FFFFF - (abs(rel_no) & 0x7FFFFF)) + 1)
                if sig == -1
                else (abs(rel_no) & 0x7FFFFF)
            )
        )

    return instr


def to_hex_string(instr):
    return hex(instr)[2:].zfill(8)


def main(filepath):
    with open(filepath, "r") as f:
        lines = f.readlines()
        programs = [int(x.strip(), 16) for x in lines]

    while True:
        push_or_pop = False
        for instr in programs:
            if is_stm(instr) or is_ldm(instr):
                push_or_pop = True

        if not push_or_pop:
            break

        for i, instr in enumerate(programs):
            if is_stm(instr):
                print(f"===== replace push instr (line {i}) =====")
                instr_list = push_to_strs(instr)
                for j, instr2 in enumerate(programs):
                    instr2 = rewrite_ldr_pc(j, instr2, i, len(instr_list))
                    instr2 = rewrite_b(j, instr2, i, len(instr_list))
                    programs[j] = instr2
                programs[i : i + 1] = instr_list
                break
            elif is_ldm(instr):
                print(f"===== replace pop instr (line {i}) =====")
                instr_list = pop_to_ldrs(instr)
                for j, instr2 in enumerate(programs):
                    instr2 = rewrite_ldr_pc(j, instr2, i, len(instr_list))
                    instr2 = rewrite_b(j, instr2, i, len(instr_list))
                    programs[j] = instr2
                programs[i : i + 1] = instr_list
                break

    with open("program_.dat", "w") as f:
        for instr in programs:
            f.write(f"{to_hex_string(instr)}\n")


if __name__ == "__main__":
    argvs = sys.argv
    argc = len(argvs)

    if argc != 2:
        sys.exit(f"python {argvs[0]} <program file>")

    filepath = argvs[1]

    main(filepath)