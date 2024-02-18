extern crate md5;
use aoc::AocResult;

fn find_5_zeroes(prefix: &str) -> i64 {
  let mut n = 0;
  let mut hash = String::from("");
  while !hash.starts_with("00000") {
    let n_str = format!("{}{}", prefix, n);
    hash = format!("{:x}", md5::compute(n_str));
    n = n + 1;
  }
  return n - 1;
}

fn find_6_zeroes(prefix: &str) -> i64 {
  let mut n = 0;
  let mut hash = String::from("");
  while !hash.starts_with("000000") {
    let n_str = format!("{}{}", prefix, n);
    hash = format!("{:x}", md5::compute(n_str));
    n = n + 1;
  }
  return n - 1;
}

fn part_one(lines: &Vec<String>) -> AocResult {
  let input = &lines[0];
  let result = find_5_zeroes(input);
  return AocResult::Number(result);
}

fn part_two(lines: &Vec<String>) -> AocResult {
  let input = &lines[0];
  let result = find_6_zeroes(input);
  return AocResult::Number(result);
}

fn main() {
  aoc::run(2015, 4, 1, part_one);
  aoc::run(2015, 4, 2, part_two);
}

#[cfg(test)]
mod tests {
  #[test]
  fn test_md5() {
    let x = format!("{}", 5);
    let md = format!("{:x}", md5::compute(x));
    assert_eq!(md, "e4da3b7fbbce2345d7772b0674a318d5");
  }
}
