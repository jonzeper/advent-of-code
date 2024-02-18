use aoc::AocResult;
use json::JsonValue;

fn json_val(x: &JsonValue) -> i64 {
  match x {
    JsonValue::Array(a) => a.iter().map(|o| json_val(o)).sum(),
    JsonValue::Object(o) => o.iter().map(|(_, x)| json_val(x)).sum(),
    JsonValue::Number(_) => x.as_i64().unwrap(),
    _ => 0,
  }
}

fn json_val_no_red(x: &JsonValue) -> i64 {
  match x {
    JsonValue::Array(a) => a.iter().map(|o| json_val_no_red(o)).sum(),
    JsonValue::Object(o) => {
      if o.iter().any(|(_, x)| x.as_str().unwrap_or("x") == "red") {
        0
      } else {
        o.iter().map(|(_, x)| json_val_no_red(x)).sum()
      }
    }
    JsonValue::Number(_) => x.as_i64().unwrap(),
    _ => 0,
  }
}

fn part_one(lines: &Vec<String>) -> AocResult {
  let x = json::parse(&lines[0]).expect("Invalid JSON!");
  AocResult::Number(json_val(&x))
}

fn part_two(lines: &Vec<String>) -> AocResult {
  let x = json::parse(&lines[0]).expect("Invalid JSON!");
  AocResult::Number(json_val_no_red(&x))
}

pub fn main() {
  aoc::run(2015, 12, 1, part_one);
  aoc::run(2015, 12, 2, part_two);
}
