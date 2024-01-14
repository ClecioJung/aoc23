#!/usr/bin/python3

from bisect import insort

LEFT  = 0
RIGHT = 1
UP    = 2
DOWN  = 3

DIRECTIONS = 4
    
def available_moves(row, col, direction, moves, max_row, max_col, minimum_moves, maximum_moves):
    directions = {
        LEFT:  (0, -1),
        RIGHT: (0, 1),
        UP:    (-1, 0),
        DOWN:  (1, 0)
    }
    movements = []
    for next_direction, (drow, dcol) in directions.items():
        if (direction, next_direction) not in [(RIGHT, LEFT), (LEFT, RIGHT), (UP, DOWN), (DOWN, UP)]:
            if moves >= minimum_moves - 1 or next_direction == direction:
                next_moves = moves + 1 if direction == next_direction else 0
                if next_moves < maximum_moves:
                    next_row, next_col = row + drow, col + dcol
                    if 0 <= next_row < max_row and 0 <= next_col < max_col:
                        movements.append((next_row, next_col, next_direction, next_moves))
    return movements

# This algorithm became very slow. It takes around 15 seconds to run. Maybe it is python's fault.
def dijkstra_algorithm(graph, minimum_moves=0, maximum_moves=3):
    max_row = len(graph)
    max_col = len(graph[0])
    visited = [[[[False
                for _ in range(maximum_moves)] # Moves
                for _ in range(DIRECTIONS)]    # Directions
                for _ in range(max_col)]       # Columns
                for _ in range(max_row)]       # Lines
    distances = [[[[float("inf")
                for _ in range(maximum_moves)] # Moves
                for _ in range(DIRECTIONS)]    # Directions
                for _ in range(max_col)]       # Columns
                for _ in range(max_row)]       # Lines
    nodes_to_visit = []
    # Start nodes
    distances[0][0][RIGHT][0] = 0
    distances[0][0][DOWN][0] = 0
    nodes_to_visit.append((0, 0, 0, RIGHT, 0))
    nodes_to_visit.append((0, 0, 0, DOWN, 0))
    while len(nodes_to_visit) > 0:
        _, row, col, direction, moves = nodes_to_visit.pop(0)
        if visited[row][col][direction][moves]: continue
        visited[row][col][direction][moves] = True
        # Update neighbors' distances
        for (i, j, dir, mov) in available_moves(row, col, direction, moves, max_row, max_col, minimum_moves, maximum_moves):
            if not visited[i][j][dir][mov]:
                dist = graph[i][j] + distances[row][col][direction][moves]
                if dist < distances[i][j][dir][mov]:
                    distances[i][j][dir][mov] = dist
                    insort(nodes_to_visit, (dist, i, j, dir, mov))
    return min([distances[max_row-1][max_col-1][dir][mov] for dir in range(DIRECTIONS) for mov in range(max(0,minimum_moves-1), maximum_moves)])

def part01(file_path):
    with open(file_path) as f:
        content = f.read()
    graph = [[int(char) for char in line] for line in content.splitlines()]
    return dijkstra_algorithm(graph)

def part02(file_path):
    with open(file_path) as f:
        content = f.read()
    graph = [[int(char) for char in line] for line in content.splitlines()]
    return dijkstra_algorithm(graph, minimum_moves=4, maximum_moves=10)

def main():
    assert part01("sample1.txt") == 102
    part01output = part01("input.txt")
    print(f"Part 01: {part01output}")
    assert part01output == 936
    assert part02("sample1.txt") == 94
    assert part02("sample2.txt") == 71
    part02output = part02("input.txt")
    print(f"Part 02: {part02output}")
    assert part02output == 1157

if __name__ == "__main__":
    main()
