use std::collections::HashMap;

pub type Token = u64;

pub struct TokenDict {
  by_name: HashMap<String, Token>,
  by_id: HashMap<Token, String>,
  counter: Token,
}

impl TokenDict {
  pub fn new() -> Self {
    TokenDict {
      by_name: HashMap::new(),
      by_id: HashMap::new(),
      counter: 0,
    }
  }

  pub fn tokenize(&mut self, name: &str) -> Token {
    match self.by_name.get(name) {
      Some(id) => *id,
      None => {
        self.by_name.insert(name.to_string(), self.counter);
        self.by_id.insert(self.counter, name.to_string());
        self.counter += 1;
        self.counter - 1
      }
    }
  }

  pub fn get_name(&self, id: Token) -> &String {
    self
      .by_id
      .get(&id)
      .expect("TokenDict called with invalid id!")
  }
}
