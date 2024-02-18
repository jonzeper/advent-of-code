use aoc::token_dict::{Token, TokenDict};
use aoc::AocResult;
use regex::Regex;
use std::collections::{HashMap, HashSet};

type NodeId = Token;
type EdgeWeight = u32;

struct Graph {
  g: HashMap<NodeId, HashMap<NodeId, EdgeWeight>>,
}
impl Graph {
  fn new() -> Self {
    Graph { g: HashMap::new() }
  }

  fn edge_weight(&self, a: NodeId, b: NodeId) -> EdgeWeight {
    *self.g.get(&a).unwrap().get(&b).unwrap()
  }

  fn add(&mut self, a: NodeId, b: NodeId, i: EdgeWeight) {
    match self.g.get_mut(&a) {
      Some(a_edges) => {
        a_edges.insert(b, i);
      }
      None => {
        let mut a_edges = HashMap::new();
        a_edges.insert(b, i);
        self.g.insert(a, a_edges);
      }
    }
    match self.g.get_mut(&b) {
      Some(b_edges) => {
        b_edges.insert(a, i);
      }
      None => {
        let mut b_edges = HashMap::new();
        b_edges.insert(a, i);
        self.g.insert(b, b_edges);
      }
    }
  }
}

struct Solver {
  best: EdgeWeight,
  tokens: TokenDict,
  g: Graph,
}

impl Solver {
  fn new(initial_best: EdgeWeight) -> Self {
    Solver {
      best: initial_best,
      tokens: TokenDict::new(),
      g: Graph::new(),
    }
  }

  fn add_line(&mut self, line: &String) {
    let re = Regex::new(r"(.*) to (.*) = (.*)").unwrap();
    let caps = re.captures(line).unwrap();
    let a = self.tokens.tokenize(caps.get(1).unwrap().as_str());
    let b = self.tokens.tokenize(caps.get(2).unwrap().as_str());
    let i = caps.get(3).unwrap().as_str().parse::<EdgeWeight>().unwrap();
    self.g.add(a, b, i);
  }

  fn solve(
    &mut self,
    node_ids: HashSet<NodeId>,
    best_cmp: fn(EdgeWeight, EdgeWeight) -> bool,
  ) -> EdgeWeight {
    for node_id in node_ids.iter() {
      let mut rem_nodes = node_ids.iter().copied().collect::<HashSet<_>>();
      rem_nodes.remove(&node_id);
      self._solve(vec![*node_id], *node_id, 0, rem_nodes, best_cmp);
    }
    return self.best;
  }

  fn _solve(
    &mut self,
    path: Vec<NodeId>,
    last_node: NodeId,
    path_weight: EdgeWeight,
    nodes_left: HashSet<NodeId>,
    best_cmp: fn(EdgeWeight, EdgeWeight) -> bool,
  ) {
    if nodes_left.is_empty() {
      self.best = if best_cmp(path_weight, self.best) {
        path_weight
      } else {
        self.best
      }
    } else {
      for next_id in &nodes_left {
        let mut next_path = path.clone();
        next_path.push(*next_id);
        let mut next_remaining = nodes_left.clone();
        next_remaining.remove(next_id);
        self._solve(
          next_path,
          *next_id,
          path_weight + self.g.edge_weight(last_node, *next_id),
          next_remaining,
          best_cmp,
        );
      }
    }
  }
}

fn part_one(lines: &Vec<String>) -> AocResult {
  let mut solver = Solver::new(EdgeWeight::MAX);
  for line in lines {
    solver.add_line(line);
  }
  let node_ids = { solver.g.g.keys().map(|s| s.clone()).collect::<HashSet<_>>() };
  let result = solver.solve(node_ids, |a, b| a < b);
  AocResult::Number(result as i64)
}

fn part_two(lines: &Vec<String>) -> AocResult {
  let mut solver = Solver::new(EdgeWeight::MIN);
  for line in lines {
    solver.add_line(line);
  }
  let node_ids = { solver.g.g.keys().map(|s| s.clone()).collect::<HashSet<_>>() };
  let result = solver.solve(node_ids, |a, b| a > b);
  AocResult::Number(result as i64)
}

pub fn main() {
  aoc::run(2015, 9, 1, part_one);
  aoc::run(2015, 9, 2, part_two);
}
