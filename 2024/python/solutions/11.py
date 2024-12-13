from collections import defaultdict
from math import ceil, log10

################################################################################
##                            Part One                                        ##
################################################################################

precalced_rock_counts = {}
for i in range(10):
    precalced_rock_counts[i] = []

# Precalcuate number of rocks resulting from blinking at a one-digit rock N times
precalced_rock_counts[0] = [1, 1, 1, 2, 4, 4, 7, 14, 16, 20, 39, 62, 81, 110, 200, 328, 418, 667, 1059, 1546, 2377, 3572, 5602, 8268, 12343, 19778, 29165, 43726, 67724, 102131, 156451, 234511, 357632, 549949, 819967, 1258125, 1916299, 2886408, 4414216, ]
precalced_rock_counts[1] = [1, 1, 2, 4, 4, 7, 14, 16, 20, 39, 62, 81, 110, 200, 328, 418, 667, 1059, 1546, 2377, 3572, 5602, 8268, 12343, 19778, 29165, 43726, 67724, 102131, 156451, 234511, 357632, 549949, 819967, 1258125, 1916299, 2886408, 4414216, 6669768, ]
precalced_rock_counts[2] = [1, 1, 2, 4, 4, 6, 12, 16, 19, 30, 57, 92, 111, 181, 295, 414, 661, 977, 1501, 2270, 3381, 5463, 7921, 11819, 18712, 27842, 42646, 64275, 97328, 150678, 223730, 343711, 525238, 784952, 1208065, 1824910, 2774273, 4230422, 6365293, ]
precalced_rock_counts[3] = [1, 1, 2, 4, 4, 5, 10, 16, 26, 35, 52, 79, 114, 202, 294, 401, 642, 987, 1556, 2281, 3347, 5360, 7914, 12116, 18714, 27569, 42628, 64379, 98160, 150493, 223231, 344595, 524150, 788590, 1210782, 1821382, 2779243, 4230598, 6382031, ]
precalced_rock_counts[4] = [1, 1, 2, 4, 4, 4, 8, 16, 27, 30, 47, 82, 115, 195, 269, 390, 637, 951, 1541, 2182, 3204, 5280, 7721, 11820, 17957, 26669, 41994, 62235, 95252, 146462, 216056, 336192, 508191, 766555, 1178119, 1761823, 2709433, 4110895, 6188994, ]
precalced_rock_counts[5] = [1, 1, 1, 2, 4, 8, 8, 11, 22, 32, 45, 67, 109, 163, 223, 383, 597, 808, 1260, 1976, 3053, 4529, 6675, 10627, 15847, 23822, 37090, 55161, 84208, 128121, 194545, 298191, 444839, 681805, 1042629, 1565585, 2396146, 3626619, 5509999, ]
precalced_rock_counts[6] = [1, 1, 1, 2, 4, 8, 8, 11, 22, 32, 54, 68, 103, 183, 250, 401, 600, 871, 1431, 2033, 3193, 4917, 7052, 11371, 16815, 25469, 39648, 57976, 90871, 136703, 205157, 319620, 473117, 727905, 1110359, 1661899, 2567855, 3849988, 5866379, ]
precalced_rock_counts[7] = [1, 1, 1, 2, 4, 8, 8, 11, 22, 32, 52, 72, 106, 168, 242, 413, 602, 832, 1369, 2065, 3165, 4762, 6994, 11170, 16509, 25071, 39034, 57254, 88672, 134638, 203252, 312940, 465395, 716437, 1092207, 1637097, 2519878, 3794783, 5771904, ]
precalced_rock_counts[8] = [1, 1, 1, 2, 4, 7, 7, 11, 22, 31, 48, 69, 103, 161, 239, 393, 578, 812, 1322, 2011, 3034, 4580, 6798, 10738, 16018, 24212, 37525, 55534, 85483, 130183, 196389, 301170, 450896, 691214, 1054217, 1583522, 2428413, 3669747, 5573490, ]
precalced_rock_counts[9] = [1, 1, 1, 2, 4, 8, 8, 11, 22, 32, 54, 70, 103, 183, 262, 419, 586, 854, 1468, 2131, 3216, 4888, 7217, 11617, 17059, 25793, 40124, 58820, 92114, 139174, 208558, 322818, 480178, 740365, 1126352, 1685448, 2602817, 3910494, 5953715, ]

def part_one(lines: list[str]) -> int:
    rocks = [int(i) for i in lines[0].split()]
    new_rocks, rock_count = blink_list_recurse(rocks, 25, 0)
    return len(new_rocks) + rock_count

output_buffer = ""
def blink_list_recurse(rocks: list[int], remaining_blinks: int, condensed_rocks: int, do_output: bool = False):
    if do_output:
        global output_buffer
        output_buffer += f"{len(rocks) + condensed_rocks}, "
    if remaining_blinks == 0:
        return (rocks, condensed_rocks)
    else:
        new_rocks = []
        for rock_num in rocks:
            if rock_num < 10 and remaining_blinks < len(precalced_rock_counts[rock_num]):
                condensed_rocks += precalced_rock_counts[rock_num][remaining_blinks]
            else:
                new_rocks += blink(rock_num)
        return blink_list_recurse(new_rocks, remaining_blinks-1, condensed_rocks, do_output=do_output)

def blink_list(l: list[int]) -> list[int]:
    new_l = []
    for i in l:
        new_l += blink(i)
    return new_l



def blink(i: int) -> list[int]:
    if i == 0:
        return [1]
    n_digits = ceil(log10(i+1))
    if n_digits % 2 == 0:
        right_side = i % (10 ** (n_digits // 2))
        left_side = (i - right_side) // (10 ** (n_digits // 2))
        return [left_side, right_side]
    else:
        return [i * 2024]

def precalculate_blink_results(rock_start_n: int, n_blinks: int) -> dict[int, list[int]]:
    blink_results = {}
    rock_counts = defaultdict(list)
    new_rocks, new_rock_count = blink_list_recurse([rock_start_n], n_blinks, 0, do_output=True)
    blink_results[rock_start_n] = new_rocks
    rock_counts[rock_start_n].append(new_rock_count)
    return rock_counts

# for i in range(10):
#     output_buffer = f"precalced_rock_counts[{i}] = ["
#     precalculate_blink_results(i, 38)
#     print(output_buffer + "]")
# exit()


################################################################################
##                            Part Two                                        ##
################################################################################

def part_two(lines: list[str]) -> int:
    l = [int(i) for i in lines[0].split()]
    new_l, rock_count = blink_list_recurse(l, 75, 0)
    return len(new_l) + rock_count
    # return 1
