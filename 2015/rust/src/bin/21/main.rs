use aoc::AocResult;

type Stat = i16;
enum GameResult {
  PlayerWon(u32),
  BossWon(u32),
}

const STARTING_HP: Stat = 100;

struct Fighter {
  hp: Stat,
  damage: Stat,
  armor: Stat,
}

impl Fighter {
  fn new(damage: Stat, armor: Stat) -> Self {
    Fighter {
      hp: STARTING_HP,
      damage: damage,
      armor: armor,
    }
  }
}

struct Game {
  boss: Fighter,
  player: Fighter,
}

impl Game {
  fn new(player_damage: Stat, player_armor: Stat) -> Self {
    Game {
      boss: Fighter::new(8, 2),
      player: Fighter::new(player_damage, player_armor),
    }
  }

  fn iterate(&mut self) {
    self.boss.hp -= std::cmp::max(1, self.player.damage - self.boss.armor);
    self.player.hp -= std::cmp::max(1, self.boss.damage - self.player.armor);
  }

  fn play(&mut self) -> GameResult {
    let mut round = 1;
    loop {
      self.iterate();
      if self.boss.hp <= 0 {
        return GameResult::PlayerWon(round);
      }
      if self.player.hp <= 0 {
        return GameResult::BossWon(round);
      }
      round += 1;
    }
  }
}

#[derive(Debug, PartialEq)]
struct Equipment {
  cost: Stat,
  damage: Stat,
  armor: Stat,
}

impl Equipment {
  fn from_line(line: &String) -> Self {
    let re = regex::Regex::new(r".*\s+(\d+)\s+(\d)\s+(\d)").unwrap();
    let caps = re.captures(line).unwrap();
    Equipment {
      cost: caps.get(1).unwrap().as_str().parse().unwrap(),
      damage: caps.get(2).unwrap().as_str().parse().unwrap(),
      armor: caps.get(3).unwrap().as_str().parse().unwrap(),
    }
  }
}

fn part_one(lines: &Vec<String>) -> AocResult {
  let chunks = aoc::chunk_lines(lines);

  let mut game = Game::new(9, 0);
  match game.play() {
    GameResult::PlayerWon(rounds) => {
      println!("Player won in {} rounds", rounds);
    }
    GameResult::BossWon(rounds) => {
      println!("Boss won in {} rounds", rounds);
    }
  }

  AocResult::Number(0)
}

fn part_two(lines: &Vec<String>) -> AocResult {
  // 138 6,3 too low
  let chunks = aoc::chunk_lines(lines);
  let weapons: Vec<Equipment> = chunks[0][1..].iter().map(Equipment::from_line).collect();
  let mut armors: Vec<Equipment> = chunks[1][1..].iter().map(Equipment::from_line).collect();
  armors.push(Equipment {
    cost: 0,
    damage: 0,
    armor: 0,
  });
  let mut rings: Vec<Equipment> = chunks[2][1..].iter().map(Equipment::from_line).collect();
  rings.push(Equipment {
    cost: 0,
    damage: 0,
    armor: 0,
  });
  rings.push(Equipment {
    cost: 0,
    damage: 0,
    armor: 0,
  });
  let mut wins: Vec<Stat> = vec![];

  for weapon in weapons {
    for armor in &armors {
      for ring1 in &rings {
        for ring2 in rings.iter().filter(|ring| *ring != ring1) {
          let cost = weapon.cost + armor.cost + ring1.cost + ring2.cost;
          let damage = weapon.damage + armor.damage + ring1.damage + ring2.damage;
          let armor = weapon.armor + armor.armor + ring1.armor + ring2.armor;
          if let GameResult::BossWon(_) = Game::new(damage, armor).play() {
            wins.push(cost);
          }
        }
      }
    }
  }
  AocResult::Number(*wins.iter().max().unwrap() as i64)
}

pub fn main() {
  aoc::run(2015, 21, 1, part_one);
  aoc::run(2015, 21, 2, part_two);
}
