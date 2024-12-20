from collections import namedtuple, defaultdict
import heapq
from rich import print
from dataclasses import dataclass, field

################################################################################
##                            Part One                                        ##
################################################################################

PathState = namedtuple("PathState", "score pos vec last_step".split())

def part_one(lines: list[str]) -> int:
    for y, line in enumerate(lines):
        for x, c in enumerate(line):
            if c == "S":
                start_pos = (y, x)
            if c == "E":
                end_pos = (y, x)
    pos = start_pos

    opts = []
    visited = defaultdict(lambda: float("inf"))
    lowest_score = float("inf")
    next_options(lines, opts, pos, (0, 1), 0)
    while len(opts) > 0:
        opt = heapq.heappop(opts)
        if opt.score >= visited[(opt.pos, opt.vec)]:
            continue
        visited[(opt.pos, opt.vec)] = opt.score
        if opt.pos == end_pos:
            if opt.score < lowest_score:
                lowest_score = opt.score
        if opt.score < lowest_score:
            next_options(lines, opts, opt.pos, opt.vec, opt.score, opt.last_step)

    return lowest_score

def next_options(lines, options, pos, vec, score, last_step="walk"):
    if last_step != "turn":
        heapq.heappush(options, PathState(score + 1000, pos, (vec[1], 0-vec[0]), "turn"))
        heapq.heappush(options, PathState(score + 1000, pos, (0-vec[1], vec[0]), "turn"))
    dst = (pos[0] + vec[0], pos[1] + vec[1])
    try:
        if lines[dst[0]][dst[1]] != "#":
            heapq.heappush(options, PathState(score + 1, dst, vec, "walk"))
    except IndexError:
        pass

def render(lines, ps: PathState, steps=set()):
    u = {
        (-1, 0): "^",
        (0, 1): ">",
        (1, 0): "v",
        (0, -1): "<"
    }[ps.vec]
    for y, line in enumerate(lines):
        buf = ""
        for x, c in enumerate(line):
            if (y, x) == ps.pos:
                buf += u
            elif (y, x) in steps:
                buf += "O"
            else:
                buf += c
        print(buf)

################################################################################
##                            Part Two                                        ##
################################################################################

PathState2 = namedtuple("PathState", "weighted_score score pos vec steps".split())

@dataclass
class PathOption:
    score: int
    weighted_score: int = 0
    pos: tuple[int] = (0, 0)
    vec: tuple[int] = (0, 1)
    steps: set[tuple[int]] = field(default_factory=set)

    def __lt__(self, other):
        return self.weighted_score < other.weighted_score

def part_two(lines: list[str]) -> int:
    for y, line in enumerate(lines):
        for x, c in enumerate(line):
            if c == "S":
                start_pos = (y, x)
            if c == "E":
                end_pos = (y, x)
    pos = start_pos

    opts: list[PathOption] = []
    visited: dict[tuple[tuple[int]], PathOption] = {}
    lowest_score = float("inf")
    steps = set()

    for opt in next_options_gen(lines, visited, PathOption(0, 0, pos, (0, 1), steps)):
        heapq.heappush(opts, opt)

    max_cans = 0
    while len(opts) > 0:
        if len(opts) > max_cans:
            max_cans = len(opts)
        opt = heapq.heappop(opts)

        visited_before = visited.get((opt.pos, opt.vec))
        # if visited_before and visited_before.score == opt.score:
        #     for future_opt in opts:
        #         if opt.pos in future_opt.steps:
        #             future_opt.steps |= opt.steps
        #     continue

        if visited_before and opt.score > visited_before.score:
            continue
        else:
            visited[(opt.pos, opt.vec)] = opt

        if opt.pos == end_pos:
            if opt.score <= lowest_score:
                lowest_score = opt.score
                steps = steps | opt.steps
        if opt.score < lowest_score:
            for opt in next_options_gen(lines, visited, opt):
                heapq.heappush(opts, opt)
        # render2(lines, opt, opt.steps)
        # print(f"{opt.weighted_score=} {opt.score=}")
        # input()

    print(f"{max_cans=}")
    return len(steps) + 1 # Plus the start step

def next_options_gen(lines, visited, opt: PathOption):
    for vec, score in (
        (opt.vec, 1),
        ((opt.vec[1], 0-opt.vec[0]), 1001),
        ((0-opt.vec[1], opt.vec[0]), 1001)
    ):
        dest = (opt.pos[0] + vec[0], opt.pos[1] + vec[1])
        # if (dest, vec) in visited:

        weight = 0
        if vec[0] == 1 or vec[1] == -1:
            # If we're walking away from E, we know we'll have to turn around at some point.
            # This helps extremely little..
            weight += 2000
        try:
            if lines[dest[0]][dest[1]] != "#" and dest not in opt.steps: # dest not in opt.steps helps just a little
                yield PathOption(opt.score + score, opt.score + score + weight, dest, vec, opt.steps | {dest})
        except IndexError:
            pass

def render2(lines, ps: PathState, steps=set()):
    u = {
        (-1, 0): "^",
        (0, 1): ">",
        (1, 0): "v",
        (0, -1): "<"
    }[ps.vec]
    for y, line in enumerate(lines):
        buf = ""
        for x, c in enumerate(line):
            if (y, x) == ps.pos:
                buf += f"[green]{u}[/green]"
            elif (y, x) in steps:
                buf += "[red]•[/red]"
            else:
                buf += f"[grey7]{c}[/grey7]"
        print(buf)
