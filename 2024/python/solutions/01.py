def part_one(lines: list[str]) -> int:
    a1 = []
    a2 = []
    for line in lines:
        i1, i2 = (int(i) for i in line.split())
        a1.append(i1)
        a2.append(i2)

    a1.sort()
    a2.sort()
    return sum(abs(a1[i] - a2[i]) for i in range(len(a1)))

def part_two(lines: list[str]) -> int:
    a1 = []
    a2 = []
    for line in lines:
        i1, i2 = [int(i) for i in line.split()]
        a1.append(i1)
        a2.append(i2)

    a1.sort()
    a2.sort()

    i = 0 # Index in a1
    j = 0 # Index in a2
    simscore = 0 # Running total similarity score
    last_seen = None # If we see a number twice in a1, re-use its score
    last_seen_score = 0

    while i < len(a1):
        ai = a1[i]
        if ai == last_seen:
            simscore += last_seen_score
            i += 1
            continue
        last_seen = ai
        last_seen_score = 0
        while j < len(a2) and a2[j] <= ai:
            if a2[j] == ai:
                simscore += ai
                last_seen_score += ai
            j += 1
        i += 1

    return simscore
