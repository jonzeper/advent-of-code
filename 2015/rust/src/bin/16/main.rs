use aoc::AocResult;
use regex::Regex;
use std::collections::HashMap;

fn mfcsam() -> HashMap<String, i64> {
  let mut map: HashMap<String, i64> = HashMap::new();
  map.insert("children".to_string(), 3);
  map.insert("cats".to_string(), 7);
  map.insert("samoyeds".to_string(), 2);
  map.insert("pomeranians".to_string(), 3);
  map.insert("akitas".to_string(), 0);
  map.insert("vizslas".to_string(), 0);
  map.insert("goldfish".to_string(), 5);
  map.insert("trees".to_string(), 3);
  map.insert("cars".to_string(), 2);
  map.insert("perfumes".to_string(), 1);
  map
}

fn part_one(lines: &Vec<String>) -> AocResult {
  let re = Regex::new(r"Sue \d*: (.*?): (\d*), (.*?): (\d*), (.*?): (\d*).*").unwrap();
  let mfcsam = mfcsam();
  let (sue, _) = lines
    .iter()
    .enumerate()
    .find(|(_i, line)| {
      let caps = re.captures(line).unwrap();
      let prop_1 = caps.get(2).unwrap().as_str();
      let prop_2 = caps.get(4).unwrap().as_str();
      let prop_3 = caps.get(6).unwrap().as_str();
      let quant_1: i64 = caps.get(3).unwrap().as_str().parse().unwrap();
      let quant_2: i64 = caps.get(5).unwrap().as_str().parse().unwrap();
      let quant_3: i64 = caps.get(7).unwrap().as_str().parse().unwrap();
      mfcsam[prop_1] == quant_1 && mfcsam[prop_2] == quant_2 && mfcsam[prop_3] == quant_3
    })
    .unwrap();
  AocResult::Number(sue as i64 + 1)
}

fn prop_is_match(mfcsam: &HashMap<String, i64>, prop: &String, quant: i64) -> bool {
  match prop.as_str() {
    "cats" => mfcsam[prop] < quant,
    "trees" => mfcsam[prop] < quant,
    "pomeranians" => mfcsam[prop] > quant,
    "goldfish" => mfcsam[prop] > quant,
    _ => mfcsam[prop] == quant,
  }
}

fn part_two(lines: &Vec<String>) -> AocResult {
  let re = Regex::new(r"Sue \d*: (.*?): (\d*), (.*?): (\d*), (.*?): (\d*).*").unwrap();
  let mfcsam = mfcsam();
  let (sue, _) = lines
    .iter()
    .enumerate()
    .find(|(_i, line)| {
      let caps = re.captures(line).unwrap();
      let prop_1 = caps.get(2).unwrap().as_str().to_string();
      let prop_2 = caps.get(4).unwrap().as_str().to_string();
      let prop_3 = caps.get(6).unwrap().as_str().to_string();
      let quant_1: i64 = caps.get(3).unwrap().as_str().parse().unwrap();
      let quant_2: i64 = caps.get(5).unwrap().as_str().parse().unwrap();
      let quant_3: i64 = caps.get(7).unwrap().as_str().parse().unwrap();
      prop_is_match(&mfcsam, &prop_1, quant_1)
        && prop_is_match(&mfcsam, &prop_2, quant_2)
        && prop_is_match(&mfcsam, &prop_3, quant_3)
    })
    .unwrap();
  AocResult::Number(sue as i64 + 1)
}

pub fn main() {
  aoc::run(2015, 16, 1, part_one);
  aoc::run(2015, 16, 2, part_two);
}
