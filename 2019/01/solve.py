from math import floor

def fuel_req(module_size):
  fuel = floor(module_size / 3) - 2
  if fuel > 0:
    return fuel + fuel_req(fuel)
  else:
    return 0

total = 0
with open("input.txt") as fp:
  for line in fp:
    total += fuel_req(int(line))

print(total)
