use aoc::AocResult;

type LightStatus = bool;
type Grid = Vec<Vec<LightStatus>>;
type Point = (i8, i8);

const GRID_SIZE: i8 = 100;
const LIGHT_ON: LightStatus = true;
const LIGHT_OFF: LightStatus = false;

struct Lighting {
  grid: Grid,
  stuck_corners: bool, // true for part two
}

impl Lighting {
  fn new(stuck_corners: bool) -> Self {
    Lighting {
      grid: empty_grid(),
      stuck_corners: stuck_corners,
    }
  }

  fn from_lines(lines: &Vec<String>, stuck_corners: bool) -> Self {
    let mut lighting = Self::new(stuck_corners);
    for (x, line) in lines.iter().enumerate() {
      for (y, c) in line.chars().enumerate() {
        lighting.grid[x][y] = match c {
          '.' => false,
          '#' => true,
          _ => true,
        }
      }
    }
    if stuck_corners {
      lighting.grid[0][0] = LIGHT_ON;
      lighting.grid[0][GRID_SIZE as usize - 1] = LIGHT_ON;
      lighting.grid[GRID_SIZE as usize - 1][0] = LIGHT_ON;
      lighting.grid[GRID_SIZE as usize - 1][GRID_SIZE as usize - 1] = LIGHT_ON;
    }
    lighting
  }

  fn get(&self, pt: Point) -> LightStatus {
    let (x, y) = pt;
    if x < 0 || y < 0 || x >= GRID_SIZE || y >= GRID_SIZE {
      LIGHT_OFF
    } else {
      self.grid[x as usize][y as usize]
    }
  }

  fn count_on_neighbors(&self, pt: Point) -> usize {
    let (x, y) = pt;
    (0..3)
      .map(|x_offset| {
        (0..3)
          .filter(|y_offset| {
            (!(x_offset == 1 && *y_offset == 1))
              && self.get((x + x_offset - 1, y + y_offset - 1)) == LIGHT_ON
          })
          .count()
      })
      .sum()
  }

  fn iterate(&mut self) {
    let mut next_grid = self.grid.clone();
    for x in 0..GRID_SIZE {
      for y in 0..GRID_SIZE {
        let n_on_neighbors = self.count_on_neighbors((x, y));
        let status = self.get((x, y));
        if status == LIGHT_ON && !(n_on_neighbors == 2 || n_on_neighbors == 3) {
          next_grid[x as usize][y as usize] = LIGHT_OFF;
        }
        if status == LIGHT_OFF && n_on_neighbors == 3 {
          next_grid[x as usize][y as usize] = LIGHT_ON;
        }
      }
    }
    if self.stuck_corners {
      next_grid[0][0] = LIGHT_ON;
      next_grid[0][GRID_SIZE as usize - 1] = LIGHT_ON;
      next_grid[GRID_SIZE as usize - 1][0] = LIGHT_ON;
      next_grid[GRID_SIZE as usize - 1][GRID_SIZE as usize - 1] = LIGHT_ON;
    }
    self.grid = next_grid;
  }

  fn count_on(&self) -> i64 {
    (0..GRID_SIZE)
      .map(|x| {
        (0..GRID_SIZE)
          .filter(|y| self.get((x, *y)) == LIGHT_ON)
          .count() as i64
      })
      .sum()
  }
}

fn empty_grid() -> Grid {
  vec![vec![false; GRID_SIZE as usize]; GRID_SIZE as usize]
}

fn part_one(lines: &Vec<String>) -> AocResult {
  let mut grid = Lighting::from_lines(lines, false);
  for _ in 0..100 {
    grid.iterate();
  }
  AocResult::Number(grid.count_on())
}

fn part_two(lines: &Vec<String>) -> AocResult {
  let mut grid = Lighting::from_lines(lines, true);
  for _ in 0..100 {
    grid.iterate();
  }
  AocResult::Number(grid.count_on())
}

pub fn main() {
  aoc::run(2015, 18, 1, part_one);
  aoc::run(2015, 18, 2, part_two);
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn test_part_one() {
    let lines = vec![
      ".#.#.#".to_string(),
      "...##.".to_string(),
      "#....#".to_string(),
      "..#...".to_string(),
      "#.#..#".to_string(),
      "####..".to_string(),
    ];
    let lighting = Lighting::from_lines(&lines, false);

    assert_eq!(lighting.count_on_neighbors((0, 0)), 1);
    assert_eq!(lighting.count_on_neighbors((0, 5)), 1);
    assert_eq!(lighting.count_on_neighbors((5, 0)), 2);
    assert_eq!(lighting.count_on_neighbors((5, 5)), 1);
    assert_eq!(lighting.count_on(), 15);
  }
}
