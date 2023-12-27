package main

import (
	"fmt"
	"io/ioutil"
	"os"
	"regexp"
	"strconv"
	"strings"
)

func numbersFromLine(line string) []int {
	re := regexp.MustCompile(`\d+`)
	matches := re.FindAllString(line, -1)
	var numbers []int
	for _, match := range matches {
		num, err := strconv.Atoi(match)
		if err == nil {
			numbers = append(numbers, num)
		}
	}
	return numbers
}

func travelledDistances(time int) []int {
	var distances []int
	for speed := 0; speed < time; speed++ {
		distance := (time - speed) * speed
		distances = append(distances, distance)
	}
	return distances
}

func winningOptions(time int, recordDistance int) int {
	travelledDistances := travelledDistances(time)
	option := 0
	for _, distance := range travelledDistances {
		if distance > recordDistance {
			option++
		}
	}
	return option
}

func allWinningOptions(times []int, recordDistances []int) []int {
	var options []int
	for i := 0; i < len(times); i++ {
		options = append(options, winningOptions(times[i], recordDistances[i]))
	}
	return options
}

func multiplyElements(numbers []int) int {
	result := 1
	for _, value := range numbers {
		result *= value
	}
	return result
}

func part01(filepath string) (int, error) {
	content, err := ioutil.ReadFile(filepath)
	if err != nil {
		return 0, err
	}
	lines := strings.Split(string(content), "\n")
	times := numbersFromLine(lines[0])
	recordDistances := numbersFromLine(lines[1])
	options := allWinningOptions(times, recordDistances)
	return multiplyElements(options), nil
}

func numberFromLine(line string) (int, error) {
	startIndex := strings.IndexFunc(line, func(r rune) bool {
		return (r >= '0' && r <= '9') || r == '-'
	})
	input := strings.ReplaceAll(line[startIndex:], " ", "")
	return strconv.Atoi(input)
}

func part02(filepath string) (int, error) {
	content, err := ioutil.ReadFile(filepath)
	if err != nil {
		return 0, err
	}
	lines := strings.Split(string(content), "\n")
	time, _ := numberFromLine(lines[0])
	recordDistance, _ := numberFromLine(lines[1])
	return winningOptions(time, recordDistance), nil
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
