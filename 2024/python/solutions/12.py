from dataclasses import dataclass, field
from collections import defaultdict

@dataclass
class Region:
    area: int = 0
    perimeter: int = 0
    edge_locs: dict[tuple, list[tuple]] = field(default_factory=lambda: defaultdict(list)) # side -> straight pos -> [var pos]
    c: str = ""

    def count_edges(self):
        edge_count = 0
        for edge_points in self.edge_locs.values():
            edge_long_side_pos = -1
            edge_points.sort()
            for loc in edge_points:
                if loc[0] != edge_long_side_pos:
                    edge_long_side_pos = loc[0]
                    cur_x = -2
                if loc[1] != cur_x + 1:
                    edge_count += 1
                cur_x = loc[1]
        return edge_count

class Point:
    val: str
    region: Region | None
    visited: bool

    def __init__(self, val, region=None):
        self.val = val
        self.region = region
        self.visited = False

################################################################################
##                            Part One                                        ##
################################################################################


def part_one(lines: list[str]) -> int:
    grid = [[Point(c) for c in line] for line in lines]

    regions = []

    current_region = None
    todo_in_region = set()
    todo_outside_region = {(0, 0)}
    while len(todo_in_region) > 0 or len(todo_outside_region) > 0:
        if len(todo_in_region):
            row, col = todo_in_region.pop()
            point = grid[row][col]
            if point.visited:
                continue
        else:
            row, col = todo_outside_region.pop()
            point = grid[row][col]
            if point.visited:
                continue
            current_region = Region()
            regions.append(current_region)

        point.visited = True
        current_region.c = point.val
        current_region.area += 1
        current_region.perimeter += 4

        neighbors_in_region = set()
        neighbors_outside_region = set()
        for dy, dx in ((-1, 0), (0, 1), (1, 0), (0, -1)):
            neighbor_row = row + dy
            neighbor_col = col + dx
            if neighbor_row in range(0, len(lines)) and neighbor_col in range(0, len(lines[0])):
                neighbor_point = grid[neighbor_row][neighbor_col]
                if neighbor_point.val == point.val:
                    current_region.perimeter -= 1
                    if not neighbor_point.visited:
                        neighbors_in_region.add((neighbor_row, neighbor_col))
                elif not neighbor_point.visited:
                    neighbors_outside_region.add((neighbor_row, neighbor_col))



        todo_in_region |= neighbors_in_region
        todo_outside_region |= neighbors_outside_region

    return sum((r.perimeter * r.area for r in regions))



################################################################################
##                            Part Two                                        ##
################################################################################

def part_two(lines: list[str]) -> int:
    grid = [[Point(c) for c in line] for line in lines]

    regions = []

    # Keep a list of points to visit. We want to fully explore each region before moving onto another, so keep separate
    # lists for points in-region and out. Fully exploring the current region helps avoid visiting the same region twice
    # and mistaking it as two separate regions instead of one.
    todo_in_region = set()
    todo_outside_region = {(0, 0)} # We'll start by visiting (0,0)

    current_region = None
    while len(todo_in_region) > 0 or len(todo_outside_region) > 0:

        # Try to visit another point in the current region. If already visited, skip
        if len(todo_in_region):
            row, col = todo_in_region.pop()
            point = grid[row][col]
            if point.visited:
                continue
        # If no points left in the current region, start another.
        else:
            row, col = todo_outside_region.pop()
            point = grid[row][col]
            if point.visited:
                continue
            current_region = Region()
            regions.append(current_region)

        point.visited = True
        current_region.area += 1

        neighbors_in_region = set()
        neighbors_outside_region = set()
        # Take a peek at each neighboring point
        for dy, dx in ((-1, 0), (0, 1), (1, 0), (0, -1)):
            neighbor_row = row + dy
            neighbor_col = col + dx
            if neighbor_row in range(0, len(lines)) and neighbor_col in range(0, len(lines[0])):
                neighbor_point = grid[neighbor_row][neighbor_col]
                if neighbor_point.val == point.val:
                    if not neighbor_point.visited:
                        neighbors_in_region.add((neighbor_row, neighbor_col))
                else:
                    # This neighbor is in a different region, so the current point is an edge in this direction.
                    add_edge_point(current_region, dy, dx, row, col)
                    if not neighbor_point.visited:
                        neighbors_outside_region.add((neighbor_row, neighbor_col))
            else:
                # This neighbor is out of bounds, so the current point is an edge in this direction.
                add_edge_point(current_region, dy, dx, row, col)

        todo_in_region |= neighbors_in_region
        todo_outside_region |= neighbors_outside_region

    return sum((r.count_edges() * r.area for r in regions))

def add_edge_point(region: Region, dy, dx, row, col):
    # Flipping row and col for vertical edges. If not, we'd have to have two versions of the edge counting function.
    # Simpler to just flip here.
    if dx == 0:
        region.edge_locs[(dy, dx)].append((row, col))
    else:
        region.edge_locs[(dy, dx)].append((col, row))
