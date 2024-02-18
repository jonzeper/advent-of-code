use aoc::AocResult;

const A: u8 = 97;
const I: u8 = 105;
const L: u8 = 108;
const O: u8 = 111;
const Z: u8 = 122;

type Password = Vec<u8>;

fn increment_char(c: u8) -> (u8, bool) {
  if c == Z {
    (A, true)
  } else {
    if c == I - 1 || c == L - 1 || c == O - 1 {
      (c + 2, false)
    } else {
      (c + 1, false)
    }
  }
}

fn increment_password(s: &mut Password) {
  let last_c = s.pop().unwrap();
  let (new_c, wrapped) = increment_char(last_c);
  if wrapped {
    increment_password(s);
    s.push(new_c);
  } else {
    s.push(new_c);
  }
}

fn str_as_pwd(s: &str) -> Password {
  s.chars().map(|c| c as u8).collect::<Password>()
}

fn pwd_as_str(ints: &Password) -> &str {
  std::str::from_utf8(ints).unwrap()
}

fn contains_run(pwd: &Password) -> bool {
  let mut last_c: u8 = 0;
  let mut run_size = 0;
  for c in pwd {
    if *c == last_c + 1 {
      run_size += 1;
      if run_size == 3 {
        return true;
      }
    } else {
      run_size = 1;
    }
    last_c = *c;
  }
  false
}

fn contains_doubles(pwd: &Password) -> bool {
  let mut last_c: u8 = 0;
  let mut first_double: u8 = 0;
  let mut found_doubles = 0;
  for c in pwd {
    if *c == last_c && *c != first_double {
      found_doubles += 1;
      if found_doubles == 2 {
        return true;
      }
      first_double = *c;
    }
    last_c = *c;
  }
  false
}

fn is_valid(pwd: &Password) -> bool {
  // Cheating a bit here, assuming the initial password is valid
  // so we don't have to check for 'i's, 'o's, or 'l's
  contains_run(pwd) && contains_doubles(pwd)
}

fn part_one(lines: &Vec<String>) -> AocResult {
  let mut pwd = str_as_pwd(&lines[0]);
  increment_password(&mut pwd);
  while !is_valid(&pwd) {
    increment_password(&mut pwd);
  }
  AocResult::String(pwd_as_str(&pwd).to_string())
}

fn part_two(lines: &Vec<String>) -> AocResult {
  let mut pwd = str_as_pwd(&lines[0]);
  increment_password(&mut pwd);
  while !is_valid(&pwd) {
    increment_password(&mut pwd);
  }
  increment_password(&mut pwd);
  while !is_valid(&pwd) {
    increment_password(&mut pwd);
  }
  AocResult::String(pwd_as_str(&pwd).to_string())
}

pub fn main() {
  aoc::run(2015, 11, 1, part_one);
  aoc::run(2015, 11, 2, part_two);
}

#[cfg(test)]
mod tests {
  use super::*;
  #[test]
  fn test_increment_password() {
    let mut pwd = str_as_pwd(&"foo".to_string());
    increment_password(&mut pwd);
    assert_eq!("fop", pwd_as_str(&pwd));
  }

  #[test]
  fn test_increment_password_wraps() {
    let mut pwd = str_as_pwd(&"foz".to_string());
    increment_password(&mut pwd);
    assert_eq!("fpa", pwd_as_str(&pwd));
  }

  #[test]
  fn test_increment_password_skips() {
    let mut pwd = str_as_pwd(&"foh".to_string());
    increment_password(&mut pwd);
    assert_eq!("foj", pwd_as_str(&pwd));
  }

  #[test]
  fn test_contains_run() {
    let pwd = str_as_pwd("abc");
    assert_eq!(contains_run(&pwd), true);

    let pwd = str_as_pwd("acdabcacd");
    assert_eq!(contains_run(&pwd), true);

    let pwd = str_as_pwd("acdefgcd");
    assert_eq!(contains_run(&pwd), true);

    let pwd = str_as_pwd("abeftu");
    assert_eq!(contains_run(&pwd), false);
  }

  #[test]
  fn test_contains_doubles() {
    let pwd = str_as_pwd("fghfgh");
    assert_eq!(contains_doubles(&pwd), false);

    let pwd = str_as_pwd("aaaa");
    assert_eq!(contains_doubles(&pwd), false);

    let pwd = str_as_pwd("aayy");
    assert_eq!(contains_doubles(&pwd), true);

    let pwd = str_as_pwd("aahgfhjgfyy");
    assert_eq!(contains_doubles(&pwd), true);
  }
}
