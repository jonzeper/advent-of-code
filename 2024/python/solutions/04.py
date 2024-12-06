def part_one(lines: list[str]) -> int:
    xmas_count = 0
    for y in range(len(lines)):
        line = lines[y]
        for x in range(len(line)):
            if line[x] == "X":
                for x_dir in (-1, 0, 1):
                    for y_dir in (-1, 0, 1):
                        xmas_count += count_xmases_from(lines, x, y, x_dir, y_dir)
    return xmas_count

def count_xmases_from(lines: list[str], x: int, y: int, x_dir: int, y_dir: int) -> int:
    if x + (x_dir * 3) < 0 or x + (x_dir * 3) >= len(lines[y]) or y + (y_dir * 3) < 0 or y + (y_dir * 3) >= len(lines):
        return 0
    s = ""
    for i in (1, 2, 3):
        s += lines[y + (y_dir * i)][x + (x_dir * i)]
    if s == "MAS":
        return 1
    return 0

def part_two(lines: list[str]) -> int:
    xmas_count = 0
    for y in range(len(lines)):
        line = lines[y]
        for x in range(len(line)):
            if line[x] == "A":
                if is_xmas(lines, x, y):
                    xmas_count += 1
    return xmas_count

def is_xmas(lines: list[str], x: int, y: int) -> bool:
    if x == 0 or y == 0 or x == len(lines[y]) - 1 or y == len(lines) - 1:
        return False
    if (lines[y-1][x-1] == "M" and lines[y+1][x+1] == "S" or lines[y-1][x-1] == "S" and lines[y+1][x+1] == "M") and (lines[y-1][x+1] == "M" and lines[y+1][x-1] == "S" or lines[y-1][x+1] == "S" and lines[y+1][x-1] == "M"):
        return True
    return False
