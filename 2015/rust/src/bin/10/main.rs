use aoc::AocResult;

fn play_round(seq: String) -> String {
  let seq_size = seq.len();
  let mut out_seq = String::from("");
  let mut buffer_c = *seq[0..1].chars().peekable().peek().unwrap();
  let mut count = 1;
  for (i, c) in seq.chars().enumerate() {
    if i == seq_size - 1 {
      if c == buffer_c {
        count = if i == 0 { count } else { count + 1 };
        out_seq.push_str(&format!("{}{}", count, buffer_c));
      } else {
        out_seq.push_str(&format!("{}{}1{}", count, buffer_c, c));
      }
    } else {
      if c == buffer_c {
        count = if i == 0 { count } else { count + 1 };
      } else {
        out_seq.push_str(&format!("{}{}", count, buffer_c));
        buffer_c = c;
        count = 1;
      }
    }
  }
  out_seq
}

fn part_one(lines: &Vec<String>) -> AocResult {
  let mut seq = lines[0].to_string();
  for _ in 0..40 {
    seq = play_round(seq.to_string());
  }
  AocResult::Number(seq.len() as i64)
}

fn part_two(lines: &Vec<String>) -> AocResult {
  let mut seq = lines[0].to_string();
  for _ in 0..50 {
    seq = play_round(seq.to_string());
  }
  AocResult::Number(seq.len() as i64)
}

pub fn main() {
  aoc::run(2015, 10, 1, part_one);
  aoc::run(2015, 10, 2, part_two);
}
