use std::fs;
use regex::Regex;

fn parse_next_number(line: &str, position: usize) -> Option<(usize, usize, usize)> {
    let re = Regex::new(r"\d+").unwrap();
    if position >= line.len() {
        return None;
    }
    if let Some(mat) = re.find(&line[position..]) {
        let start_index = mat.start() + position;
        let end_index = mat.end() + position;
        let number = mat.as_str().parse::<usize>().unwrap();
        Some((start_index, end_index, number))
    } else {
        None
    }
}

fn find_symbols(line_index: usize, lines: &Vec<&str>, start_index: usize, end_index: usize, check_for_symbol: fn (char) -> bool) -> Vec<(usize, usize)> {
    let mut candidates: Vec<(usize, usize)> = Vec::new();
    let current_line = lines[line_index];
    if start_index > 0 {
        let char_before = current_line.chars().nth(start_index-1).unwrap();
        if check_for_symbol(char_before) {
            candidates.push((line_index, start_index-1));
        }
    }
    if end_index < current_line.len() {
        let char_after = current_line.chars().nth(end_index).unwrap();
        if check_for_symbol(char_after) {
            candidates.push((line_index, end_index));
        }
    }
    let start: usize = if start_index > 0 { start_index - 1 } else { start_index };
    let end: usize = if end_index < current_line.len() { end_index + 1 } else { end_index };
    if line_index > 0 {
        let previous_line = &lines[line_index-1][start..end];
        for (index, character) in previous_line.chars().enumerate() {
            if check_for_symbol(character) {
                candidates.push((line_index-1, start+index));
            }
        }
    }
    if line_index + 1 < lines.len() {
        let next_line = &lines[line_index+1][start..end];
        for (index, character) in next_line.chars().enumerate() {
            if check_for_symbol(character) {
                candidates.push((line_index+1, start+index));
            }
        }
    }
    candidates
}

fn is_symbol(character: char) -> bool {
    character != '.'
}

fn is_part_number(line_index: usize, lines: &Vec<&str>, start_index: usize, end_index: usize) -> bool {
    let symbols = find_symbols(line_index, lines, start_index, end_index, is_symbol);
    return symbols.len() > 0;
}

fn part1(filepath: &str) -> usize {
    let input = fs::read_to_string(filepath)
        .expect(&format!("Couldn't read the file '{}'", filepath));
    let mut sum: usize = 0;
    let lines: Vec<&str> = input.lines().collect();
    for (line_index, line) in lines.iter().enumerate() {
        let mut pos: usize = 0;
        while let Some((start_index, end_index, number)) = parse_next_number(line, pos) {
            if is_part_number(line_index, &lines, start_index, end_index) {
                sum += number;
            }
            pos = end_index + 1;
        }
    }
    return sum;
}

fn is_gear_candidate(character: char) -> bool {
    character == '*'
}

fn find_gear_candidates(line_index: usize, lines: &Vec<&str>, start_index: usize, end_index: usize) -> Vec<(usize, usize)> {
    find_symbols(line_index, lines, start_index, end_index, is_gear_candidate)
}

fn part2(filepath: &str) -> usize {
    let input = fs::read_to_string(filepath)
        .expect(&format!("Couldn't read the file '{}'", filepath));
    let lines: Vec<&str> = input.lines().collect();
    let mut gear_ratio: usize = 0;
    let mut gear_candidates: Vec<(usize, (usize, usize))> = Vec::new();
    for (line_index, line) in lines.iter().enumerate() {
        let mut pos: usize = 0;
        while let Some((start_index, end_index, number)) = parse_next_number(line, pos) {
            for candidate_pos in find_gear_candidates(line_index, &lines, start_index, end_index) {
                if let Some(gear_index) = gear_candidates.iter().position(|(_, gear_pos)| gear_pos == &candidate_pos) {
                    let (previous_number, _) = gear_candidates.remove(gear_index);
                    gear_ratio += previous_number * number;
                } else {
                    gear_candidates.push((number, candidate_pos));
                }
            }
            pos = end_index + 1;
        }
    }
    return gear_ratio;
}

fn main() {
    println!("part1: {}", part1("input.txt"));
    println!("part2: {}", part2("input.txt"));
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part1() {
        assert_eq!(part1("sample.txt"), 4361);
    }

    #[test]
    fn result_part1() {
        assert_eq!(part1("input.txt"), 537732);
    }
    
    #[test]
    fn test_part2() {
        assert_eq!(part2("sample.txt"), 467835);
    }

    #[test]
    fn result_part2() {
        assert_eq!(part2("input.txt"), 84883664);
    }
}
