extern crate fancy_regex;
use aoc::AocResult;
use fancy_regex::Regex;
use std::collections::{HashMap, HashSet};

type Ingredient = u32;
type Allergen = u32;

struct Dictionary {
  counter: u32,
  by_name: HashMap<String, u32>,
  by_id: HashMap<u32, String>,
}

impl Dictionary {
  fn new() -> Self {
    Dictionary {
      counter: 0,
      by_name: HashMap::new(),
      by_id: HashMap::new(),
    }
  }

  fn add(&mut self, s: &str) -> u32 {
    match self.by_name.get(s) {
      Some(i) => *i,
      None => {
        self.by_name.insert(s.to_string(), self.counter);
        self.by_id.insert(self.counter, s.to_string());
        self.counter += 1;
        self.counter - 1
      }
    }
  }

  fn get_name(&self, id: u32) -> &String {
    self.by_id.get(&id).unwrap()
  }
}

#[derive(Debug)]
struct Food {
  ingredients: HashSet<Ingredient>,
  known_allergens: HashSet<Allergen>,
}

impl Food {
  fn new() -> Self {
    Food {
      ingredients: HashSet::new(),
      known_allergens: HashSet::new(),
    }
  }
}

struct Solver {
  foods: Vec<Food>,
  agmap: AllergenMap,
  ing_dict: Dictionary,
  ag_dict: Dictionary,
}

impl Solver {
  fn new() -> Self {
    Solver {
      foods: Vec::new(),
      agmap: AllergenMap::new(),
      ing_dict: Dictionary::new(),
      ag_dict: Dictionary::new(),
    }
  }

  fn add_food_from_line(&mut self, line: &String) {
    let re = Regex::new(r"(.*) \(contains (.*)\)").unwrap();
    let captures = re.captures(line).unwrap().unwrap();
    let ingredient_strs = captures.get(1).unwrap().as_str().split(" ");
    let mut food = Food::new();
    for ing_str in ingredient_strs {
      let ing_id = self.ing_dict.add(&ing_str);
      food.ingredients.insert(ing_id);
    }
    let allergen_strs = captures.get(2).unwrap().as_str().split(", ");
    for ag_str in allergen_strs {
      let ag_id = self.ag_dict.add(&ag_str);
      food.known_allergens.insert(ag_id);
    }
    self.foods.push(food);
  }

  fn build_agmap(&mut self) {
    for food in &self.foods {
      self.agmap.add_food(&food);
    }
    self.agmap.reduce();
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
          .into_iter()
          .map(|s| *s)
          .collect();
        self.map.insert(*allergen, new_ings);
      } else {
        self.map.insert(*allergen, food.ingredients.clone());
      }
    }
  }

  fn find_known(&self) -> Option<(Allergen, &HashSet<Ingredient>)> {
    match self.map.iter().find(|(_, ings)| ings.iter().count() == 1) {
      Some((ag, ings)) => Some((*ag, ings)),
      None => None,
    }
  }

  fn reduce(&mut self) {
    while let Some((ag, _)) = self.find_known() {
      let (known_ag, known_ings) = self.map.remove_entry(&ag).unwrap();
      let known_ing = known_ings.iter().nth(0).unwrap();
      self.known.insert(known_ag, *known_ing);
      for ings in self.map.values_mut() {
        ings.remove(known_ing);
      }
    }
  }
}

pub fn part_one(lines: &Vec<String>) -> AocResult {
  let mut solver = Solver::new();
  for line in lines {
    solver.add_food_from_line(&line);
  }
  solver.build_agmap();
  let bad_ingredients: HashSet<Ingredient> = solver.agmap.known.values().map(|s| *s).collect();
  let count = solver
    .foods
    .iter()
    .map(|food| food.ingredients.difference(&bad_ingredients).count())
    .sum::<usize>();
  AocResult::Number(count as i64)
}

pub fn part_two(lines: &Vec<String>) -> AocResult {
  let mut solver = Solver::new();
  for line in lines {
    solver.add_food_from_line(&line);
  }
  solver.build_agmap();
  let mut known_allergen_ids: Vec<&u32> = solver.agmap.known.keys().collect();
  known_allergen_ids.sort_by_key(|ag_id| solver.ag_dict.get_name(**ag_id));
  let bad_ingredients = known_allergen_ids
    .iter()
    .map(|ag_id| solver.agmap.known.get(ag_id).unwrap())
    .map(|ig_id| solver.ing_dict.get_name(*ig_id))
    .collect::<Vec<_>>();
  return AocResult::String(itertools::join(bad_ingredients, ","));
}
