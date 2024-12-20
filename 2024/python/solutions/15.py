from dataclasses import dataclass
from collections import defaultdict

CHAR_TO_VEC = {
    "<": (0, -1),
    "^": (-1, 0),
    ">": (0, 1),
    "v": (1, 0)
}

################################################################################
##                            Part One                                        ##
################################################################################

@dataclass
class World:
    grid: dict[tuple[int], str]
    grid_size: tuple[int]
    moves: list[str]
    robot_pos: tuple[int]

    def __init__(self, lines):
        self.grid = {}
        for y, line in enumerate(lines):
            if line == "":
                break
            for x, c in enumerate(line):
                if c == "@":
                    self.robot_pos = (y, x)
                if c == "#" or c == "O":
                    self.grid[(y, x)] = c
        self.grid_size = [y, x+1]
        self.moves = []
        for line in lines[y:]:
            self.moves += (CHAR_TO_VEC[c] for c in line)

    def render(self):
        for y in range(self.grid_size[0]):
            line = ""
            for x in range(self.grid_size[1]):
                pos = (y, x)
                if self.robot_pos == pos:
                    line += "@"
                elif c := self.grid.get(pos):
                    line += c
                else:
                    line += "."
            print(line)


    def move_robot(self, vec: tuple):
        src = self.robot_pos
        dst = (src[0] + vec[0], src[1] + vec[1])
        if self.grid.get(dst) == "#":
            return False
        elif self.grid.get(dst) == "O":
            if self.move_object(dst, vec):
                self.robot_pos = dst
        else:
            self.robot_pos = dst

    def move_object(self, src: tuple, vec: tuple):
        dst = (src[0] + vec[0], src[1] + vec[1])
        if self.grid.get(dst) == "#":
            return False
        elif self.grid.get(dst) == "O":
            if self.move_object(dst, vec):
                del self.grid[src]
                self.grid[dst] = "O"
                return True
            else:
                return False
        else:
            del self.grid[src]
            self.grid[dst] = "O"
            return True

def part_one(lines: list[str]) -> int:
    world = World(lines)
    for vec in world.moves:
        # world.render()
        # print(f"Next: {vec}")
        # input()
        world.move_robot(vec)

    answer = 0
    for (y, x), c in world.grid.items():
        if c == "O":
            answer += y * 100 + x
    return answer

################################################################################
##                            Part Two                                        ##
################################################################################

@dataclass
class World2:
    grid: dict[tuple[int], str]
    grid_size: tuple[int]
    moves: list[str]
    robot_pos: tuple[int]

    def __init__(self, lines):
        self.grid = {}
        for y, line in enumerate(lines):
            if line == "":
                break
            for x, c in enumerate(line):
                if c == "@":
                    self.robot_pos = (y, x*2)
                elif c == "#":
                    self.grid[(y, x*2)] = c
                    self.grid[(y, x*2+1)] = c
                elif c == "O":
                    self.grid[(y, x*2)] = c
        self.grid_size = (y, (x+1)*2)
        self.moves = []
        for line in lines[y:]:
            self.moves += (CHAR_TO_VEC[c] for c in line)

    def render(self):
        for y in range(self.grid_size[0]):
            line = ""
            x = 0
            while x < self.grid_size[1]:
                pos = (y, x)
                if self.robot_pos == pos:
                    line += "@"
                else:
                    c = self.grid.get(pos)
                    if c == "O":
                        line += "[]"
                        x += 1
                    elif c == "#":
                        line += "#"
                    else:
                        line += "."
                x += 1
            print(line)


    def move_robot(self, vec: tuple):
        if self.can_move_robot(vec):
            self.do_move_robot(vec)

    def can_move_robot(self, vec):
        src = self.robot_pos
        dst = (src[0] + vec[0], src[1] + vec[1])
        if self.grid.get(dst) == "#":
            return False
        match vec:
            case (0, -1):
                if self.grid.get((dst[0], dst[1] - 1)) == "O":
                    return self.can_move_object((dst[0], dst[1] - 1), vec)
            case (0, 1):
                if self.grid.get(dst) == "O":
                    return self.can_move_object(dst, vec)
            case (-1, 0) | (1, 0):
                abutting_objects = []
                for dx in (-1, 0):
                    if self.grid.get((dst[0], dst[1] + dx)) == "O":
                        abutting_objects.append((dst[0], dst[1] + dx))
                return all(self.can_move_object(opos, vec) for opos in abutting_objects)
        return True

    def do_move_robot(self, vec):
        src = self.robot_pos
        dst = (src[0] + vec[0], src[1] + vec[1])
        match vec:
            case (0, -1):
                if self.grid.get((dst[0], dst[1] - 1)) == "O":
                    self.do_move_object((dst[0], dst[1] - 1), vec)
            case (0, 1):
                if self.grid.get(dst) == "O":
                    self.do_move_object(dst, vec)
            case (-1, 0) | (1, 0):
                for dx in (-1, 0):
                    if self.grid.get((dst[0], dst[1] + dx)) == "O":
                        self.do_move_object((dst[0], dst[1] + dx), vec)
        self.robot_pos = dst

    def can_move_object(self, src, vec):
        dst = (src[0] + vec[0], src[1] + vec[1])
        if self.grid.get(dst) == "#":
            return False
        abutting_objects = []
        match vec:
            case (0, -1):
                if self.grid.get((dst[0], dst[1] - 1)) == "O":
                    abutting_objects.append((dst[0], dst[1] - 1))
            case (0, 1):
                if self.grid.get((dst[0], dst[1] + 1)) == "#":
                    return False
                if self.grid.get((dst[0], dst[1] + 1)) == "O":
                    abutting_objects.append((dst[0], dst[1] + 1))
            case (-1, 0) | (1, 0):
                if self.grid.get(dst) == "#" or self.grid.get((dst[0], dst[1] + 1)) == "#":
                    return False
                for dx in (-1, 0, 1):
                    if self.grid.get((dst[0], dst[1] + dx)) == "O":
                        abutting_objects.append((dst[0], dst[1] + dx))
        return all(self.can_move_object(opos, vec) for opos in abutting_objects)


    def do_move_object(self, src, vec):
        dst = (src[0] + vec[0], src[1] + vec[1])
        match vec:
            case (0, -1):
                if self.grid.get((dst[0], dst[1] - 1)) == "O":
                    self.do_move_object((dst[0], dst[1] - 1), vec)
            case (0, 1):
                if self.grid.get((dst[0], dst[1] + 1)) == "O":
                    self.do_move_object((dst[0], dst[1] + 1), vec)
            case (-1, 0) | (1, 0):
                for dx in (-1, 0, 1):
                    if self.grid.get((dst[0], dst[1] + dx)) == "O":
                        self.do_move_object((dst[0], dst[1] + dx), vec)
        del self.grid[src]
        self.grid[dst] = "O"

def part_two(lines: list[str]) -> int:
    world = World2(lines)
    # world.render()
    for vec in world.moves:
        # world.render()
        # print(f"Next: {vec}")
        # input()
        world.move_robot(vec)
    # world.render()

    answer = 0
    for (y, x), c in sorted(world.grid.items()):
        if c == "O":
            answer += y * 100 + x
    return answer

