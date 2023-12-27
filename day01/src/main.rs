use std::fs;

fn get_digit(line: &str, reverse: bool) -> (usize, usize) {
    let iterator: Box<dyn Iterator<Item = char>> = if reverse {
        Box::new(line.chars().rev())
    } else { 
        Box::new(line.chars())
    };
    for (index, character) in iterator.enumerate() {
        if character.is_digit(10) {
            let pos = if reverse { line.len() - 1 - index } else { index };
            return (pos, character.to_string().parse::<usize>().unwrap());
        }
    }
    return if reverse { (0, 0) } else { (line.len(), 0) };
}

fn get_value_from_line(line: &str) -> usize {
    let (_, first) = get_digit(line, false);
    let (_, second) = get_digit(line, true);
    return first * 10 + second;
}

fn part1(filepath: &str) -> usize {
    let input = fs::read_to_string(filepath)
        .expect(&format!("Couldn't read the file '{}'", filepath));
    let mut sum: usize = 0;
    for line in input.lines() {
        sum += get_value_from_line(line);
    }
    return sum;
}

fn get_number(line: &str, reverse: bool) -> usize {
    let numbers = &["zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"];
    let (mut current_pos, mut current_value) = get_digit(line, reverse);
    for (index, number) in numbers.iter().enumerate() {
        let found = if reverse { line.rfind(number) } else { line.find(number) };
        if found.is_some() {
            let found_pos = found.unwrap();
            let condition: bool = (found_pos < current_pos) ^ reverse;
            if condition {
                (current_pos, current_value) = (found_pos, index);
            }
        }
    }
    return current_value;
}

fn part2(filepath: &str) -> usize {
    let input = fs::read_to_string(filepath)
        .expect(&format!("Couldn't read the file '{}'", filepath));
    let mut sum: usize = 0;
    for line in input.lines() {
        let value = get_number(line, false) * 10 + get_number(line, true);
        sum += value;
    }
    return sum;
}

fn main() {
    println!("Part 01: {}", part1("input.txt"));
    println!("Part 02: {}", part2("input.txt"));
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part1() {
        assert_eq!(part1("sample1.txt"), 142);
    }

    #[test]
    fn result_part1() {
        assert_eq!(part1("input.txt"), 55447);
    }
    
    #[test]
    fn test_part2() {
        assert_eq!(part2("sample2.txt"), 281);
    }

    #[test]
    fn result_part2() {
        assert_eq!(part2("input.txt"), 54706);
    }
}
