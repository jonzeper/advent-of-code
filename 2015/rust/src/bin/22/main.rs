use aoc::AocResult;
use std::cmp::Ordering;
use std::collections::BinaryHeap;

type Stat = i32;
type MoveId = usize;
enum GameResult {
  PlayerWin,
  BossWin,
  DeadEnd,
}

const SHIELD_ARMOR: Stat = 7;
const POISON_DAMAGE: Stat = 3;
const RECHARGE_AMOUNT: Stat = 101;

struct Move<'a> {
  name: &'a str,
  cost: Stat,
}

const MOVES: [Move; 5] = [
  Move {
    name: "magic_missile",
    cost: 53,
  },
  Move {
    name: "drain",
    cost: 73,
  },
  Move {
    name: "shield",
    cost: 113,
  },
  Move {
    name: "poison",
    cost: 173,
  },
  Move {
    name: "recharge",
    cost: 229,
  },
];

#[derive(Eq, PartialEq, Clone, Debug, Hash)]
struct MoveList {
  list: Vec<MoveId>,
  cost: Stat,
}

impl MoveList {
  fn new(list: Vec<MoveId>) -> Self {
    let cost = list.iter().map(|&move_id| MOVES[move_id].cost).sum();
    MoveList {
      list: list,
      cost: cost,
    }
  }

  fn push(&mut self, move_id: MoveId) {
    self.list.insert(0, move_id);
    self.cost += MOVES[move_id].cost;
  }

  fn pop(&mut self) -> Option<MoveId> {
    self.list.pop()
  }
}

impl PartialOrd for MoveList {
  fn partial_cmp(&self, other: &MoveList) -> Option<Ordering> {
    other.cost.partial_cmp(&self.cost)
  }
}

impl Ord for MoveList {
  fn cmp(&self, other: &MoveList) -> Ordering {
    other.cost.cmp(&self.cost)
  }
}

#[derive(Clone)]
struct Game {
  boss_hp: Stat,
  boss_damage: Stat,
  player_hp: Stat,
  mana: Stat,
  shield_effect: Stat,
  poison_effect: Stat,
  recharge_effect: Stat,
  movelist: MoveList,
  part_two: bool,
}

impl Game {
  fn new(boss_hp: Stat, boss_damage: Stat, movelist: &MoveList, part_two: bool) -> Self {
    Game {
      boss_hp: boss_hp,
      boss_damage: boss_damage,
      player_hp: 50,
      mana: 500,
      shield_effect: 0,
      poison_effect: 0,
      recharge_effect: 0,
      movelist: movelist.clone(),
      part_two: part_two,
    }
  }

  fn hps(&self) -> String {
    format!(
      " player: {}  boss: {}  mana: {}",
      self.player_hp, self.boss_hp, self.mana
    )
  }

  fn player_armor(&self) -> Stat {
    if self.shield_effect > 0 {
      SHIELD_ARMOR
    } else {
      0
    }
  }

  fn decrease_effects(&mut self) {
    if self.shield_effect > 0 {
      self.shield_effect -= 1;
      //println!("  -shield: {}", self.shield_effect);
    }
    if self.poison_effect > 0 {
      self.poison_effect -= 1;
      //println!("  -poison: {}", self.poison_effect);
    }
    if self.recharge_effect > 0 {
      self.recharge_effect -= 1;
      //println!("  -recharge: {}", self.recharge_effect);
    }
  }

  fn apply_effects(&mut self) {
    if self.poison_effect > 0 {
      self.boss_hp -= POISON_DAMAGE;
      //println!("boss poisoned\t\t{}", self.hps());
    }
    if self.recharge_effect > 0 {
      self.mana += RECHARGE_AMOUNT;
      //println!("  recharge  {}", self.hps());
    }
    self.decrease_effects();
  }

  fn boss_turn(&mut self) -> Option<GameResult> {
    //println!("\n== BOSS TURN ==\t\t{}", self.hps());
    self.apply_effects();
    if self.boss_hp <= 0 {
      return Some(GameResult::PlayerWin);
    }
    let damage = std::cmp::max(1, self.boss_damage - self.player_armor());
    self.player_hp -= damage;
    //println!("Boss hits for {}\t\t{}", damage, self.hps());
    if self.player_hp <= 0 {
      if self.movelist.list.len() > 0 {
        Some(GameResult::DeadEnd)
      } else {
        Some(GameResult::BossWin)
      }
    } else {
      None
    }
  }

  fn player_turn(&mut self) -> Option<GameResult> {
    //println!("\n== PLAYER TURN ==\t{}", self.hps());
    if self.part_two {
      self.player_hp -= 1;
      //println!("player decay\t\t{}", self.hps());
      if self.player_hp <= 0 {
        return Some(GameResult::DeadEnd);
      }
    }
    self.apply_effects();
    if self.boss_hp <= 0 {
      return Some(GameResult::PlayerWin);
    }
    if let Some(next_move) = self.movelist.pop() {
      //println!("Cast {}", MOVES[next_move].name);
      self.mana -= MOVES[next_move].cost;
      if self.mana < 0 {
        //println!("    out of mana!");
        return Some(GameResult::DeadEnd);
      }
      match MOVES[next_move].name {
        "magic_missile" => {
          self.boss_hp -= 4;
        }
        "drain" => {
          self.boss_hp -= 2;
          self.player_hp += 2;
        }
        "shield" => {
          if self.shield_effect == 0 {
            self.shield_effect = 6;
          } else {
            return Some(GameResult::DeadEnd);
          }
        }
        "poison" => {
          if self.poison_effect == 0 {
            self.poison_effect = 6;
          } else {
            return Some(GameResult::DeadEnd);
          }
        }
        "recharge" => {
          if self.recharge_effect == 0 {
            self.recharge_effect = 5;
          } else {
            return Some(GameResult::DeadEnd);
          }
        }
        _ => {
          unimplemented!();
        }
      }
    } else {
      return Some(GameResult::BossWin);
    }
    None
  }

  fn iterate(&mut self) -> Option<GameResult> {
    if let Some(result) = self.player_turn() {
      return Some(result);
    }
    if let Some(result) = self.boss_turn() {
      return Some(result);
    }
    None
  }

  fn play(&mut self) -> GameResult {
    //println!("Playing game with {:?}", self.movelist);
    while self.player_hp > 0 && self.boss_hp > 0 {
      if let Some(result) = self.iterate() {
        return result;
      }
    }
    if self.boss_hp <= 0 {
      //println!("  Player won!");
      GameResult::PlayerWin
    } else {
      //println!("  Boss won!");
      GameResult::BossWin
    }
  }
}

struct Solver {
  current: MoveList,
  future: BinaryHeap<MoveList>,
  boss_hp: Stat,
  boss_damage: Stat,
  part_two: bool,
}

impl Solver {
  fn new(boss_hp: Stat, boss_damage: Stat, part_two: bool) -> Self {
    Solver {
      current: MoveList::new(vec![]),
      future: BinaryHeap::new(),
      boss_hp: boss_hp,
      boss_damage: boss_damage,
      part_two: part_two,
    }
  }

  fn generate_next_moves(&mut self) {
    MOVES.iter().enumerate().for_each(|(i, _mov)| {
      let mut new_move_list = self.current.clone();
      new_move_list.push(i);
      self.future.push(new_move_list);
    });
  }

  fn next_move_list(&mut self) -> MoveList {
    self.future.pop().unwrap()
  }

  fn solve(&mut self) -> Stat {
    loop {
      match Game::new(self.boss_hp, self.boss_damage, &self.current, self.part_two).play() {
        GameResult::PlayerWin => {
          return self.current.cost;
        }
        GameResult::BossWin => {
          self.generate_next_moves();
        }
        GameResult::DeadEnd => {
          0;
        }
      }
      self.current = self.next_move_list();
    }
  }
}

fn part_one(lines: &Vec<String>) -> AocResult {
  let boss_hp: Stat = aoc::regex_captures("ts: (.*)", &lines[0])[0]
    .parse()
    .unwrap();
  let boss_damage: Stat = aoc::regex_captures("ge: (.*)", &lines[1])[0]
    .parse()
    .unwrap();

  let result = Solver::new(boss_hp, boss_damage, false).solve();
  AocResult::Number(result as i64)
}

fn part_two(lines: &Vec<String>) -> AocResult {
  let boss_hp: Stat = aoc::regex_captures("ts: (.*)", &lines[0])[0]
    .parse()
    .unwrap();
  let boss_damage: Stat = aoc::regex_captures("ge: (.*)", &lines[1])[0]
    .parse()
    .unwrap();

  let result = Solver::new(boss_hp, boss_damage, true).solve();
  AocResult::Number(result as i64)
}

pub fn main() {
  aoc::run(2015, 22, 1, part_one);
  aoc::run(2015, 22, 2, part_two);
}

#[cfg(test)]
mod tests {
  use super::*;
  #[test]
  fn test_game() {
    let movelist = MoveList {
      list: vec![3, 0, 2, 3, 4, 1, 3],
      cost: 987,
    };
    match Game::new(51, 9, &movelist, true).play() {
      GameResult::BossWin => assert!(true),
      _ => assert!(false),
    }
  }
}
