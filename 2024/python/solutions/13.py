from dataclasses import dataclass
from itertools import batched
from collections import namedtuple
from math import sqrt, ceil, floor

import decimal
decimal.getcontext().prec = 50

Decimal = decimal.Decimal

A_COST = 3
B_COST = 1
DEBUG=0
@dataclass
class ClawMachine:
    ax: int
    ay: int
    bx: int
    by: int
    prize_x: int
    prize_y: int
    multiplier: int = 1 # For part two

    def valid_a_presses_for_prize_x(self):
        a_presses = 0
        required_bx = self.prize_x
        while required_bx >= 0 and a_presses < 100:
            if required_bx % self.bx == 0:
                # print(f"{a_presses=} valid for x")
                yield a_presses
            a_presses += 1
            required_bx = (self.prize_x - (self.ax * a_presses))
            # print(f"{a_presses=} {required_bx=}")

    def valid_combos(self):
        for a_presses in self.valid_a_presses_for_prize_x():
            b_presses = (self.prize_x - (a_presses * self.ax)) // self.bx
            if a_presses * self.ay + b_presses * self.by == self.prize_y:
                debug(f"{(a_presses, b_presses)=}")
                yield (a_presses, b_presses)

    def min_cost(self):
        costs = [presses[0] * A_COST + presses[1] * B_COST for presses in self.valid_combos()]
        if len(costs) == 0:
            return 0
        else:
            return min(costs) * self.multiplier



################################################################################
##                            Part One                                        ##
################################################################################

def part_one(lines: list[str]) -> int:
    lines = (line for line in lines if line != "")
    machines = []
    for aspec, bspec, prizespec in batched(lines, 3):
        ax = int(aspec.split("+")[1].split(",")[0])
        ay = int(aspec.split("+")[2])
        bx = int(bspec.split("+")[1].split(",")[0])
        by = int(bspec.split("+")[2])
        prize_x = int(prizespec.split("=")[1].split(",")[0])
        prize_y = int(prizespec.split("=")[2])
        machines.append(ClawMachine(ax, ay, bx, by, prize_x, prize_y))
    return sum(machine.min_cost() for machine in machines)

################################################################################
##                            Part Two                                        ##
################################################################################

Vector = namedtuple("Vector", ["x", "y"])

@dataclass
class ClawMachine2:
    avec: Vector
    bvec: Vector
    prize: Vector


def part_two(lines: list[str]) -> int:
    lines = (line for line in lines if line != "")
    machines: list[ClawMachine2] = []
    for aspec, bspec, prizespec in batched(lines, 3):
        ax = int(aspec.split("+")[1].split(",")[0])
        ay = int(aspec.split("+")[2])
        bx = int(bspec.split("+")[1].split(",")[0])
        by = int(bspec.split("+")[2])
        prize_x = int(prizespec.split("=")[1].split(",")[0]) + 10000000000000
        prize_y = int(prizespec.split("=")[2]) + 10000000000000
        machines.append(ClawMachine2(Vector(ax, ay), Vector(bx, by), Vector(prize_x, prize_y)))
    return sum(best_cost(m) for m in machines)

def best_cost(m: ClawMachine2):
    return min(valid_costs(m))

def valid_costs(m: ClawMachine2):
    debug("="*80+"\n")
    debug(f"{m=}")
    valid_costs = set()

    for avec, bvec, acost, bcost in ((m.avec, m.bvec, A_COST, B_COST), (m.bvec, m.avec, B_COST, A_COST)):

        debug("")
        debug("Determining maximum A presses")
        max_a_presses = min(m.prize.x // avec.x, m.prize.y // avec.y)
        b_presses, landing = b_presses_and_landing(m.prize, avec, bvec, max_a_presses, rounded=False)
        dist = distance(landing, m.prize)
        debug(f"{max_a_presses=} {b_presses=} {landing=} {dist=}")

        if dist == 0:
            valid_costs.add(max_a_presses * acost + b_presses * bcost)
            continue

        # Figure out distance delta per A press
        debug("")
        debug("Pressing A one less time")
        b_presses, landing = b_presses_and_landing(m.prize, avec, bvec, max_a_presses-1, rounded=False)
        delta = dist - distance(landing, m.prize)
        debug(f"{b_presses=} {landing=} {dist=} {delta=}")
        debug(f"Each one less A press, allows us to get {delta} closer")
        if delta == 0:
            continue
        debug(f"{dist / delta=}")

        # Given that delta-per-A-press, we can estimate how many times we should press A
        # Since we can't press a fractional number of times, let's overestimate (by using floor)
        # and then we'll work backwards from there.
        est_a_presses = max_a_presses - floor(dist / delta)
        debug(f"To close the gap of {dist}, we should press A {est_a_presses} times ({max_a_presses - est_a_presses} fewer than max)")

        # See where we're at after pressing A the estimated number of times
        debug("")
        debug(f"Pressing A {est_a_presses} times")
        b_presses, landing = b_presses_and_landing(m.prize, avec, bvec, est_a_presses, rounded=True)
        dist = distance(landing, m.prize)
        debug(f"{est_a_presses=} {b_presses=} {landing=} {dist=}")

        # Since we're overestimating, we may be past the target point.
        # As long as we are getting closer by reducing the number of A presses, let's keep trying one fewer A press until
        # we get it (or find that we can't get it). It shouldn't take more than a couple tries to figure it out.
        last_dist = float("inf")
        while dist != 0 and dist < last_dist:
            last_dist = dist
            est_a_presses -= 1
            b_presses, landing = b_presses_and_landing(m.prize, avec, bvec, est_a_presses)
            delta = dist - distance(landing, m.prize)
            dist = distance(landing, m.prize)
            debug(f"* {est_a_presses=} {b_presses=} {dist=} {last_dist=} {delta=}")
            if DEBUG:
                input()

        if dist == 0:
            debug(f" Good: {est_a_presses=} {b_presses=}")
            valid_costs.add(est_a_presses * acost + b_presses * bcost)
        else:
            debug(" Bad")
    if DEBUG:
        input()

    # print(m, valid_costs)
    if len(valid_costs) == 0:
        return [0]
    return valid_costs

def b_presses_and_landing(prize: Vector, avec: Vector, bvec: Vector, a_presses, rounded=True):
    if rounded:
        b_presses = min((prize.x - a_presses * avec.x) // bvec.x, (prize.y - a_presses * avec.y) // bvec.y)
    else:
        b_presses = min(Decimal(prize.x - a_presses * avec.x) / bvec.x, Decimal(prize.y - a_presses * avec.y) / bvec.y)
    landing_x = avec.x * a_presses + bvec.x * b_presses
    landing_y = avec.y * a_presses + bvec.y * b_presses
    return b_presses, Vector(landing_x, landing_y)

def distance(a: Vector, b: Vector, rounded=False):
    return Decimal((b.x - a.x) ** 2 + (b.y - a.y) ** 2).sqrt()
    return sqrt((b.x - a.x) ** 2 + (b.y - a.y) ** 2)
    # return (b.x - a.x) + (b.y - a.y)



# print(gcd(1071, 462))
# exit()
# def gcd(a: int, b: int) -> int:
#     while a != b:
#         if a > b:
#             a = a - b * (a // b)
#             if a == 0:
#                 return b
#         else:
#             b = b - a * (b // a)
#             if b == 0:
#                 return a
#     return a
"""
Button A: X+94, Y+34
Button B: X+22, Y+67
Prize: X=8400, Y=5400


Pushing the machine's A button would move the claw 94 units along the X axis and 34 units along the Y axis.
Pushing the B button would move the claw 22 units along the X axis and 67 units along the Y axis.
The prize is located at X=8400, Y=5400;
    this means that from the claw's initial position, it would need to move exactly 8400 units along the X axis and exactly 5400 units along the Y axis
    to be perfectly aligned with the prize in this machine.

The cheapest way to win the prize is by pushing the A button 80 times and the B button 40 times.
This would line up the claw along the X axis (because 80*94 + 40*22 = 8400) and along the Y axis (because 80*34 + 40*67 = 5400).
Doing this would cost 80*3 tokens for the A presses and 40*1 for the B presses, a total of 280 tokens.

94a + 22b = 8400
34a + 67b = 5400







"""

def debug(s):
    if DEBUG:
        print(s)
