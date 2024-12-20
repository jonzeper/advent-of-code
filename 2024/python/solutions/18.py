from dataclasses import dataclass
import heapq
from rich import print

RENDER = 0

################################################################################
##                            Part One                                        ##
################################################################################

@dataclass
class Node:
    cost: int = float("inf")
    score: int = float("inf")
    pos: tuple[int] = (0, 0)
    previous: "Node" = None

    def __lt__(self, other: "Node"):
        return self.score < other.score

    def has_in_path(self, pos):
        node = self
        while node.previous is not None:
            if node.previous.pos == pos:
                # print(f"{node.previous.pos=} {pos=}")
                return True
            node = node.previous
        return False

def part_one(lines: list[str]) -> int:
    grid_size = int(lines[0].split(":")[1])
    n_steps = int(lines[1].split(":")[1])
    walls = {(x, y) for x, y in ((int(i) for i in line.split(",")) for line in lines[2:n_steps+2])}

    return fastest_route_through_grid(grid_size, walls)

def fastest_route_through_grid(grid_size, walls):
    exit = (grid_size-1, grid_size-1)
    nodes = {(0, 0): Node(pos=(0, 0), cost=0, score=0)}

    candidates = [nodes[(0, 0)]]
    i = 0
    next_stop = 0
    while len(candidates) > 0:
        node = heapq.heappop(candidates)
        if node.pos == exit:
            continue
        for vec in ((-1, 0), (0, 1), (1, 0), (0, -1)):
            next_pos = (node.pos[0] + vec[0], node.pos[1] + vec[1])
            if -1 in next_pos or grid_size in next_pos:
                continue # Out of bounds
            if next_pos in walls:
                continue # It's a wall

            if next_pos not in nodes:
                nodes[next_pos] = Node(pos=next_pos)
            next_node = nodes[next_pos]
            next_cost = node.cost + 1

            if next_cost < next_node.cost:
                next_node.cost = next_cost
                next_node.score = next_cost + h(grid_size, next_pos)
                next_node.previous = node
                heapq.heappush(candidates, next_node)

        if RENDER and i == next_stop:
            render(grid_size, walls, candidates, node)
            next_stop = i + (int(input() or 0) or 1)
        i += 1

    if exit in nodes:
        return nodes[exit].cost
    else:
        return None


def h(grid_size, pos):
    return (grid_size - pos[0]) + (grid_size - pos[1])

def render(grid_size, walls, candidates, node):
    print("")
    for y in range(grid_size):
        buf = ""
        for x in range(grid_size):
            if (x, y) in walls:
                buf += "#"
            elif node.pos == (x, y):
                buf += "[red]•[/red]"
            elif node.has_in_path((x, y)):
                buf += "[yellow]•[/yellow]"
            else:
                is_candidate = False
                for candidate in candidates:
                    if candidate.pos == (x, y):
                        is_candidate = True
                        break
                if is_candidate:
                    buf += "[green]•[/green]"
                else:
                    buf += "[black] [/black]"
        print(buf)


################################################################################
##                            Part Two                                        ##
################################################################################

def part_two(lines: list[str]) -> int:
    grid_size = int(lines[0].split(":")[1])
    n_steps = int(lines[1].split(":")[1])
    walls = [(x, y) for x, y in ((int(i) for i in line.split(",")) for line in lines[2:])]
    max_steps = len(walls)

    bisectable_range = range(n_steps, max_steps)

    while len(bisectable_range) > 0:
        candidate = bisectable_range[len(bisectable_range) // 2]
        if fastest_route_through_grid(grid_size, walls[:candidate]):
            bisectable_range = range(candidate, max(bisectable_range))
        else:
            bisectable_range = range(min(bisectable_range), candidate+1)

    return ",".join(str(i) for i in walls[candidate])
