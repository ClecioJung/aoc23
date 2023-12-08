use std::fs;
use std::cmp;
use std::ops::Range;

#[derive(Debug)]
struct Map {
    dst: u64,
    src: u64,
    len: u64,
}

impl Map {
    fn from_line(line: &str) -> Map {
        let numbers: Vec<u64> = line.split(' ').map(|s| s.parse::<u64>().unwrap()).collect();
        if numbers.len() != 3 {
            panic!("Expected three numbers in a line!");
        }
        Map {dst: numbers[0], src: numbers[1], len: numbers[2]}
    }
}

#[derive(Debug)]
struct Almanac {
    seed_to_soil: Vec<Map>,
    soil_to_fertilizer: Vec<Map>,
    fertilizer_to_water: Vec<Map>,
    water_to_light: Vec<Map>,
    light_to_temperature: Vec<Map>,
    temperature_to_humidity: Vec<Map>,
    humidity_to_location: Vec<Map>,
}

impl Almanac {
    fn parse_map(text: &str, name: &str) -> Vec<Map> {
        let start_index = text.find(name).unwrap();
        let end_index = if let Some(length) = text[start_index..].find("\n\n") {
            start_index + length
        } else {
            text.len()
        };
        let mapping_str = &text[start_index..end_index];
        mapping_str.lines().skip(1).map(|line| Map::from_line(line)).collect()
    }
    
    fn parse_almanac(text: &str) -> Almanac {
        Almanac {
            seed_to_soil: Almanac::parse_map(text, "seed-to-soil"),
            soil_to_fertilizer: Almanac::parse_map(text, "soil-to-fertilizer"),
            fertilizer_to_water: Almanac::parse_map(text, "fertilizer-to-water"),
            water_to_light: Almanac::parse_map(text, "water-to-light"),
            light_to_temperature: Almanac::parse_map(text, "light-to-temperature"),
            temperature_to_humidity: Almanac::parse_map(text, "temperature-to-humidity"),
            humidity_to_location: Almanac::parse_map(text, "humidity-to-location"),
        }
    }

    fn map_seeds_single_step(mappings: &Vec<Map>, seeds: Range<u64>) -> (Range<u64>, Option<Range<u64>>) {
        for mapping in mappings {
            if seeds.start >= mapping.src && seeds.start < mapping.src + mapping.len {
                let end: u64 = cmp::min(seeds.end, mapping.src + mapping.len - 1);
                let range = Range {
                    start: (seeds.start - mapping.src) + mapping.dst,
                    end: (end - mapping.src) + mapping.dst
                };
                let remainder = if end != seeds.end {
                    Some(Range {
                        start: end + 1,
                        end: seeds.end
                    })
                } else {
                    None
                };
                return (range, remainder);
            } 
        }
        return (seeds, None);
    }

    fn map_seeds_vector_single_step(mappings: &Vec<Map>, list_of_seeds: Vec<Range<u64>>) -> Vec<Range<u64>> {
        let mut output: Vec<Range<u64>> = Vec::new();
        for seeds in list_of_seeds {
            let mut next: Option<Range<u64>> = Some(seeds);
            while let Some(current) = next {
                let out = Almanac::map_seeds_single_step(mappings, current);
                output.push(out.0);
                next = out.1;
            }
        }
        output
    }

    fn map_seeds(&self, seeds: Vec<Range<u64>>) -> Vec<Range<u64>> {
        let soil = Almanac::map_seeds_vector_single_step(&self.seed_to_soil, seeds);
        let fertilizer = Almanac::map_seeds_vector_single_step(&self.soil_to_fertilizer, soil);
        let water = Almanac::map_seeds_vector_single_step(&self.fertilizer_to_water, fertilizer);
        let light = Almanac::map_seeds_vector_single_step(&self.water_to_light, water);
        let temperature = Almanac::map_seeds_vector_single_step(&self.light_to_temperature, light);
        let humidity = Almanac::map_seeds_vector_single_step(&self.temperature_to_humidity, temperature);
        let location = Almanac::map_seeds_vector_single_step(&self.humidity_to_location, humidity);
        location
    }
}

fn parse_seeds(text: &str) -> Vec<Range<u64>> {
    let first_line: &str = text.lines().next().unwrap();
    let seeds_as_str: &str = &first_line["seeds: ".len()..].trim();
    seeds_as_str.split(' ').map(|s| s.parse::<u64>().unwrap())
        .map(|value| Range { start: value, end: value }).collect()
}

fn part1(filepath: &str) -> u64 {
    let input = fs::read_to_string(filepath)
        .expect(&format!("Couldn't read the file '{}'", filepath));
    let seeds = parse_seeds(&input);
    let almanac = Almanac::parse_almanac(&input);
    almanac.map_seeds(seeds).iter().map(|r| r.start).min().unwrap()
}

fn parse_seeds_as_ranges(text: &str) -> Vec<Range<u64>> {
    let first_line: &str = text.lines().next().unwrap();
    let seeds_as_str: &str = &first_line["seeds: ".len()..].trim();
    let numbers: Vec<u64> = seeds_as_str.split(' ').map(|s| s.parse::<u64>().unwrap()).collect();
    if numbers.len() % 2 != 0 {
        panic!("Expected seed numbers to come in pairs!");
    }
    numbers.chunks(2).map(|chunk| Range { start: chunk[0], end: chunk[0] + chunk[1]}).collect()
}

fn part2(filepath: &str) -> u64 {
    let input = fs::read_to_string(filepath)
        .expect(&format!("Couldn't read the file '{}'", filepath));
    let seeds = parse_seeds_as_ranges(&input);
    let almanac = Almanac::parse_almanac(&input);
    almanac.map_seeds(seeds).iter().map(|r| r.start).min().unwrap()
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
        assert_eq!(part1("sample.txt"), 35);
    }

    #[test]
    fn result_part1() {
        assert_eq!(part1("input.txt"), 323142486);
    }

    #[test]
    fn test_part2() {
        assert_eq!(part2("sample.txt"), 46);
    }

    #[test]
    fn result_part2() {
        assert_eq!(part2("input.txt"), 79874951);
    }
}