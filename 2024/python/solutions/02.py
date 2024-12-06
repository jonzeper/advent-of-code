def part_one(lines: list[str]) -> int:
    return len([1 for report in lines if is_safe([int(x) for x in report.split()])])

def is_safe(levels: list[int], except_level: int = None) -> bool:
    if except_level is None:
        return first_unsafe_step(levels) == -1
    return is_safe(levels[0:except_level] + levels[except_level+1:])

def first_unsafe_step(levels: list[int]) -> int:
    if levels[1] > levels[0]:
        direction = 1
    elif levels[1] < levels[0]:
        direction = -1
    else:
        return 0

    last_level = levels[0]
    for i in range(1, len(levels)):
        level = levels[i]
        diff = level - last_level
        if abs(diff) < 1 or abs(diff) > 3 or diff * direction < 0:
            return i
        last_level = level
    return -1


def part_two(lines: list[str]) -> int:
    return len([1 for report in lines if is_safe_2([int(x) for x in report.split()])])


def is_safe_2(levels: list[int]) -> bool:
    unsafe_step = first_unsafe_step(levels)
    if unsafe_step == -1:
        return True # This record is safe without skipping any levels

    # Once we've hit an unsafe step we can try removing it, and nearby steps to see if the record becomes safe
    # No need to go farther than 2 levels back - any farther would not have any impact on our current state
    for lookback in range(3):
        if is_safe(levels, except_level=unsafe_step - lookback):
            return True

    return False
