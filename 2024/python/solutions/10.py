from collections import namedtuple

Point = namedtuple("Point", ["row", "col"])

class Grid:
    trailheads: set[Point]

    def __init__(self, lines: list[str]):
        self.trailheads = set()
        self.grid = [[0 for _ in range(len(lines[0]))] for _ in range(len(lines))]
        for row, line in enumerate(lines):
            for col, c in enumerate(line):
                if c == "0":
                    self.trailheads.add(Point(row, col))
                self.grid[row][col] = int(c)

    def __getitem__(self, row: int) -> list[int]:
        return self.grid[row]

    def neighbors(self, loc: Point) -> set[Point]:
        neighbors = {
            Point(loc.row - 1, loc.col),
            Point(loc.row + 1, loc.col),
            Point(loc.row, loc.col - 1),
            Point(loc.row, loc.col + 1)
        }
        return {n for n in neighbors if self.in_bounds(n)}

    def in_bounds(self, loc: Point) -> bool:
        return loc.row in range(0, len(self.grid)) and loc.col in range(0, len(self.grid[0]))

################################################################################
##                            Part One                                        ##
################################################################################

def part_one(lines: list[str]) -> int:
    grid = Grid(lines)
    return sum((trailhead_score(grid, trailhead) for trailhead in grid.trailheads))

def trailhead_score(grid: Grid, trailhead_loc: Point) -> int:
    return len(trailends_reachable_from(grid, {trailhead_loc}, set()))

def trailends_reachable_from(grid: Grid, locs: set[Point], reached: set[Point]) -> set[Point]:
    loc = locs.pop()
    val = grid[loc.row][loc.col]
    if val == 9:
        reached.add(loc)
    else:
        locs = locs | {n for n in grid.neighbors(loc) if grid[n.row][n.col] == val + 1}
    if len(locs) == 0:
        return reached
    else:
        return trailends_reachable_from(grid, locs, reached)

################################################################################
##                            Part Two                                        ##
################################################################################

def part_two(lines: list[str]) -> int:
    grid = Grid(lines)
    return sum((trailhead_rating(grid, trailhead) for trailhead in grid.trailheads))

def trailhead_rating(grid: Grid, trailhead_loc: Point) -> int:
    return count_paths(grid, [trailhead_loc], 0)

# TODO: optimization: Save known ratings and avoid re-walking known routes
def count_paths(grid: Grid, locs: list[Point], n_paths: int) -> int:
    loc = locs.pop()
    val = grid[loc.row][loc.col]
    if val == 9:
        n_paths += 1
    else:
        # Any neighbor which is one step up from the current location gets pushed onto the exploration queue
        locs = locs + [n for n in grid.neighbors(loc) if grid[n.row][n.col] == val + 1]
    if len(locs) == 0:
        return n_paths
    else:
        return count_paths(grid, locs, n_paths)
