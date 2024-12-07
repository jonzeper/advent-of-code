from collections import defaultdict
from dataclasses import dataclass
from copy import deepcopy

class OutOfBounds(Exception):
    pass

class LoopDetected(Exception):
    pass

@dataclass
class WorldState:
    def __init__(self, lines: list[str]):
        self.guard_vector = (-1, 0) # Start off pointed up
        self.visited = set()
        self.lines = [list(line) for line in lines] # We're going to want lists of chars rather than strs to modify cells in part two
        self.hit_obstacles = set() # Use for loop detection. Tuple of obstacle location and guard orientation
        for y, line in enumerate(lines):
            for x, c in enumerate(line):
                if c == "^":
                    self.guard_position = (y, x)

    def render(self):
        for y, line in enumerate(self.lines):
            buf = ""
            for x, c in enumerate(line):
                if (y, x) in self.visited:
                    buf += "x"
                elif c == "#":
                    buf += c
                elif (y, x) == self.guard_position:
                    buf += "*"
                else:
                    buf += "."
            print(buf)

    def add_confounding_obstacle(self, obstacle_location: tuple[int]):
        self.lines[obstacle_location[0]][obstacle_location[1]] = "#"

    def rotate_guard(self):
        self.guard_vector = (self.guard_vector[1], 0-self.guard_vector[0])

    def move(self, detect_loops):
        self.visited.add(self.guard_position)
        next_y = self.guard_position[0] + self.guard_vector[0]
        next_x = self.guard_position[1] + self.guard_vector[1]
        if -1 in (next_x, next_y) or next_x == len(self.lines[0]) or next_y == len(self.lines):
            raise OutOfBounds
        if self.lines[next_y][next_x] == "#":
            hit_obstacle = ((next_y, next_x), self.guard_vector)
            if detect_loops and hit_obstacle in self.hit_obstacles:
                raise LoopDetected
            self.hit_obstacles.add(hit_obstacle)
            self.rotate_guard()
        else:
            self.guard_position = (next_y, next_x)

    def detect_loop(self):
        while True:
            try:
                self.move(detect_loops=True)
            except LoopDetected:
                return True
            except OutOfBounds:
                return False

    def run(self, detect_loops = False):
        try:
            while True:
                self.move(detect_loops=detect_loops)
        except OutOfBounds:
            return

def part_one(lines: list[str]) -> int:
    world = WorldState(lines)
    world.run()
    return len(world.visited)

def part_two(lines: list[str]) -> int:
    world = WorldState(lines)
    guard_start_loc = world.guard_position

    world.run() # To generate list of visited cells
    world.visited.discard(guard_start_loc) # Skip the first cell, where the guard starts. We can't place an obstacle there

    result = 0
    for loc in world.visited:
        clone = WorldState(lines)
        clone.add_confounding_obstacle(loc)
        try:
            clone.run(detect_loops=True)
        except LoopDetected:
            result += 1

    return result
