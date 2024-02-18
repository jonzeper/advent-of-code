use aoc::AocResult;

fn presents_for_house(house: i64, first_elf: &i64, part_two: bool) -> i64 {
  let presents_per_elf: i64 = if part_two { 11 } else { 10 };
  // println!("House: {}", house);
  let mut presents: i64 = 0;
  if !part_two || house <= 50 {
    presents = presents_per_elf + house * presents_per_elf;
  }
  // println!("  base: {}", presents);
  let mut step: i64 = 1;
  let mut start: i64 = 2;
  if part_two {
    start = *first_elf;
  } else {
    for i in 2..100 {
      if house % i != 0 {
        step += 1;
        start += 1;
      } else {
        break;
      }
    }
  }

  let mut upper_bound = house / 2;
  let mut i = start;
  let mut co: i64;
  while i <= upper_bound {
    if house % i == 0 {
      presents += i * presents_per_elf;
      // println!("  add {}", i * 10);
      co = house / i;
      if co != i {
        presents += co * presents_per_elf;
        // println!("  add {}", co * 10);
      }
      upper_bound = co - 1;
    }
    i += step;
  }
  // println!("Presents: {}", presents);
  presents
}

fn part_one(lines: &Vec<String>) -> AocResult {
  // let target: i64 = lines[0].parse().unwrap();
  let target: i64 = 4000000;
  // let target: i64 = 33100000;

  let mut presents: i64 = 10;
  let mut house: i64 = 2;
  while presents < target {
    presents = presents_for_house(house, &2, false);
    house += 1;
  }
  AocResult::Number(house - 1 as i64)
}

fn part_two(lines: &Vec<String>) -> AocResult {
  // let target: i64 = lines[0].parse().unwrap();
  let target: i64 = 4000000;
  // let target: i64 = 33100000;

  let mut presents: i64 = 10;
  let mut house: i64 = 2;
  let mut first_elf: i64 = 2;
  while presents < target {
    presents = presents_for_house(house, &first_elf, true);
    if house / first_elf == 50 {
      first_elf += 1;
    }
    house += 1;
  }
  AocResult::Number(house - 1 as i64)
}

pub fn main() {
  let now = std::time::Instant::now();
  aoc::run(2015, 20, 1, part_one);
  println!("Done in {}ms", now.elapsed().as_millis());
  aoc::run(2015, 20, 2, part_two);
}
