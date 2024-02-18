use aoc::AocResult;
use regex::Regex;
use std::collections::HashMap;

type WireId = String;
type WireVal = u16;

#[derive(Debug)]
enum WireInputPart {
  Val(WireVal),
  Wire(WireId),
}

#[derive(Debug)]
enum WireInput {
  Val(WireInputPart),
  And(WireInputPart, WireInputPart),
  Or(WireInputPart, WireInputPart),
  Not(WireInputPart),
  Lshift(WireInputPart, u32),
  Rshift(WireInputPart, u32),
}

#[derive(Debug)]
struct Wire {
  input: WireInput,
}

impl Wire {
  fn new(input: WireInput) -> Self {
    Wire { input: input }
  }
}

#[derive(Debug)]
struct Wiring {
  wires: HashMap<WireId, Wire>,
}

impl Wiring {
  fn new() -> Self {
    Wiring {
      wires: HashMap::new(),
    }
  }

  fn add_from_line(&mut self, line: &str) {
    let op_re = Regex::new(r"(AND|OR|NOT|LSHIFT|RSHIFT)").unwrap();
    match op_re.captures(line) {
      Some(x) => match x.get(0).unwrap().as_str() {
        "AND" => {
          self.add_and(line);
        }
        "OR" => {
          self.add_or(line);
        }
        "NOT" => {
          self.add_not(line);
        }
        "LSHIFT" => {
          self.add_lshift(line);
        }
        "RSHIFT" => {
          self.add_rshift(line);
        }
        _ => {
          0;
        }
      },
      None => {
        self.add_store(line);
      }
    }
  }

  fn add_lshift(&mut self, line: &str) {
    let re = Regex::new(r"(.*) LSHIFT (.*) -> (.*)").unwrap();
    let captures = re.captures(line).unwrap();
    let a = captures.get(1).unwrap().as_str().to_string();
    let b = captures.get(2).unwrap().as_str().parse::<u32>().unwrap();
    let target = captures.get(3).unwrap().as_str().to_string();
    self
      .wires
      .insert(target, Wire::new(WireInput::Lshift(parse_input_part(a), b)));
  }

  fn add_rshift(&mut self, line: &str) {
    let re = Regex::new(r"(.*) RSHIFT (.*) -> (.*)").unwrap();
    let captures = re.captures(line).unwrap();
    let a = captures.get(1).unwrap().as_str().to_string();
    let b = captures.get(2).unwrap().as_str().parse::<u32>().unwrap();
    let target = captures.get(3).unwrap().as_str().to_string();
    self
      .wires
      .insert(target, Wire::new(WireInput::Rshift(parse_input_part(a), b)));
  }

  fn add_and(&mut self, line: &str) {
    let re = Regex::new(r"(.*) AND (.*) -> (.*)").unwrap();
    let captures = re.captures(line).unwrap();
    let a = captures.get(1).unwrap().as_str().to_string();
    let b = captures.get(2).unwrap().as_str().to_string();
    let target = captures.get(3).unwrap().as_str().to_string();
    self.wires.insert(
      target,
      Wire::new(WireInput::And(parse_input_part(a), parse_input_part(b))),
    );
  }

  fn add_or(&mut self, line: &str) {
    let re = Regex::new(r"(.*) OR (.*) -> (.*)").unwrap();
    let captures = re.captures(line).unwrap();
    let a = captures.get(1).unwrap().as_str().to_string();
    let b = captures.get(2).unwrap().as_str().to_string();
    let target = captures.get(3).unwrap().as_str().to_string();
    self.wires.insert(
      target,
      Wire::new(WireInput::Or(parse_input_part(a), parse_input_part(b))),
    );
  }

  fn add_not(&mut self, line: &str) {
    let re = Regex::new(r"NOT (.*) -> (.*)").unwrap();
    let captures = re.captures(line).unwrap();
    let a = captures.get(1).unwrap().as_str().to_string();
    let target = captures.get(2).unwrap().as_str().to_string();
    self
      .wires
      .insert(target, Wire::new(WireInput::Not(parse_input_part(a))));
  }

  fn add_store(&mut self, line: &str) {
    let re = Regex::new(r"(.*) -> (.*)").unwrap();
    let captures = re.captures(line).unwrap();
    let a = captures.get(1).unwrap().as_str().to_string();
    let target = captures.get(2).unwrap().as_str().to_string();
    self
      .wires
      .insert(target, Wire::new(WireInput::Val(parse_input_part(a))));
  }
}

fn eval_wire(wiring: &Wiring, wire_id: &str, known_vals: &mut HashMap<WireId, WireVal>) -> WireVal {
  // println!("Evaling {}", wire_id);
  match known_vals.get(wire_id) {
    Some(x) => *x,
    None => {
      let val = match &wiring.wires.get(wire_id).unwrap().input {
        WireInput::Val(a) => eval_input(wiring, &a, known_vals),
        WireInput::And(a, b) => {
          eval_input(wiring, &a, known_vals) & eval_input(wiring, &b, known_vals)
        }
        WireInput::Or(a, b) => {
          eval_input(wiring, &a, known_vals) | eval_input(wiring, &b, known_vals)
        }
        WireInput::Not(a) => !eval_input(wiring, &a, known_vals),
        WireInput::Lshift(a, x) => eval_input(wiring, &a, known_vals) << x,
        WireInput::Rshift(a, x) => eval_input(wiring, &a, known_vals) >> x,
      };
      known_vals.insert(wire_id.to_string(), val);
      val
    }
  }
}

fn eval_input(
  wiring: &Wiring,
  input: &WireInputPart,
  known_vals: &mut HashMap<WireId, WireVal>,
) -> WireVal {
  match input {
    WireInputPart::Val(x) => *x,
    WireInputPart::Wire(a) => eval_wire(wiring, &a, known_vals),
  }
}

fn parse_input_part(part: String) -> WireInputPart {
  match part.parse::<WireVal>() {
    Ok(x) => WireInputPart::Val(x),
    Err(_) => WireInputPart::Wire(part),
  }
}

fn part_one(lines: &Vec<String>) -> AocResult {
  let mut wiring = Wiring::new();
  let mut known_vals = HashMap::new();
  for line in lines {
    wiring.add_from_line(line)
  }
  AocResult::Number(eval_wire(&wiring, "a", &mut known_vals) as i64)
}

// Same algo, with input edited to remove the ### -> b and replace it with
// 46065 -> b, where 46065 is the answer to part one
fn part_two(lines: &Vec<String>) -> AocResult {
  part_one(lines)
}

pub fn main() {
  aoc::run(2015, 7, 1, part_one);
  aoc::run(2015, 7, 2, part_two);
}
