use ansi_term::Colour::Green;
use ansi_term::Colour::Red;
use std::fs;
extern crate yaml_rust;
use yaml_rust::yaml;
use yaml_rust::{Yaml, YamlLoader};

pub mod token_dict;

pub enum AocResult {
    String(String),
    Number(i64),
}

fn load_test_cases(year: u32, day: u32, part_num: u32) -> yaml::Hash {
    let filepath = format!("../../inputs/{}/{:02}/test.yaml", year, day);
    let contents = fs::read_to_string(filepath).expect("test.yaml not found");
    let yaml = YamlLoader::load_from_str(&contents).expect("Invalid test.yaml");
    let part_id = match part_num {
        1 => "part_1",
        2 => "part_2",
        _ => "part_1",
    };
    let test_cases_yaml = yaml[0][part_id]
        .as_hash()
        .expect("Unable to find part_x in test.yaml");
    return test_cases_yaml.clone();
}

fn read_lines(year: u32, day: u32, filename: &str) -> Vec<String> {
    let fullpath = format!("../../inputs/{}/{:02}/{}", year, day, filename);
    let contents = fs::read_to_string(fullpath).unwrap();
    return contents
        .lines()
        .map(std::string::ToString::to_string)
        .collect();
}

/// Split a vec of Strings into chunks split by newlines
/// Assumes the last line is a newline
// TODO: Return slices without new allocations
pub fn chunk_lines(lines: &Vec<String>) -> Vec<Vec<String>> {
    let mut chunks: Vec<Vec<String>> = vec![];
    let mut current_chunk: Vec<String> = vec![];
    for line in lines {
        if line == "" {
            chunks.push(current_chunk);
            current_chunk = vec![];
        } else {
            current_chunk.push(line.clone());
        }
    }
    if current_chunk.len() > 0 {
        chunks.push(current_chunk);
    }
    chunks
}

pub fn run(year: u32, day: u32, part_num: u32, solution: fn(&Vec<String>) -> AocResult) {
    println!("\nRunning _{}_{:02} part {}", year, day, part_num);
    let test_cases = load_test_cases(year, day, part_num);
    for (test_input, expected_result) in test_cases {
        let test_input_str = test_input.as_str().expect("Invalid test input!");
        let input_lines = if test_input_str.ends_with(".txt") {
            read_lines(year, day, test_input_str)
        } else {
            vec![String::from(test_input_str)]
        };
        let now = std::time::Instant::now();
        let result_str = match solution(&input_lines) {
            AocResult::String(s) => s,
            AocResult::Number(i) => format!("{}", i),
        };
        let elapsed = now.elapsed();
        let expected_result_str: String = match expected_result {
            Yaml::Integer(i) => format!("{}", i),
            Yaml::String(s) => s,
            _ => String::from(""),
        };
        let success_indicator = if result_str == expected_result_str {
            Green.paint("√")
        } else {
            Red.paint("✗")
        };
        let expectation_correction = if result_str == expected_result_str {
            String::from("")
        } else {
            format!(" (should be {})", expected_result_str)
        };
        println!(
            " {} {}: {}{}    [done in {}ms]",
            success_indicator,
            test_input_str,
            result_str,
            expectation_correction,
            elapsed.as_millis()
        );
    }
}

pub fn run_x_times(year: u32, day: u32, solution: fn(&Vec<String>) -> AocResult, x_count: u32) {
    let lines = read_lines(year, day, "input.txt");
    let start = std::time::Instant::now();
    for _ in 0..x_count {
        solution(&lines);
    }
    let duration = start.elapsed();
    println!("Done in {:?}", duration);
}

pub fn regex_captures(re_str: &str, target: &str) -> Vec<String> {
    let re = regex::Regex::new(re_str).unwrap();
    let caps = re.captures(target).unwrap();
    let mut matches = caps
        .iter()
        .map(|matc| matc.unwrap().as_str().to_string())
        .collect::<Vec<String>>();
    matches.remove(0);
    matches
}
