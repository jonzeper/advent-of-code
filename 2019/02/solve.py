class Solver:
  def __init__(self):
    file = open("input.txt")
    self.baseInstructions = [int(x) for x in file.readline().strip().split(",")]

  def valueOf(self, position):
    return self.instructions[self.instructions[position]]

  def solve(self, noun, verb):
    self.instructions = self.baseInstructions.copy()
    self.position = 0
    self.instructions[1] = noun
    self.instructions[2] = verb
    instruction = self.instructions[self.position]
    while instruction != 99:
      self.iterate(instruction)
      instruction = self.instructions[self.position]
    return self.instructions[0]

  def iterate(self, instruction):
    pos = self.position
    dst = self.instructions[pos + 3]
    if instruction == 1:
      val = self.valueOf(pos + 1) + self.valueOf(pos + 2)
    elif instruction == 2:
      val = self.valueOf(pos + 1) * self.valueOf(pos + 2)
    self.instructions[dst] = val
    self.position += 4

solver = Solver()
# print(solver.solve(12,2))

for i in range(99):
  for j in range(99):
    if solver.solve(i,j) == 19690720:
      print(f'{i},{j}')
