def parse_line(line):
    test_value, operands = line.split(":")
    test_value = int(test_value)
    operands = [int(i) for i in operands.strip().split(" ")]
    return test_value, operands

def part_one(lines: list[str]) -> int:
    result = 0
    for line in lines:
        test_value, operands = parse_line(line)
        if could_be_valid(test_value, 0, operands):
            result += test_value
    return result

def could_be_valid(test_value, cur_value, operands) -> bool:
    if cur_value > test_value:
        return False
    next_operand = operands[0]
    if len(operands) == 1:
        return cur_value + next_operand == test_value or cur_value * next_operand == test_value
    else:
        return could_be_valid(test_value, cur_value + next_operand, operands[1:]) or could_be_valid(test_value, cur_value * next_operand, operands[1:])


def could_be_valid_2(test_value, cur_value, operands) -> bool:
    if cur_value > test_value:
        return False # Short circuiting here knocks time from ~4s to ~3s
    next_operand = operands[0]
    if len(operands) == 1:
        return cur_value + next_operand == test_value or cur_value * next_operand == test_value or concat_i(cur_value, next_operand) == test_value
    else:
        return could_be_valid_2(test_value, cur_value + next_operand, operands[1:]) or could_be_valid_2(test_value, cur_value * next_operand, operands[1:]) or could_be_valid_2(test_value, concat_i(cur_value, next_operand), operands[1:])

# NOTE concat this way instead of stringifying knocks ~3s to ~2s
def concat_i(a: int, b: int) -> int:
    # Assumption: a and b are between 1 and 999
    if b < 10:
        return a * 10 + b
    if b < 100:
        return a * 100 + b
    return a * 1000 + b

def part_two(lines: list[str]) -> int:
    result = 0
    for line in lines:
        test_value, operands = parse_line(line)
        if could_be_valid_2(test_value, 0, operands):
            result += test_value
    return result
