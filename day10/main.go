package main

import (
	"fmt"
	"io/ioutil"
	"os"
	"strings"
)

type Position struct {
	line int
	col  int
}

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}

func max(a, b int) int {
	if a > b {
		return a
	}
	return b
}

func parseBoard(input string) [][]byte {
	lines := strings.Split(input, "\n")
	board := make([][]byte, len(lines))
	for i, line := range lines {
		board[i] = []byte(line)
	}
	return board
}

func findInBoard(board [][]byte, char byte) Position {
	for i, row := range board {
		for j, value := range row {
			if value == char {
				return Position{i, j}
			}
		}
	}
	return Position{-1, -1} // Unreachable
}

func findValidPos(board [][]byte, initialPos Position) ([]Position, byte) {
	up := false
	down := false
	left := false
	right := false
	minLine := max(initialPos.line-1, 0)
	maxLine := min(initialPos.line+1, len(board)-1)
	minCol := max(initialPos.col-1, 0)
	maxCol := min(initialPos.col+1, len(board[0])-1)
	var pos []Position
	for i := minLine; i <= maxLine; i++ {
		for j := minCol; j <= maxCol; j++ {
			switch board[i][j] {
			case '|':
				if initialPos.col == j {
					pos = append(pos, Position{i, j})
					if i > initialPos.line {
						down = true
					} else {
						up = true
					}
				}
			case '-':
				if initialPos.line == i {
					pos = append(pos, Position{i, j})
					if j > initialPos.col {
						right = true
					} else {
						left = true
					}
				}
			case 'L':
				if initialPos.line == i && initialPos.col == j+1 {
					pos = append(pos, Position{i, j})
					left = true
				} else if initialPos.line == i-1 && initialPos.col == j {
					pos = append(pos, Position{i, j})
					down = true
				}
			case 'J':
				if initialPos.line == i && initialPos.col == j-1 {
					pos = append(pos, Position{i, j})
					right = true
				} else if initialPos.line == i-1 && initialPos.col == j {
					pos = append(pos, Position{i, j})
					down = true
				}
			case '7':
				if initialPos.line == i && initialPos.col == j-1 {
					pos = append(pos, Position{i, j})
					right = true
				} else if initialPos.line == i+1 && initialPos.col == j {
					pos = append(pos, Position{i, j})
					up = true
				}
			case 'F':
				if initialPos.line == i && initialPos.col == j+1 {
					pos = append(pos, Position{i, j})
					left = true
				} else if initialPos.line == i+1 && initialPos.col == j {
					pos = append(pos, Position{i, j})
					up = true
				}
			case '.':
			case 'S':
			}
		}
	}
	initialPipe := '.'
	if right && left {
		initialPipe = '-'
	}
	if up && down {
		initialPipe = '|'
	}
	if up {
		if left {
			initialPipe = 'J'
		}
		if right {
			initialPipe = 'L'
		}
	}
	if down {
		if left {
			initialPipe = '7'
		}
		if right {
			initialPipe = 'F'
		}
	}
	return pos, byte(initialPipe)
}

func nextValidPos(board [][]byte, currentPos, previousPos Position) Position {
	switch board[currentPos.line][currentPos.col] {
	case '|':
		if previousPos.line < currentPos.line {
			currentPos.line++
		} else {
			currentPos.line--
		}
	case '-':
		if previousPos.col < currentPos.col {
			currentPos.col++
		} else {
			currentPos.col--
		}
	case 'L':
		if currentPos.line == previousPos.line {
			currentPos.line--
		} else {
			currentPos.col++
		}
	case 'J':
		if currentPos.line == previousPos.line {
			currentPos.line--
		} else {
			currentPos.col--
		}
	case '7':
		if currentPos.line == previousPos.line {
			currentPos.line++
		} else {
			currentPos.col--
		}
	case 'F':
		if currentPos.line == previousPos.line {
			currentPos.line++
		} else {
			currentPos.col++
		}
	case '.': // Unreachable
	case 'S': // Unreachable
	}
	return currentPos
}

func part01(filepath string) (int, error) {
	content, err := ioutil.ReadFile(filepath)
	if err != nil {
		return 0, err
	}
	board := parseBoard(string(content))
	initialPos := findInBoard(board, 'S')
	previousPos := initialPos
	currentPositions, _ := findValidPos(board, initialPos)
	currentPos := currentPositions[0]
	step := 1
	for board[currentPos.line][currentPos.col] != 'S' {
		nextPos := nextValidPos(board, currentPos, previousPos)
		previousPos = currentPos
		currentPos = nextPos
		step++
	}
	farthest := (step + 1) / 2
	return farthest, nil
}

func createEmptyBoolVector(line, cols int) [][]bool {
	space := make([][]bool, line)
	for i := 0; i < line; i++ {
		space[i] = make([]bool, cols)
	}
	return space
}

func computeArea(board [][]byte, isPath [][]bool) int {
	area := 0
	for i := 0; i < len(board); i++ {
		up := false
		down := false
		for j := 0; j < len(board[i]); j++ {
			if isPath[i][j] {
				switch board[i][j] {
				case '|':
					up = !up
					down = !down
				case '-':
				case 'L':
					up = !up
				case 'J':
					up = !up
				case '7':
					down = !down
				case 'F':
					down = !down
				case '.':
				case 'S':
				}
			} else {
				if up || down {
					area++
				}
			}
		}
	}
	return area
}

func part02(filepath string) (int, error) {
	content, err := ioutil.ReadFile(filepath)
	if err != nil {
		return 0, err
	}
	board := parseBoard(string(content))
	isPath := createEmptyBoolVector(len(board), len(board[0]))
	initialPos := findInBoard(board, 'S')
	previousPos := initialPos
	currentPositions, initialPipe := findValidPos(board, initialPos)
	currentPos := currentPositions[0]
	isPath[previousPos.line][previousPos.col] = true
	for board[currentPos.line][currentPos.col] != 'S' {
		nextPos := nextValidPos(board, currentPos, previousPos)
		previousPos = currentPos
		currentPos = nextPos
		isPath[previousPos.line][previousPos.col] = true
	}
	board[initialPos.line][initialPos.col] = initialPipe
	area := computeArea(board, isPath)
	return area, nil
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
