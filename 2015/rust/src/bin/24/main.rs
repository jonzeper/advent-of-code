use aoc::AocResult;
use itertools::Itertools;
use std::cmp::Ordering;
use std::collections::BinaryHeap;
use std::collections::HashSet;

type Package = u128;

#[derive(Eq, PartialEq, Clone, Debug)]
struct Combo {
  packages: HashSet<Package>,
  entanglement: Package,
  weight: Package,
  last_package_n: usize,
}

impl Combo {
  fn new() -> Self {
    Combo {
      packages: HashSet::new(),
      entanglement: 1,
      weight: 0,
      last_package_n: 0,
    }
  }

  fn insert(&mut self, package: Package) {
    self.packages.insert(package);
    self.entanglement *= package;
    self.weight += package;
  }
}

impl PartialOrd for Combo {
  fn partial_cmp(&self, other: &Combo) -> Option<Ordering> {
    (other.weight, other.entanglement).partial_cmp(&(self.weight, self.entanglement))
  }
}

impl Ord for Combo {
  fn cmp(&self, other: &Combo) -> Ordering {
    (other.weight, other.entanglement).cmp(&(self.weight, self.entanglement))
  }
}

fn find_min_combo_size(packages: &Vec<Package>, target_weight: Package) -> usize {
  let mut weight: Package = 0;
  let mut n: usize = 0;
  let mut iter = packages.iter();
  while weight < target_weight {
    weight += iter.next().unwrap();
    n += 1;
  }
  n
}

fn find_combos(packages: &Vec<Package>, target_weight: Package, size: usize) -> Vec<Vec<Package>> {
  let combos: Vec<Vec<Package>> = vec![];

  let mut first_usable: usize = packages.len() - 1;
  let max_except_one: Package = packages[0..size - 1].iter().sum();
  while max_except_one + packages[first_usable] < target_weight {
    first_usable -= 1;
  }
  let usable_packages = &packages[0..first_usable + 1];

  let combos = usable_packages
    .iter()
    .combinations(size)
    .filter(|c| c.iter().fold(0, |acc, x| acc + **x) == target_weight);

  combos.for_each(|c| println!("{:?}", c));

  vec![]
  // combos
}

fn part_one(lines: &Vec<String>) -> AocResult {
  let mut packages: Vec<Package> = lines
    .iter()
    .map(|l| l.parse::<Package>().unwrap())
    .collect();
  packages.sort();
  packages.reverse();
  let total_weight: Package = packages.iter().sum();
  let compartment_weight = total_weight / 3;

  let min_combo_size = find_min_combo_size(&packages, compartment_weight);

  let mut combos: Vec<Vec<Package>> = vec![];
  while combos.is_empty() {
    combos = find_combos(&packages, compartment_weight, min_combo_size);
  }

  println!("min combo size: {}", min_combo_size);

  AocResult::Number(0)
}

fn part_two(lines: &Vec<String>) -> AocResult {
  AocResult::Number(0)
}

pub fn main() {
  aoc::run(2015, 24, 1, part_one);
  // aoc::run(2015, 24, 2, part_two);
}

#[cfg(test)]
mod tests {
  use super::*;
  #[test]
  fn test_entanglement() {
    let mut combo: Combo = Combo::new();
    combo.insert(2);
    combo.insert(3);
    combo.insert(4);
    assert_eq!(entanglement(&combo), 24);
  }
}
