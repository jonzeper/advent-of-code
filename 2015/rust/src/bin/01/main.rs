use aoc::AocResult;

struct Santa {
  floor: i64,
}

impl Santa {
  pub fn new() -> Self {
    Santa { floor: 0 }
  }

  pub fn move_floor(&mut self, c: char) {
    if c == '(' {
      self.floor += 1;
    } else {
      self.floor -= 1;
    }
  }

  pub fn is_in_basement(&self) -> bool {
    return self.floor == -1;
  }
}

fn part_one(lines: &Vec<String>) -> AocResult {
  let mut santa = Santa::new();
  for c in lines[0].chars() {
    santa.move_floor(c);
  }
  return AocResult::Number(santa.floor);
}

fn part_two(lines: &Vec<String>) -> AocResult {
  let mut santa = Santa::new();
  for (i, c) in lines[0].chars().enumerate() {
    santa.move_floor(c);
    if santa.is_in_basement() {
      return AocResult::Number((i + 1) as i64);
    }
  }
  return AocResult::Number(0);
}

fn main() {
  aoc::run(2015, 1, 1, part_one);
  aoc::run(2015, 1, 2, part_two);
}

mod tests {
  #[test]
  fn starts_at_floor_0() {
    use super::*;
    let s: Santa = Santa::new();
    assert_eq!(s.floor, 0);
  }
}
