import bisect

from collections import defaultdict
from dataclasses import dataclass

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
        self.x_indexed_obstacles = defaultdict(list) # Y position of obstacles (in asc order) for each X value
        self.y_indexed_obstacles = defaultdict(list) # X position of obstacles (in asc order) for each Y value
        for y, line in enumerate(lines):
            for x, c in enumerate(line):
                if c == "^":
                    self.guard_position = (y, x)
                if c == "#":
                    self.x_indexed_obstacles[x].append(y)
                    self.y_indexed_obstacles[y].append(x)

    @property
    def guard_x(self):
        return self.guard_position[1]

    @property
    def guard_y(self):
        return self.guard_position[0]

    def render(self):
        print(self.guard_vector, self.guard_position)
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
        bisect.insort(self.x_indexed_obstacles[obstacle_location[1]], obstacle_location[0])
        bisect.insort(self.y_indexed_obstacles[obstacle_location[0]], obstacle_location[1])

    def rotate_guard(self):
        self.guard_vector = (self.guard_vector[1], 0-self.guard_vector[0])

    def move(self):
        self.visited.add(self.guard_position)
        next_y = self.guard_y + self.guard_vector[0]
        next_x = self.guard_x + self.guard_vector[1]
        if -1 in (next_x, next_y) or next_x == len(self.lines[0]) or next_y == len(self.lines):
            raise OutOfBounds
        if self.lines[next_y][next_x] == "#":
            self.rotate_guard()
        else:
            self.guard_position = (next_y, next_x)

    def jump(self):
        # Used by part two. Since we have no use for tracking each cell visited, we'll move the guard directly to the next
        # obstacle. Assuming obstacles are relatively sparse, this should be faster. (ends up being about 2x faster than walking)
        hit_obstacle = None
        if self.guard_vector[0] == -1: # Moving up
            for obstacle_y in reversed(self.x_indexed_obstacles[self.guard_x]):
                if obstacle_y < self.guard_y:
                    hit_obstacle = ((obstacle_y, self.guard_x), self.guard_vector)
                    next_y = obstacle_y + 1
                    next_x = self.guard_x
                    break
        elif self.guard_vector[0] == 1: # Moving down
            for obstacle_y in self.x_indexed_obstacles[self.guard_x]:
                if obstacle_y > self.guard_y:
                    hit_obstacle = ((obstacle_y, self.guard_x), self.guard_vector)
                    next_y = obstacle_y - 1
                    next_x = self.guard_x
                    break
        elif self.guard_vector[1] == -1: # Moving left
            for obstacle_x in reversed(self.y_indexed_obstacles[self.guard_y]):
                if obstacle_x < self.guard_x:
                    hit_obstacle = ((self.guard_y, obstacle_x), self.guard_vector)
                    next_y = self.guard_y
                    next_x = obstacle_x + 1
                    break
        elif self.guard_vector[1] == 1: # Moving right
            for obstacle_x in self.y_indexed_obstacles[self.guard_y]:
                if obstacle_x > self.guard_x:
                    hit_obstacle = ((self.guard_y, obstacle_x), self.guard_vector)
                    next_y = self.guard_y
                    next_x = obstacle_x - 1
                    break
        if hit_obstacle:
            if hit_obstacle in self.hit_obstacles:
                raise LoopDetected
            self.hit_obstacles.add(hit_obstacle)
            self.guard_position = (next_y, next_x)
            self.rotate_guard()
        else:
            # If we didn't hit an obstacle above, we jumped off the grid
            raise OutOfBounds

    def run(self, detect_loops = False):
        try:
            while True:
                if detect_loops:
                    self.jump()
                else:
                    self.move()
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
