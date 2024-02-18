extern crate fancy_regex;
use aoc::AocResult;
use fancy_regex::Regex;

fn has_three_vowels(s: &str) -> bool {
  let re_vowels = Regex::new(r".*[aeiou].*[aeiou].*[aeiou].*").unwrap();
  return re_vowels.is_match(s).unwrap();
}

fn has_a_double(s: &str) -> bool {
  let re_double = Regex::new(r"(.)\1").unwrap();
  return re_double.is_match(s).unwrap();
}

fn does_not_have_bad_word(s: &str) -> bool {
  let re_bads = Regex::new(r"(ab)|(cd)|(pq)|(xy)").unwrap();
  return !re_bads.is_match(s).unwrap();
}

fn is_nice_1(s: &str) -> bool {
  return has_three_vowels(s) && has_a_double(s) && does_not_have_bad_word(s);
}

fn is_nice_2(s: &str) -> bool {
  let re_double_double = Regex::new(r"(..).*\1").unwrap();
  let re_surround = Regex::new(r"(.).\1").unwrap();
  return re_double_double.is_match(s).unwrap() && re_surround.is_match(s).unwrap();
}

fn part_one(lines: &Vec<String>) -> AocResult {
  return AocResult::Number(lines.iter().filter(|s| is_nice_1(s)).count() as i64);
}

fn part_two(lines: &Vec<String>) -> AocResult {
  return AocResult::Number(lines.iter().filter(|s| is_nice_2(s)).count() as i64);
}

pub fn main() {
  aoc::run(2015, 5, 1, part_one);
  aoc::run(2015, 5, 2, part_two);
}

#[cfg(test)]
mod tests {
  use super::*;
  #[test]
  fn test_vowels() {
    assert_eq!(has_three_vowels("aaa"), true, "aaa");
    assert_eq!(has_three_vowels("ddaeddidd"), true, "ddaeddidd");
    assert_eq!(has_three_vowels("bbabbabb"), false, "bbabbabb");
  }
}
