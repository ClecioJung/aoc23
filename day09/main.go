package main

import (
	"fmt"
	"io/ioutil"
	"os"
	"strconv"
	"strings"
)

func parseInput(content string) [][]int {
	lines := strings.Split(string(content), "\n")
	values := make([][]int, len(lines))
	for i, line := range lines {
		numbers := strings.Split(string(line), " ")
		linesValues := make([]int, len(numbers))
		for j, number := range numbers {
			linesValues[j], _ = strconv.Atoi(number)
		}
		values[i] = linesValues
	}
	return values
}

func nullVector(values []int) bool {
	for _, value := range values {
		if value != 0 {
			return false
		}
	}
	return true
}

func computeDifferences(values []int) []int {
	var differences []int
	for i := 0; i < len(values)-1; i++ {
		differences = append(differences, values[i+1]-values[i])
	}
	return differences
}

func estimateNextValue(values []int) int {
	if nullVector(values) {
		return 0
	}
	differences := computeDifferences(values)
	return values[len(values)-1] + estimateNextValue(differences)
}

func estimateNextValues(values [][]int) []int {
	var nextValues []int
	for _, line := range values {
		nextValues = append(nextValues, estimateNextValue(line))
	}
	return nextValues
}

func sum(values []int) int {
	sum := 0
	for _, value := range values {
		sum += value
	}
	return sum
}

func part01(filepath string) (int, error) {
	content, err := ioutil.ReadFile(filepath)
	if err != nil {
		return 0, err
	}
	values := parseInput(string(content))
	nextValues := estimateNextValues(values)
	return sum(nextValues), nil
}

func estimatePreviousValue(values []int) int {
	if nullVector(values) {
		return 0
	}
	differences := computeDifferences(values)
	return values[0] - estimatePreviousValue(differences)
}

func estimatePreviousValues(values [][]int) []int {
	var nextValues []int
	for _, line := range values {
		nextValues = append(nextValues, estimatePreviousValue(line))
	}
	return nextValues
}

func part02(filepath string) (int, error) {
	content, err := ioutil.ReadFile(filepath)
	if err != nil {
		return 0, err
	}
	values := parseInput(string(content))
	previousValues := estimatePreviousValues(values)
	return sum(previousValues), nil
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
