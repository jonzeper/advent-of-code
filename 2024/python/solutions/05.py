from collections import defaultdict

def part_one_prep(lines: list[str]) -> list[int]:
    page_order_rules = []
    page_updates = []
    for line in lines:
        if "|" in line:
            page_order_rules.append(line.split("|"))
        else:
            page_updates.append(line.split(","))
    return (page_order_rules, page_updates)

def part_one(params: tuple[list[list[int]]]) -> int:
    rules, updates = params

    invalid_after = defaultdict(set)
    for (a, b) in rules:
        invalid_after[b].add(a)

    sum = 0
    for update in updates:
        blockers = set()
        valid = True
        for page in update:
            if page in blockers:
                valid = False
                break
            blockers = blockers | invalid_after[page]
        if valid:
            sum += int(update[len(update) // 2])
    return sum

def part_two_prep(lines: list[str]) -> list[int]:
    page_order_rules = []
    page_updates = []
    for line in lines:
        if "|" in line:
            page_order_rules.append(line.split("|"))
        else:
            page_updates.append(line.split(","))
    return (page_order_rules, page_updates)

def part_two(params: tuple[list[list[int]]]) -> int:
    rules, updates = params

    invalid_after = defaultdict(set)
    for (a, b) in rules:
        invalid_after[b].add(a)

    sum = 0
    for update in updates:
        ordered_pages = []
        was_invalid = False
        for page in update:
            # Find the first ordered page which we would be invalid after. Then add before that
            i = 0
            while i < len(ordered_pages) and page not in invalid_after[ordered_pages[i]]:
                i += 1
            if i != len(ordered_pages):
                was_invalid = True
            ordered_pages.insert(i, page)
        if was_invalid:
            sum += int(ordered_pages[len(ordered_pages) // 2])
    return sum
