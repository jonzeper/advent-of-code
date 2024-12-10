from collections import defaultdict

def part_one(lines: list[str]) -> int:
    antennae = defaultdict(list) # Antenna signal -> list of locations
    y_bound = len(lines)
    x_bound = len(lines[0])
    for y, line in enumerate(lines):
        for x, c in enumerate(line):
            if c != ".":
                antennae[c].append((y, x))

    antinode_locs = set()
    for c, locs in antennae.items():
        for i in range(len(locs) - 1):
            for j in range(i + 1, len(locs)):
                anode_1, anode_2 = find_antinodes(locs[i], locs[j])
                if anode_1[0] in range(0, y_bound) and anode_1[1] in range(0, x_bound):
                    antinode_locs.add(anode_1)
                if anode_2[0] in range(0, y_bound) and anode_2[1] in range(0, x_bound):
                    antinode_locs.add(anode_2)

    return len(antinode_locs)

def find_antinodes(a, b):
    dy = b[0] - a[0]
    dx = b[1] - a[1]
    a1 = (a[0] - dy, a[1] - dx)
    a2 = (b[0] + dy, b[1] + dx)
    return a1, a2

def part_two(lines: list[str]) -> int:
    antennae = defaultdict(list)
    y_bound = len(lines)
    x_bound = len(lines[0])
    for y, line in enumerate(lines):
        for x, c in enumerate(line):
            if c != ".":
                antennae[c].append((y, x))

    antinode_locs = set()
    for c, locs in antennae.items(): # For each type of antenna
        for i in range(len(locs) - 1): # For each antenna of that type
            for j in range(i + 1, len(locs)): # For each _other_ antenna of that type (excluding already checked)
                for anode in find_antinodes_2(locs[i], locs[j], y_bound, x_bound):
                    antinode_locs.add(anode)

    return len(antinode_locs)

def find_antinodes_2(a, b, y_bound, x_bound):
    dy = b[0] - a[0] # 0
    dx = b[1] - a[1] # 3
    # Antinodes along the path A -> B -> ...
    loc = (a[0], a[1])
    while loc[0] in range(0, y_bound) and loc[1] in range(0, x_bound):
        yield loc
        loc = (loc[0] + dy, loc[1] + dx) # 6 # 9 # 12
    # Antinodes along the path B -> A -> ...
    loc = (b[0], b[1])
    while loc[0] in range(0, y_bound) and loc[1] in range(0, x_bound):
        yield loc
        loc = (loc[0] - dy, loc[1] - dx)
