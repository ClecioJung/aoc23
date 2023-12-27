package main

import (
	"fmt"
	"io/ioutil"
	"os"
	"regexp"
	"strings"
)

type Point struct {
	left  string
	right string
}

func parseInput(content string) (string, map[string]Point) {
	lines := strings.Split(string(content), "\n")
	instructions := lines[0]
	// lines[1] is an empty line, and thus should be ignored
	mapping := make(map[string]Point)
	for i := 2; i < len(lines); i++ {
		pattern := `^([^\s]+) = \(([^\s]+), ([^\s]+)\)$`
		re := regexp.MustCompile(pattern)
		matches := re.FindStringSubmatch(lines[i])
		mapping[matches[1]] = Point{left: matches[2], right: matches[3]}
	}
	return instructions, mapping
}

func part01(filepath string) (int, error) {
	content, err := ioutil.ReadFile(filepath)
	if err != nil {
		return 0, err
	}
	instructions, mapping := parseInput(string(content))
	currentPos := "AAA"
	steps := 0
	for currentPos != "ZZZ" {
		for _, instruction := range instructions {
			steps++
			switch instruction {
			case 'L':
				currentPos = mapping[currentPos].left
			case 'R':
				currentPos = mapping[currentPos].right
			}
			if currentPos == "ZZZ" {
				break
			}
		}
	}
	return steps, nil
}

func findInitialPositions(mapping map[string]Point) []string {
	var initialPos []string
	for name := range mapping {
		if strings.HasSuffix(name, "A") {
			initialPos = append(initialPos, name)
		}
	}
	return initialPos
}

func getSteps(currentPos string, instructions string, mapping map[string]Point) int {
	steps := 0
	for !strings.HasSuffix(currentPos, "Z") {
		for _, instruction := range instructions {
			steps++
			switch instruction {
			case 'L':
				currentPos = mapping[currentPos].left
			case 'R':
				currentPos = mapping[currentPos].right
			}
			if strings.HasSuffix(currentPos, "Z") {
				break
			}
		}
	}
	return steps
}

func GCD(a, b int) int {
	for b != 0 {
		a, b = b, a%b
	}
	return a
}

func LCM(periods []int) int {
	lcm := periods[0]
	for _, period := range periods[1:] {
		lcm = lcm * period / GCD(lcm, period)
	}
	return lcm
}

// Each path is periodic, so we just need to find the period of each path,
// and then the amount of steps will be the least common multiple (LCM)
// between the periods
// This is true because the initial and ending locations have the same signature:
// HVA = (NMF, CTG) NMZ = (CTG, NMF)
// LBA = (TBT, HGC) SJZ = (HGC, TBT)
// FXA = (MQX, NDF) GNZ = (NDF, MQX)
// GHA = (DLD, MBC) TNZ = (MBC, DLD)
// PSA = (MLN, HHG) BNZ = (HHG, MLN)
// AAA = (CLB, XLR) ZZZ = (XLR, CLB)
func part02(filepath string) (int, error) {
	content, err := ioutil.ReadFile(filepath)
	if err != nil {
		return 0, err
	}
	instructions, mapping := parseInput(string(content))
	initialPos := findInitialPositions(mapping)
	var periods []int
	for i := 0; i < len(initialPos); i++ {
		periods = append(periods, getSteps(initialPos[i], instructions, mapping))
	}
	steps := LCM(periods)
	return steps, nil
}

func main() {
	result, err := part01("input.txt")
	if err != nil {
		fmt.Fprintln(os.Stderr, "Error reading file:", err)
		return
	}
	fmt.Println("Part 01:", result)
	result, err = part02("input.txt")
	if err != nil {
		fmt.Fprintln(os.Stderr, "Error reading file:", err)
		return
	}
	fmt.Println("Part 02:", result)
}
