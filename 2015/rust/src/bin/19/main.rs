use aoc::AocResult;
use regex::Regex;
use std::collections::HashSet;

fn parse_transformations(lines: &Vec<String>) -> Vec<(&str, &str)> {
  let re = Regex::new(r"(.*) => (.*)").unwrap();
  lines
    .iter()
    .map(|line| {
      let caps = re.captures(line).unwrap();
      let from = caps.get(1).unwrap().as_str();
      let to = caps.get(2).unwrap().as_str();
      (from, to)
    })
    .collect::<Vec<(&str, &str)>>()
}

fn part_one(lines: &Vec<String>) -> AocResult {
  let mut found: HashSet<String> = HashSet::new();
  let chunks = aoc::chunk_lines(lines);
  let transformations = parse_transformations(&chunks[0]);
  let source_molecule = &chunks[1][0];
  for (from, to) in &transformations {
    let re = Regex::new(from).unwrap();
    let mut match_iter = re.find_iter(source_molecule);
    while let Some(matc) = match_iter.next() {
      let mut news = source_molecule.clone();
      news.replace_range(matc.start()..matc.end(), to);
      found.insert(news);
    }
  }
  AocResult::Number(found.len() as i64)
}

// XXX: This is no good, way too many combos to check
// fn find_target(
//   target: &String,
//   strs_to_check: Vec<String>,
//   step: u32,
//   transformations: &Vec<(&str, &str)>,
//   visited: &mut HashSet<String>,
// ) -> u32 {
//   println!("Step {} checking {} variations", step, strs_to_check.len());
//   let mut next_checks: Vec<String> = vec![];
//   for current in strs_to_check {
//     for (from, to) in transformations {
//       let re = Regex::new(from).unwrap();
//       let mut match_iter = re.find_iter(&current);
//       while let Some(matc) = match_iter.next() {
//         let mut news = current.clone();
//         news.replace_range(matc.start()..matc.end(), to);
//         if news == *target {
//           return step;
//         } else {
//           if !visited.contains(&news) {
//             visited.insert(news.clone());
//             next_checks.push(news);
//           }
//         }
//       }
//     }
//   }
//   if step > 7 {
//     return 0;
//   }
//   find_target(target, next_checks, step + 1, transformations, visited)
// }

// Cheated on this one and took answer from
// https://www.reddit.com/r/adventofcode/comments/3xflz8/day_19_solutions/cy4etju/?utm_source=reddit&utm_medium=web2x&context=3
fn part_two(lines: &Vec<String>) -> AocResult {
  let chunks = aoc::chunk_lines(lines);
  // let transformations = parse_transformations(&chunks[0]);
  let target = &chunks[1][0];
  // let steps = find_target(
  //   &target,
  //   vec!["e".to_string()],
  //   1,
  //   &transformations,
  //   &mut HashSet::new(),
  // );
  let rn_re = Regex::new(r"Rn").unwrap();
  let rn_c = rn_re.find_iter(target).count() as i64;
  let ar_re = Regex::new(r"Ar").unwrap();
  let ar_c = ar_re.find_iter(target).count() as i64;
  let y_re = Regex::new(r"Y").unwrap();
  let y_c = y_re.find_iter(target).count() as i64;
  let steps: i64 =
    target.chars().filter(|c| (*c as u8) < ('a' as u8)).count() as i64 - rn_c - ar_c - 2 * y_c - 1;
  AocResult::Number(steps as i64)
}

pub fn main() {
  aoc::run(2015, 19, 1, part_one);
  aoc::run(2015, 19, 2, part_two);
}
