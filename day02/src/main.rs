use std::fs;
use std::cmp;

#[derive(Default, Debug)]
struct Set {
    red: u64,
    green: u64,
    blue: u64,
}

impl Set {
    fn from_line(line: &str) -> Set {
        let mut set = Set::default();
        let cubes: Vec<&str> = line.split(',').collect();
        for cube in cubes {
            let cube_parts: Vec<&str> = cube.trim_start().split(' ').collect();
            let value: u64 = cube_parts[0].parse::<u64>().unwrap();
            let color = cube_parts[1];
            match color {
                "red" => set.red = value,
                "green" => set.green = value,
                "blue" => set.blue = value,
                &_ => unreachable!(),
            }
        }
        set
    }

    fn power(&self) -> u64 {
        self.red * self.green * self.blue
    }
}

#[derive(Debug)]
struct Game {
    id: u64,
    sets: Vec<Set>,
}

impl Game {
    fn from_line(line: &str) -> Game {
        let line_parts: Vec<&str> = line.split(':').collect();
        let id_str = &line_parts[0]["Game: ".len()-1..];
        let id: u64 = id_str.parse::<u64>().unwrap();
        let mut sets = Vec::new();
        let sets_strs: Vec<&str> = line_parts[1].split(';').collect();
        for set_str in sets_strs {
            let set = Set::from_line(set_str);
            sets.push(set);
        }
        Game { id, sets }
    }

    fn is_possible(&self, expected_set: Set) -> bool {
        for set in &self.sets {
            if (expected_set.red < set.red) || (expected_set.green < set.green) || (expected_set.blue < set.blue) {
                return false;
            }
        }
        true
    }

    fn fewest_set(&self) -> Set {
        let mut max_set = Set::default();
        for set in &self.sets {
            max_set.red = cmp::max(max_set.red, set.red);
            max_set.green = cmp::max(max_set.green, set.green);
            max_set.blue = cmp::max(max_set.blue, set.blue);
        }
        max_set
    }

    fn power(&self) -> u64 {
        self.fewest_set().power()
    }
}

fn part1(filepath: &str) -> u64 {
    let input = fs::read_to_string(filepath)
        .expect(&format!("Couldn't read the file '{}'", filepath));
    let mut sum_of_ids: u64 = 0;
    for line in input.lines() {
        let game = Game::from_line(line);
        if game.is_possible(Set {red: 12, green: 13, blue: 14}) {
            sum_of_ids += game.id;
        }
    }
    return sum_of_ids;
}

fn part2(filepath: &str) -> u64 {
    let input = fs::read_to_string(filepath)
        .expect(&format!("Couldn't read the file '{}'", filepath));
    let mut sum: u64 = 0;
    for line in input.lines() {
        let game = Game::from_line(line);
        sum += game.power();
    }
    return sum;
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
        assert_eq!(part1("sample.txt"), 8);
    }

    #[test]
    fn result_part1() {
        assert_eq!(part1("input.txt"), 2810);
    }

    #[test]
    fn test_part2() {
        assert_eq!(part2("sample.txt"), 2286);
    }

    #[test]
    fn result_part2() {
        assert_eq!(part2("input.txt"), 69110);
    }
}
