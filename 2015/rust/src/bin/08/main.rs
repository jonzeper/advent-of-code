use aoc::AocResult;
use regex::Regex;

fn lendiff_1(line: &String) -> usize {
  let initial_count = line.chars().count();
  let re = Regex::new(r#"\\\\|\\"|\\x.."#).unwrap();
  let updated = re.replace_all(line, "Z");
  let updated_count = updated.chars().count() - 2;
  initial_count - updated_count
}

fn lendiff_2(line: &String) -> usize {
  let initial_count = line.chars().count();
  let re = Regex::new(r#""|\\"#).unwrap();
  let updated = re.replace_all(line, "12");
  let updated_count = updated.chars().count() + 2;
  updated_count - initial_count
}

fn part_one(lines: &Vec<String>) -> AocResult {
  AocResult::Number(lines.iter().map(lendiff_1).sum::<usize>() as i64)
}

fn part_two(lines: &Vec<String>) -> AocResult {
  AocResult::Number(lines.iter().map(lendiff_2).sum::<usize>() as i64)
}

pub fn main() {
  aoc::run(2015, 8, 1, part_one);
  aoc::run(2015, 8, 2, part_two);
}
