use aoc::AocResult;
use std::collections::HashMap;

type World = HashMap<(i64, i64), i64>;

struct Santa {
  x: i64,
  y: i64,
}
impl Santa {
  fn new() -> Self {
    Santa { x: 0, y: 0 }
  }

  fn move_self(&mut self, c: char) {
    let (x, y) = match c {
      '^' => (self.x, self.y - 1),
      'v' => (self.x, self.y + 1),
      '<' => (self.x - 1, self.y),
      '>' => (self.x + 1, self.y),
      _ => (self.x, self.y),
    };
    self.x = x;
    self.y = y;
  }
}

fn part_one(lines: &Vec<String>) -> AocResult {
  let mut s = Santa::new();
  let mut w = World::new();

  w.insert((s.x, s.y), 1);
  for c in lines[0].chars() {
    s.move_self(c);
    w.insert((s.x, s.y), 1);
  }
  return AocResult::Number(w.values().sum::<i64>());
}

fn part_two(lines: &Vec<String>) -> AocResult {
  let n_santas = 2;
  let mut w = World::new();

  // NOTE: Had tried cycling over a Vec<Santa>, but cycle is concerned about the
  // possibility of referencing the same value multiple times if we were to, say,
  // .take(5).collect(). This explains better: https://users.rust-lang.org/t/unable-to-iter-mut-cycle/35067
  let mut santas: HashMap<i64, Santa> = HashMap::new();
  for i in 0..n_santas {
    santas.insert(i, Santa::new());
  }
  let mut santa_cycle = (0..n_santas).cycle();

  w.insert((0, 0), 1);
  for c in lines[0].chars() {
    let santa_id = santa_cycle.next().expect("No santas found!");
    let s = santas.get_mut(&santa_id).expect("Santa not found!");
    s.move_self(c);
    w.insert((s.x, s.y), 1);
  }
  return AocResult::Number(w.values().sum::<i64>());
}

fn main() {
  aoc::run(2015, 3, 1, part_one);
  aoc::run(2015, 3, 2, part_two);
}
