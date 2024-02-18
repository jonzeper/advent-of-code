extern crate fancy_regex;
use aoc::AocResult;
use fancy_regex::Regex;

type LightStatus = i32;

struct LightGrid {
  grid: [[LightStatus; 1000]; 1000],
}
impl LightGrid {
  fn new() -> Self {
    LightGrid {
      grid: [[0; 1000]; 1000],
    }
  }

  fn range_operation(
    &mut self,
    x1: usize,
    y1: usize,
    x2: usize,
    y2: usize,
    op: fn(&mut LightGrid, usize, usize),
  ) {
    for x in x1..x2 + 1 {
      for y in y1..y2 + 1 {
        op(self, x, y);
      }
    }
  }

  fn turn_on(lg: &mut LightGrid, x: usize, y: usize) {
    lg.grid[x][y] = 1;
  }

  fn turn_off(lg: &mut LightGrid, x: usize, y: usize) {
    lg.grid[x][y] = 0;
  }

  fn toggle(lg: &mut LightGrid, x: usize, y: usize) {
    lg.grid[x][y] = 1 - lg.grid[x][y];
  }

  fn turn_on_2(lg: &mut LightGrid, x: usize, y: usize) {
    lg.grid[x][y] += 1;
  }

  fn turn_off_2(lg: &mut LightGrid, x: usize, y: usize) {
    let next = lg.grid[x][y] - 1;
    lg.grid[x][y] = std::cmp::max(next, 0);
  }

  fn toggle_2(lg: &mut LightGrid, x: usize, y: usize) {
    lg.grid[x][y] += 2;
  }

  fn brightness(&self) -> LightStatus {
    self
      .grid
      .iter()
      .map(|row| row.iter().sum::<LightStatus>())
      .sum::<LightStatus>()
  }
}

enum CommandType {
  TurnOn,
  TurnOff,
  Toggle,
}
struct Command {
  command_type: CommandType,
  x1: usize,
  y1: usize,
  x2: usize,
  y2: usize,
}

impl Command {
  fn from_string(s: &String) -> Self {
    let re = Regex::new(r"(.*) (\d.*?),(\d.*?) through (\d.*?),(\d.*)").unwrap();
    let captures = re.captures(&s).unwrap().unwrap();
    let command_type = match captures.get(1).unwrap().as_str() {
      "toggle" => CommandType::Toggle,
      "turn on" => CommandType::TurnOn,
      "turn off" => CommandType::TurnOff,
      _ => unimplemented!(),
    };
    Command {
      command_type: command_type,
      x1: captures.get(2).unwrap().as_str().parse().unwrap(),
      y1: captures.get(3).unwrap().as_str().parse().unwrap(),
      x2: captures.get(4).unwrap().as_str().parse().unwrap(),
      y2: captures.get(5).unwrap().as_str().parse().unwrap(),
    }
  }
}

fn part_one(lines: &Vec<String>) -> AocResult {
  let mut lights = LightGrid::new();
  for c in lines.iter().map(Command::from_string) {
    match c.command_type {
      CommandType::TurnOn => lights.range_operation(c.x1, c.y1, c.x2, c.y2, LightGrid::turn_on),
      CommandType::TurnOff => lights.range_operation(c.x1, c.y1, c.x2, c.y2, LightGrid::turn_off),
      CommandType::Toggle => lights.range_operation(c.x1, c.y1, c.x2, c.y2, LightGrid::toggle),
    }
  }
  return AocResult::Number(lights.brightness() as i64);
}

fn part_two(lines: &Vec<String>) -> AocResult {
  let mut lights = LightGrid::new();
  for c in lines.iter().map(Command::from_string) {
    match c.command_type {
      CommandType::TurnOn => lights.range_operation(c.x1, c.y1, c.x2, c.y2, LightGrid::turn_on_2),
      CommandType::TurnOff => lights.range_operation(c.x1, c.y1, c.x2, c.y2, LightGrid::turn_off_2),
      CommandType::Toggle => lights.range_operation(c.x1, c.y1, c.x2, c.y2, LightGrid::toggle_2),
    }
  }
  return AocResult::Number(lights.brightness() as i64);
}

pub fn main() {
  aoc::run(2015, 6, 1, part_one);
  aoc::run(2015, 6, 2, part_two);
}
