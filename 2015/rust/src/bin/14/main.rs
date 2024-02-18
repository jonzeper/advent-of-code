use aoc::AocResult;
use regex::Regex;

fn dist_after(data: (i64, i64, i64), time: i64) -> i64 {
  let (spd, fly_d, rest_d) = data;
  let full_intervals = time / (fly_d + rest_d);
  let rem_time = time - full_intervals * (fly_d + rest_d);
  full_intervals * spd * fly_d + std::cmp::min(fly_d, rem_time) * spd
}

fn parse_input(lines: &Vec<String>) -> Vec<(i64, i64, i64)> {
  let re =
    Regex::new(r"(.*) can fly (.*) km/s for (.*) seconds, but then must rest for (.*) seconds\.")
      .unwrap();
  lines
    .iter()
    .map(|line| {
      let caps = re.captures(line).unwrap();
      let speed: i64 = caps.get(2).unwrap().as_str().parse().unwrap();
      let fly_duration: i64 = caps.get(3).unwrap().as_str().parse().unwrap();
      let rest_duration: i64 = caps.get(4).unwrap().as_str().parse().unwrap();
      (speed, fly_duration, rest_duration)
    })
    .collect()
}

fn part_one(lines: &Vec<String>) -> AocResult {
  let data = parse_input(lines);
  let result = data.iter().map(|d| dist_after(*d, 2503)).max().unwrap();
  AocResult::Number(result)
}

struct Reindeer {
  speed: i64,
  fly_duration: i64,
  rest_duration: i64,
  points: i64,
  position: i64,
  fly_remaining: i64,
  rest_remaining: i64,
}
impl Reindeer {
  fn new(speed: i64, fly_duration: i64, rest_duration: i64) -> Self {
    Reindeer {
      speed: speed,
      fly_duration: fly_duration,
      rest_duration: rest_duration,
      points: 0,
      position: 0,
      fly_remaining: fly_duration,
      rest_remaining: 0,
    }
  }

  fn step(&mut self) {
    if self.fly_remaining > 0 {
      self.position += self.speed;
      self.fly_remaining -= 1;
      if self.fly_remaining == 0 {
        self.rest_remaining = self.rest_duration;
      }
    } else {
      self.rest_remaining -= 1;
      if self.rest_remaining == 0 {
        self.fly_remaining = self.fly_duration;
      }
    }
  }
}

fn part_two(lines: &Vec<String>) -> AocResult {
  let data = parse_input(lines);
  let mut reindeers: Vec<Reindeer> = data
    .iter()
    .map(|(spd, fly_d, rest_d)| Reindeer::new(*spd, *fly_d, *rest_d))
    .collect();
  for _ in 0..2503 {
    for reindeer in reindeers.iter_mut() {
      reindeer.step()
    }
    let winning = reindeers.iter().map(|r| r.position).max().unwrap();
    for reindeer in reindeers.iter_mut() {
      if reindeer.position == winning {
        reindeer.points += 1;
      }
    }
  }
  let winner = reindeers.iter().map(|r| r.points).max().unwrap();
  AocResult::Number(winner)
}

pub fn main() {
  aoc::run(2015, 14, 1, part_one);
  aoc::run(2015, 14, 2, part_two);
}
