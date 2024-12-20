from collections import deque

class Halt(Exception):
    pass

################################################################################
##                            Part One                                        ##
################################################################################

def part_one(lines: list[str]) -> int:
    instructions = [int(i) for i in lines[4].split(":")[1].strip().split(",")]
    output = run(instructions, a=int(lines[0].split(":")[1].strip()))
    return ",".join(str(i) for i in output)

def run(instructions: list[int], a: int) -> list[int]:
    register = {"A": a, "B": 0, "C": 0}
    output = []
    inst_pointer = 0

    try:
        while inst_pointer < len(instructions):
            inst, operand = read_instruction(instructions, inst_pointer)
            match inst:
                case 0: # adv
                    register["A"] = register["A"] // (2 ** combo(operand, register))
                case 1: # bxl
                    register["B"] = register["B"] ^ operand
                case 2: # bst
                    register["B"] = combo(operand, register) % 8
                case 3: # jnz
                    if register["A"] != 0:
                        inst_pointer = operand - 2 # -2 to counter future automatic +2
                case 4: # bxc
                    register["B"] = register["B"] ^ register["C"]
                case 5: # out
                    output.append(combo(operand, register) % 8)
                case 6: # bdv
                    register["B"] = register["A"] // (2 ** combo(operand, register))
                case 7: # cdv
                    register["C"] = register["A"] // (2 ** combo(operand, register))
            inst_pointer += 2
    except Halt:
        pass

    return output

def read_instruction(instructions: list[int], inst_pointer: int) -> tuple[int]:
    try:
        return instructions[inst_pointer], instructions[inst_pointer + 1]
    except IndexError:
        raise Halt

def combo(operand: int, register: dict[str, int]) -> int:
    match operand:
        case x if x in range(4):
            return x
        case 4:
            return register["A"]
        case 5:
            return register["B"]
        case 6:
            return register["C"]
        case _:
            raise Halt(f"Invalid operand {operand}")



################################################################################
##                            Part Two                                        ##
################################################################################

def part_two(lines: list[str]) -> int:
    instructions = [int(i) for i in lines[4].split(":")[1].strip().split(",")]
    og_a = int(lines[0].split(":")[1].strip())

    starting_a = 2 ** ((len(instructions) - 1) * 3)

    # Try to find rate of [0:3] matching
    # target012 = "24"
    # last_012 = ""
    # last_hit = starting_a-1
    # a = starting_a
    # while True:
    #     result = run(instructions, a)
    #     # print("".join(str(i) for i in result))
    #     cur012 = "".join(str(i) for i in result[0:2])
    #     if cur012 == target012 and cur012 != last_012:
    #         print(a-last_hit)
    #         last_hit = a
    #     last_012 = cur012
    #     a += 1

    a = starting_a
    last_result = run(instructions, a)
    while last_result != instructions:
        a += 1
        result = run(instructions, a)
        # print("".join(str(i) for i in result))
        for d in reversed(range(3, len(instructions))):
            if result[d] != last_result[d] and result[d] != instructions[d]:
                jump = (2 ** (d * 3))
                # if d > 1:
                #     print(f"result[{d}] changed from {last_result[d]} to {result[d]} but we want {instructions[d]}, jumping {jump}")
                a += jump - 1
                break
        last_result = result


    print("".join(str(i) for i in result))

    return a

    # Cycle detection
    # CYCLE_SIZE = 128
    # a = 5
    # result = []
    # result0 = deque()
    # # while result != instructions:
    # #     a += 32
    # #     result = run(instructions, a)
    #     # try:
    #     #     result0.append(f"{result[2]}")
    #     # except IndexError:
    #     #     pass
    #     # if len(result0) > CYCLE_SIZE:
    #     #     result0.popleft()
    #     # if len(result0) % 4 == 0 and len(result0) >= CYCLE_SIZE:
    #     #     chunk_size = len(result0) // 4
    #     #     l0 = list(result0)[0:chunk_size]
    #     #     l1 = list(result0)[chunk_size:chunk_size*2]
    #     #     l2 = list(result0)[chunk_size*2:chunk_size*3]
    #     #     l3 = list(result0)[chunk_size*3:chunk_size*4]
    #     #     # print(f"{l0}  {l1}  {l2}  {l3}")
    #     #     if l0 == l1 and l1 == l2 and l2 == l3:
    #     #         print("Cycle detected")
    #     #         exit()
