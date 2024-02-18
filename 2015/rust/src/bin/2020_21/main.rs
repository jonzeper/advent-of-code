extern crate fancy_regex;
use aoc::AocResult;
use fancy_regex::Regex;
use std::collections::{HashMap, HashSet};

mod using_int_ids;

type Ingredient = String;
type Allergen = String;

struct Food {
  ingredients: HashSet<Ingredient>,
  known_allergens: HashSet<Allergen>,
}

impl Food {
  fn from_line(line: &String) -> Self {
    let re = Regex::new(r"(.*) \(contains (.*)\)").unwrap();
    let captures = re.captures(line).unwrap().unwrap();
    let ingredients: HashSet<Ingredient> = captures
      .get(1)
      .unwrap()
      .as_str()
      .split(" ")
      .map(str::to_string)
      .collect();
    let allergens: HashSet<Allergen> = captures
      .get(2)
      .unwrap()
      .as_str()
      .split(", ")
      .map(str::to_string)
      .collect();
    Food {
      ingredients: ingredients,
      known_allergens: allergens,
    }
  }
}

struct AllergenMap {
  map: HashMap<Allergen, HashSet<Ingredient>>,
  known: HashMap<Allergen, Ingredient>,
}

impl AllergenMap {
  fn new() -> Self {
    AllergenMap {
      map: HashMap::new(),
      known: HashMap::new(),
    }
  }

  fn add_food(&mut self, food: &Food) {
    for allergen in &food.known_allergens {
      if self.map.contains_key(allergen) {
        let new_ings = self.map[allergen]
          .intersection(&food.ingredients)
          .map(|s| s.clone())
          .collect();
        self.map.insert(allergen.clone(), new_ings);
      } else {
        self.map.insert(allergen.clone(), food.ingredients.clone());
      }
    }
  }

  fn find_known(&self) -> Option<(Allergen, &HashSet<Ingredient>)> {
    match self.map.iter().find(|(_, ings)| ings.iter().count() == 1) {
      Some((ag, ings)) => Some((ag.clone(), ings)),
      None => None,
    }
  }

  fn reduce(&mut self) {
    while let Some((ag, _)) = self.find_known() {
      let (known_ag, known_ings) = self.map.remove_entry(&ag).unwrap();
      let known_ing = known_ings.iter().nth(0).unwrap();
      self.known.insert(known_ag.clone(), known_ing.clone());
      for ings in self.map.values_mut() {
        ings.remove(known_ing);
      }
    }
  }
}

fn read_foods(lines: &Vec<String>) -> Vec<Food> {
  lines.iter().map(Food::from_line).collect()
}

fn build_agmap(foods: &Vec<Food>) -> AllergenMap {
  let mut agmap = AllergenMap::new();
  for food in foods {
    agmap.add_food(&food);
  }
  agmap.reduce();
  agmap
}

fn part_one(lines: &Vec<String>) -> AocResult {
  let foods = read_foods(lines);
  let agmap = build_agmap(&foods);
  let bad_ingredients: HashSet<Ingredient> = agmap.known.values().map(|s| s.clone()).collect();
  let count = foods
    .iter()
    .map(|food| food.ingredients.difference(&bad_ingredients).count())
    .sum::<usize>();
  AocResult::Number(count as i64)
}

fn part_two(lines: &Vec<String>) -> AocResult {
  let foods = read_foods(lines);
  let agmap = build_agmap(&foods);
  let mut known_allergens = agmap.known.keys().collect::<Vec<_>>();
  known_allergens.sort();
  let bad_ingredients = known_allergens
    .iter()
    .map(|ag| agmap.known.get(*ag).unwrap())
    .collect::<Vec<_>>();
  return AocResult::String(itertools::join(bad_ingredients, ","));
}

pub fn main() {
  aoc::run(2020, 21, 1, part_one);
  aoc::run(2020, 21, 2, part_two);

  println!("Using int ids");
  aoc::run(2020, 21, 1, using_int_ids::part_one);
  aoc::run(2020, 21, 2, using_int_ids::part_two);

  // No difference
  // aoc::run_x_times(2020, 21, part_two, 30);
  // aoc::run_x_times(2020, 21, using_int_ids::part_two, 30);
}
