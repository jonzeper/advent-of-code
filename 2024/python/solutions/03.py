PARSE_INSTRUCTION = 0
PARSE_INT = 1
PARSE_DO = 2
PARSE_DONT = 3

class Parser:
    def __init__(self):
        self.reset()

    def reset(self):
        self.state = PARSE_INSTRUCTION
        self.buffer = ""
        self.mul_args = []
        self.cur_int = -1

def part_one(lines: list[str]) -> int:
    s = "\n".join(lines) # Undo the automatic line splitting
    sum = 0
    p = Parser()
    for c in s:
        if p.state == PARSE_INSTRUCTION:
            if c == "(": # We were parsing an instruction and hit a open paren
                if p.buffer.endswith("mul"): # If we had a valid instruction, switch to int parsing
                    p.state = PARSE_INT
            else:
                p.buffer += c
        elif p.state == PARSE_INT:
            if c == ",":
                if p.cur_int > -1 and len(p.mul_args) == 0:
                    p.mul_args.append(p.cur_int)
                    p.cur_int = -1
                else:
                    p.reset()
            elif c == ")":
                if p.cur_int > -1 and len(p.mul_args) == 1:
                    p.mul_args.append(p.cur_int)
                    sum += p.mul_args[0] * p.mul_args[1]
                    p.reset()
            elif c.isdigit():
                if p.cur_int == -1:
                    p.cur_int = int(c)
                elif p.cur_int < 100:
                    p.cur_int = p.cur_int * 10 + int(c)
                else: # Only 1-3 digit numbers are allowed!
                    p.reset()
            else:
                p.reset()
    return sum

def part_two(lines: list[str]) -> int:
    s = "\n".join(lines) # Undo the automatic line splitting
    sum = 0
    mul_active = True
    p = Parser()
    for c in s:
        if p.state == PARSE_INSTRUCTION:
            if c == "(": # We were parsing an instruction and hit a open paren
                if p.buffer.endswith("mul"): # If we had a valid instruction, switch to int parsing
                    p.state = PARSE_INT
                elif p.buffer.endswith("do"):
                    p.state = PARSE_DO
                elif p.buffer.endswith("don't"):
                    p.state = PARSE_DONT
            else:
                p.buffer += c
        elif p.state == PARSE_DO:
            if c == ")":
                mul_active = True
            p.reset()
        elif p.state == PARSE_DONT:
            if c == ")":
                mul_active = False
            p.reset()
        elif p.state == PARSE_INT:
            if c == ",":
                if p.cur_int > -1 and len(p.mul_args) == 0:
                    p.mul_args.append(p.cur_int)
                    p.cur_int = -1
                else:
                    p.reset()
            elif c == ")":
                if p.cur_int > -1 and len(p.mul_args) == 1:
                    p.mul_args.append(p.cur_int)
                    if mul_active:
                        sum += p.mul_args[0] * p.mul_args[1]
                    p.reset()
            elif c.isdigit():
                if p.cur_int == -1:
                    p.cur_int = int(c)
                elif p.cur_int < 100:
                    p.cur_int = p.cur_int * 10 + int(c)
                else: # Only 1-3 digit numbers are allowed!
                    p.reset()
            else:
                p.reset()
    return sum
