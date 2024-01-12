use std::fs;

#[allow(dead_code)]
#[derive(Debug)]
struct Scratchcard {
    id: u32,
    winnings: Vec<u32>,
    numbers: Vec<u32>,
}

impl Scratchcard {
    fn from_line(line: &str) -> Scratchcard {
        let line_parts: Vec<&str> = line.split(':').collect();
        let id_str = &line_parts[0]["Card:".len()-1..];
        let id: u32 = id_str.trim().parse::<u32>().unwrap();
        let number_strs: Vec<&str> = line_parts[1].split('|').collect();
        let winnings: Vec<u32> = number_strs[0].split(' ')
            .filter(|s| !s.is_empty()).map(|s| s.parse::<u32>().unwrap()).collect();
        let numbers: Vec<u32> = number_strs[1].split(' ')
            .filter(|s| !s.is_empty()).map(|s| s.parse::<u32>().unwrap()).collect();
        Scratchcard { id, winnings, numbers }
    }

    fn winning_numbers(&self) -> u32 {
        let mut winning_numbers: u32 = 0;
        for number in &self.numbers {
            if self.winnings.contains(&number) {
                winning_numbers += 1;
            }
        }
        winning_numbers
    }

    fn points(&self) -> u32 {
        let winning_numbers: u32 = self.winning_numbers();
        if winning_numbers != 0 { 2u32.pow(winning_numbers - 1) } else { 0 }
    }
}

fn part1(filepath: &str) -> u64 {
    let input = fs::read_to_string(filepath)
        .expect(&format!("Couldn't read the file '{}'", filepath));
    let scratchcards: Vec<Scratchcard> = input.lines().map(|line| Scratchcard::from_line(line)).collect();
    let points: u64 = scratchcards.iter().map(|scratchcard| scratchcard.points() as u64).sum();
    return points;
}

fn part2(filepath: &str) -> u64 {
    let input = fs::read_to_string(filepath)
        .expect(&format!("Couldn't read the file '{}'", filepath));
    let scratchcards: Vec<Scratchcard> = input.lines().map(|line| Scratchcard::from_line(line)).collect();
    let winning_numbers: Vec<u32> = scratchcards.iter().map(|scratchcard| scratchcard.winning_numbers()).collect();
    let mut copies: Vec<u64> = vec![1; winning_numbers.len()];
    for (i, numbers) in winning_numbers.iter().enumerate() {
        for j in 1..(*numbers+1) as usize {
            copies[i+j] += copies[i];
        }
    }
    copies.iter().sum()
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
        assert_eq!(part1("sample.txt"), 13);
    }

    #[test]
    fn result_part1() {
        assert_eq!(part1("input.txt"), 17803);
    }

    #[test]
    fn test_part2() {
        assert_eq!(part2("sample.txt"), 30);
    }

    #[test]
    fn result_part2() {
        assert_eq!(part2("input.txt"), 5554894);
    }
}