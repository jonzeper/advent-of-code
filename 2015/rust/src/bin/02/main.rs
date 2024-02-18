use aoc::AocResult;

struct Present {
  l: i64,
  w: i64,
  h: i64,
}

impl Present {
  fn new(line: &String) -> Self {
    let split: Vec<i64> = line
      .split('x')
      .map(|c| str::parse::<i64>(c).expect("Expected a number"))
      .collect();
    Present {
      l: split[0],
      w: split[1],
      h: split[2],
    }
  }

  fn surface_area(&self) -> i64 {
    return self.l * self.w * 2 + self.w * self.h * 2 + self.l * self.h * 2;
  }

  fn paper_needed(&self) -> i64 {
    let sides: Vec<i64> = vec![self.l * self.w, self.w * self.h, self.l * self.h];
    let min: &i64 = sides.iter().min().expect("Unable to find min");
    return min + self.surface_area();
  }

  fn ribbon_needed(&self) -> i64 {
    let volume = self.l * self.w * self.h;
    let sides: Vec<i64> = vec![self.l, self.w, self.h];
    let ribbon = self.l * 2 + self.w * 2 + self.h * 2 - (sides.iter().max().unwrap() * 2);
    return volume + ribbon;
  }
}

fn part_one(lines: &Vec<String>) -> AocResult {
  let presents: Vec<Present> = load_presents(lines);
  return AocResult::Number(presents.iter().map(Present::paper_needed).sum());
}

fn part_two(lines: &Vec<String>) -> AocResult {
  let presents: Vec<Present> = load_presents(lines);
  return AocResult::Number(presents.iter().map(Present::ribbon_needed).sum());
}

fn load_presents(lines: &Vec<String>) -> Vec<Present> {
  return lines.iter().map(|s| Present::new(s)).collect();
}

fn main() {
  aoc::run(2015, 2, 1, part_one);
  aoc::run(2015, 2, 2, part_two);
}

#[cfg(test)]
mod tests {
  use super::*;
  #[test]
  fn surface_area() {
    let p1 = Present { l: 2, w: 3, h: 4 };
    let p2 = Present { l: 1, w: 1, h: 10 };

    assert_eq!(p1.surface_area(), 52);
    assert_eq!(p2.surface_area(), 42);
  }

  #[test]
  fn paper_needed() {
    let p1 = Present { l: 2, w: 3, h: 4 };
    let p2 = Present { l: 1, w: 1, h: 10 };

    assert_eq!(p1.paper_needed(), 58);
    assert_eq!(p2.paper_needed(), 43);
  }
}
