use aoc::token_dict::{Token, TokenDict};
use aoc::AocResult;
use regex::Regex;
use std::collections::{HashMap, HashSet};

const SELF: Token = 42;

fn build_happy_ratings(lines: &Vec<String>) -> HashMap<Token, HashMap<Token, i64>> {
  let re =
    Regex::new(r"(.*) would (gain|lose) (.*) happiness units by sitting next to (.*)\.").unwrap();
  let mut data: HashMap<Token, HashMap<Token, i64>> = HashMap::new();
  let mut tokens = TokenDict::new();
  for line in lines {
    let caps = re.captures(line).unwrap();
    let a = tokens.tokenize(caps.get(1).unwrap().as_str());
    let b = tokens.tokenize(caps.get(4).unwrap().as_str());
    let gainlose = if caps.get(2).unwrap().as_str() == "gain" {
      1
    } else {
      -1
    };
    let weight = caps.get(3).unwrap().as_str().parse::<i64>().unwrap() * gainlose;
    match data.get_mut(&a) {
      Some(h) => {
        h.insert(b, weight);
      }
      None => {
        let mut newh = HashMap::new();
        newh.insert(b, weight);
        data.insert(a, newh);
      }
    }
  }
  data
}

fn max_happiness(
  happy_ratings: &HashMap<Token, HashMap<Token, i64>>,
  remaining: HashSet<Token>,
) -> i64 {
  remaining
    .iter()
    .map(|p| {
      let mut next_rem = remaining.clone();
      next_rem.remove(p);
      _max_happiness(&happy_ratings, *p, *p, 0, next_rem)
    })
    .max()
    .unwrap()
}

fn _max_happiness(
  happy_ratings: &HashMap<Token, HashMap<Token, i64>>,
  first: Token,
  prev: Token,
  happiness: i64,
  remaining: HashSet<Token>,
) -> i64 {
  if remaining.len() == 0 {
    happiness
      + happy_ratings.get(&first).unwrap().get(&prev).unwrap()
      + happy_ratings.get(&prev).unwrap().get(&first).unwrap()
  } else {
    remaining
      .iter()
      .map(|p| {
        let mut next_rem = remaining.clone();
        next_rem.remove(p);
        happy_ratings.get(&prev).unwrap().get(p).unwrap()
          + happy_ratings.get(p).unwrap().get(&prev).unwrap()
          + _max_happiness(&happy_ratings, first, *p, happiness, next_rem)
      })
      .max()
      .unwrap()
  }
}
fn part_one(lines: &Vec<String>) -> AocResult {
  let happy_ratings = build_happy_ratings(lines);
  let people: HashSet<Token> = happy_ratings.keys().copied().collect();
  AocResult::Number(max_happiness(&happy_ratings, people))
}

fn part_two(lines: &Vec<String>) -> AocResult {
  let mut happy_ratings = build_happy_ratings(lines);
  let mut self_happy = HashMap::<Token, i64>::new();
  for p in happy_ratings.keys() {
    self_happy.insert(*p, 0);
  }
  happy_ratings.insert(SELF, self_happy);
  let people: HashSet<Token> = happy_ratings.keys().copied().collect();
  for hr in happy_ratings.values_mut() {
    hr.insert(SELF, 0);
  }
  AocResult::Number(max_happiness(&happy_ratings, people))
}

pub fn main() {
  aoc::run(2015, 13, 1, part_one);
  aoc::run(2015, 13, 2, part_two);
}
