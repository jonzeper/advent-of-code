use aoc::AocResult;
use std::collections::HashMap;

type RegisterId = char;
type Value = i64;

#[derive(Debug)]
enum Instruction {
  Halve(RegisterId),
  Triple(RegisterId),
  Increment(RegisterId),
  Jump(Value),
  JumpIfEven(RegisterId, Value),
  JumpIfOne(RegisterId, Value),
}

impl Instruction {
  fn from_line(line: &String) -> Self {
    let command = &line[0..3];
    let rest = &line[4..];
    match command {
      "hlf" => Instruction::Halve(rest.parse().unwrap()),
      "tpl" => Instruction::Triple(rest.parse().unwrap()),
      "inc" => Instruction::Increment(rest.parse().unwrap()),
      "jmp" => Instruction::Jump(rest.parse().unwrap()),
      "jie" => {
        let mut split = rest.split(", ");
        let register: RegisterId = split.next().unwrap().parse().unwrap();
        let offset: Value = split.next().unwrap().parse().unwrap();
        Instruction::JumpIfEven(register, offset)
      }
      "jio" => {
        let mut split = rest.split(", ");
        let register: RegisterId = split.next().unwrap().parse().unwrap();
        let offset: Value = split.next().unwrap().parse().unwrap();
        Instruction::JumpIfOne(register, offset)
      }
      _ => unimplemented!(),
    }
  }
}

#[derive(Debug)]
struct Computer {
  registers: HashMap<RegisterId, Value>,
  instructions: Vec<Instruction>,
  current: Value,
}

impl Computer {
  fn new(instructions: Vec<Instruction>, initial_a: Value) -> Self {
    let mut computer = Computer {
      registers: HashMap::new(),
      instructions: instructions,
      current: 0,
    };
    computer.registers.insert('a', initial_a);
    computer.registers.insert('b', 0);
    computer
  }

  fn set_reg(&mut self, reg: RegisterId, val: Value) {
    self.registers.insert(reg, val);
  }

  fn get_reg(&self, reg: RegisterId) -> Value {
    *self.registers.get(&reg).unwrap()
  }

  fn step(&mut self) {
    match self.instructions[self.current as usize] {
      Instruction::Halve(reg) => {
        self.set_reg(reg, self.get_reg(reg) / 2);
        self.current += 1;
      }
      Instruction::Triple(reg) => {
        self.set_reg(reg, self.get_reg(reg) * 3);
        self.current += 1;
      }
      Instruction::Increment(reg) => {
        self.set_reg(reg, self.get_reg(reg) + 1);
        self.current += 1;
      }
      Instruction::Jump(offset) => {
        self.current += offset;
      }
      Instruction::JumpIfEven(reg, offset) => {
        if self.get_reg(reg) % 2 == 0 {
          self.current += offset;
        } else {
          self.current += 1;
        }
      }
      Instruction::JumpIfOne(reg, offset) => {
        if self.get_reg(reg) == 1 {
          self.current += offset;
        } else {
          self.current += 1;
        }
      }
    }
  }

  fn run(&mut self) {
    while self.current >= 0 && self.current < self.instructions.len() as Value {
      self.step();
    }
  }
}

fn part_one(lines: &Vec<String>) -> AocResult {
  let instructions: Vec<Instruction> = lines.iter().map(Instruction::from_line).collect();
  let mut computer = Computer::new(instructions, 0);
  computer.run();
  AocResult::Number(*computer.registers.get(&'b').unwrap() as i64)
}

fn part_two(lines: &Vec<String>) -> AocResult {
  let instructions: Vec<Instruction> = lines.iter().map(Instruction::from_line).collect();
  let mut computer = Computer::new(instructions, 1);
  computer.run();
  AocResult::Number(*computer.registers.get(&'b').unwrap() as i64)
}

pub fn main() {
  aoc::run(2015, 23, 1, part_one);
  aoc::run(2015, 23, 2, part_two);
}
