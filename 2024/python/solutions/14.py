from dataclasses import dataclass
from collections import defaultdict

@dataclass
class RobotSecurityGuard:
    x: int
    y: int
    vx: int
    vy: int


################################################################################
##                            Part One                                        ##
################################################################################

def part_one(lines: list[str]) -> int:
    guards = []
    for line in lines:
        vals = [int(i) for i in line.replace("p=", "").replace("v=", "").replace(" ",",").split(",")]
        guards.append(RobotSecurityGuard(x=vals[0], y=vals[1], vx=vals[2], vy=vals[3]))

    if guards[0].x == 0:
        grid_width = 11
        grid_height = 7
    else:
        grid_width = 101
        grid_height = 103
    for guard in guards:
        guard.x = (guard.x + (guard.vx * 100)) % grid_width
        guard.y = (guard.y + (guard.vy * 100)) % grid_height
    quads = [0, 0, 0, 0]
    for guard in guards:
        if guard.x < grid_width // 2:
            if guard.y < grid_height // 2:
                quads[0] += 1
            elif guard.y > grid_height // 2:
                quads[2] += 1
        elif guard.x > grid_width // 2:
            if guard.y < grid_height // 2:
                quads[1] += 1
            elif guard.y > grid_height // 2:
                quads[3] += 1
    return quads[0] * quads[1] * quads[2] * quads[3]

################################################################################
##                            Part Two                                        ##
################################################################################

def part_two(lines: list[str]) -> int:
    guards = []
    guards_by_pos = defaultdict(int)
    for line in lines:
        vals = [int(i) for i in line.replace("p=", "").replace("v=", "").replace(" ",",").split(",")]
        guards.append(RobotSecurityGuard(x=vals[0], y=vals[1], vx=vals[2], vy=vals[3]))
        guards_by_pos[(vals[0], vals[1])] += 1

    grid_width = 101
    grid_height = 103

    # Tall (correct)
    # START = 1564
    # STEP = 103
    # N_ITERS = 100

    # Wide (not correct)
    START = 74
    STEP = 101
    N_ITERS = 500

    n_steps = START
    for guard in guards:
        guards_by_pos[(guard.x, guard.y)] -= 1
        guard.x = (guard.x + (guard.vx * n_steps)) % grid_width
        guard.y = (guard.y + (guard.vy * n_steps)) % grid_height
        guards_by_pos[(guard.x, guard.y)] += 1

    iters = 0
    with open("solutions/robots/output.txt", "w") as f:
        while True:
            iters += 1
            n_steps += STEP
            for guard in guards:
                guards_by_pos[(guard.x, guard.y)] -= 1
                guard.x = (guard.x + (guard.vx * STEP)) % grid_width
                guard.y = (guard.y + (guard.vy * STEP)) % grid_height
                guards_by_pos[(guard.x, guard.y)] += 1
            buf = ""
            for x in range(grid_width):
                for y in range(grid_height):
                    guards_at_pos = guards_by_pos[(x,y)]
                    if guards_at_pos == 0:
                        buf += "."
                    else:
                        buf += str(guards_at_pos)
                buf += "\n"
            f.write(buf)
            f.write(f"\n{str(n_steps)}\n")
            if iters >= N_ITERS:
                f.close()
                exit()

    quads = [0, 0, 0, 0]
    for guard in guards:
        if guard.x < grid_width // 2:
            if guard.y < grid_height // 2:
                quads[0] += 1
            elif guard.y > grid_height // 2:
                quads[2] += 1
        elif guard.x > grid_width // 2:
            if guard.y < grid_height // 2:
                quads[1] += 1
            elif guard.y > grid_height // 2:
                quads[3] += 1
    return quads[0] * quads[1] * quads[2] * quads[3]
