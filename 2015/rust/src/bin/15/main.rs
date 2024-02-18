use aoc::AocResult;
use regex::Regex;
use std::cmp::max;

const RECIPE_SIZE: i64 = 100;

#[derive(Debug, Default)]
struct Ingredient {
  cap: i64,
  dur: i64,
  flv: i64,
  tex: i64,
  cal: i64,
}

impl Ingredient {
  fn new() -> Self {
    Default::default()
  }

  fn from_line(line: &String) -> Self {
    let re =
      Regex::new(r".*: capacity (.*), durability (.*), flavor (.*), texture (.*), calories (.*)")
        .unwrap();
    let caps = re.captures(line).unwrap();
    Ingredient {
      cap: caps.get(1).unwrap().as_str().parse().unwrap(),
      dur: caps.get(2).unwrap().as_str().parse().unwrap(),
      flv: caps.get(3).unwrap().as_str().parse().unwrap(),
      tex: caps.get(4).unwrap().as_str().parse().unwrap(),
      cal: caps.get(5).unwrap().as_str().parse().unwrap(),
    }
  }
}

#[derive(Debug, Clone)]
struct Recipe {
  quantities: Vec<i64>,
}

impl Recipe {
  fn new(ingredients: &Vec<Ingredient>) -> Recipe {
    let n_ingredients = ingredients.len();
    Recipe {
      quantities: vec![0; n_ingredients],
    }
  }

  fn best(ings: &Vec<Ingredient>, cal_requirement: i64) -> Self {
    let n_ings = ings.len();
    let mut best_score = 0;
    let mut best_recipe: Recipe = Recipe::new(ings);
    if n_ings == 2 {
      for i in 0..RECIPE_SIZE {
        let quants = vec![i, RECIPE_SIZE - i];
        let recipe = Recipe { quantities: quants };
        if recipe.value(ings) > best_score
          && (cal_requirement < 0 || recipe.calories(ings) == cal_requirement)
        {
          best_score = recipe.value(ings);
          best_recipe = recipe;
        }
      }
    } else {
      // n_ings == 4
      for i in 0..RECIPE_SIZE {
        for j in 0..(RECIPE_SIZE - i) {
          for k in 0..(RECIPE_SIZE - (i + j)) {
            let l = RECIPE_SIZE - (i + j + k);
            let recipe = Recipe {
              quantities: vec![i, j, k, l],
            };
            if recipe.value(ings) > best_score
              && (cal_requirement < 0 || recipe.calories(ings) == cal_requirement)
            {
              best_score = recipe.value(ings);
              best_recipe = recipe;
            }
          }
        }
      }
    }
    best_recipe
  }

  fn value(&self, ings: &Vec<Ingredient>) -> i64 {
    let ing_sums: Ingredient =
      self
        .quantities
        .iter()
        .zip(ings)
        .fold(Ingredient::new(), |ing, (q, i)| Ingredient {
          cap: ing.cap + q * i.cap,
          dur: ing.dur + q * i.dur,
          flv: ing.flv + q * i.flv,
          tex: ing.tex + q * i.tex,
          cal: ing.cal + q * i.cal,
        });
    max(0, ing_sums.cap) * max(0, ing_sums.dur) * max(0, ing_sums.flv) * max(0, ing_sums.tex)
  }

  fn calories(&self, ings: &Vec<Ingredient>) -> i64 {
    self
      .quantities
      .iter()
      .zip(ings)
      .map(|(q, i)| q * i.cal)
      .sum()
  }
}

fn part_one(lines: &Vec<String>) -> AocResult {
  let ings = lines.iter().map(Ingredient::from_line).collect::<Vec<_>>();
  let recipe = Recipe::best(&ings, -1);
  println!("Final quantities: {:?}", recipe.quantities);
  AocResult::Number(recipe.value(&ings))
}

fn part_two(lines: &Vec<String>) -> AocResult {
  let ings = lines.iter().map(Ingredient::from_line).collect::<Vec<_>>();
  let recipe = Recipe::best(&ings, 500);
  println!("Final quantities: {:?}", recipe.quantities);
  AocResult::Number(recipe.value(&ings))
}

pub fn main() {
  aoc::run(2015, 15, 1, part_one);
  aoc::run(2015, 15, 2, part_two);
}

#[cfg(test)]
mod tests {
  use super::*;
  #[test]
  fn test_value() {
    let ing1 = Ingredient::from_line(
      &"Butterscotch: capacity -1, durability -2, flavor 6, texture 3, calories 8".to_string(),
    );
    let ing2 = Ingredient::from_line(
      &"Cinnamon: capacity 2, durability 3, flavor -2, texture -1, calories 3".to_string(),
    );
    let ings = vec![ing1, ing2];
    let mut recipe = Recipe::new(&ings);
    recipe.quantities = vec![44, 56];
    assert_eq!(recipe.value(&ings), 62842880);
  }
}
