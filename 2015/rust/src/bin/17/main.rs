use aoc::AocResult;

const TOTAL_NOG: u16 = 150;
type Combo = Vec<(u16, u16)>;

fn combo_sum(combo: &Combo) -> u16 {
  combo.iter().map(|(c, q)| c * q).sum()
}

fn combo_size(combo: &Combo) -> usize {
  combo.iter().filter(|(_c, q)| q > &0).count()
}

fn increment_combo(combo: &mut Combo) -> Result<(), ()> {
  // println!("Incrementing {:?}", combo);
  if let Some((last_container, last_quant)) = combo.pop() {
    // println!("Popped ({}, {})", last_container, last_quant);
    let next_quant = last_quant + 1;
    if next_quant == 2 {
      // let (removed, _) = combo.pop().unwrap();
      match increment_combo(combo) {
        Ok(_) => {
          0;
        }
        Err(_) => {
          return Err(());
        }
      };
      combo.push((last_container, 0));
    } else {
      combo.push((last_container, last_quant + 1));
    }
  } else {
    return Err(());
  }
  Ok(())
}

fn find_combos(containers: Vec<u16>) -> Vec<Combo> {
  let n_containers = containers.len();
  let mut combo: Combo = containers
    .into_iter()
    .zip(vec![0 as u16; n_containers])
    .collect();
  let mut finds: Vec<Combo> = vec![];
  loop {
    match increment_combo(&mut combo) {
      Ok(()) => {
        0;
      }
      Err(()) => {
        break;
      }
    };
    if combo_sum(&combo) == TOTAL_NOG {
      finds.push(combo.clone());
    }
    let (c1, q1) = combo[0];
    if c1 * q1 >= TOTAL_NOG {
      break;
    }
  }
  finds
}

fn part_one(lines: &Vec<String>) -> AocResult {
  let containers: Vec<u16> = lines.iter().map(|l| l.parse::<u16>().unwrap()).collect();
  let combos = find_combos(containers);
  AocResult::Number(combos.len() as i64)
}

fn part_two(lines: &Vec<String>) -> AocResult {
  let containers: Vec<u16> = lines.iter().map(|l| l.parse::<u16>().unwrap()).collect();
  let combos = find_combos(containers);
  let min_combo = combos.iter().min_by_key(|c| combo_size(c)).unwrap();
  let min_size = combo_size(min_combo);
  AocResult::Number(min_size as i64)
}

pub fn main() {
  aoc::run(2015, 17, 1, part_one);
  aoc::run(2015, 17, 2, part_two);
}

#[cfg(test)]
mod tests {
  use super::*;
  #[test]
  fn test_combo_sum() {
    let combo = vec![(5, 5), (3, 1), (8, 2)];
    assert_eq!(combo_sum(&combo), 44);
  }

  #[test]
  fn test_find_combos() {
    let containers: Vec<u16> = vec![75, 75];
    assert_eq!(find_combos(containers).len(), 1);

    let containers: Vec<u16> = vec![75, 75, 75];
    assert_eq!(find_combos(containers).len(), 3);
  }
}
