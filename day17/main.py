#!/usr/bin/python3

from bisect import insort
from dataclasses import dataclass

LEFT  = 0
RIGHT = 1
UP    = 2
DOWN  = 3

DIRECTIONS = 4

@dataclass
class Node:
    visited: bool = False
    distance: int = float("inf")

@dataclass
class NodeToVisit:
    row: int
    col: int
    direction: int
    moves: int
    distance: int

    def __iter__(self):
        return iter(self.__dict__.values())

def next_node(nodes_to_visit, nodes):
    while True:
        row, col, direction, moves, _ = nodes_to_visit.pop(0)
        if not nodes[row][col][direction][moves].visited:
            return (row, col, direction, moves)

def append_if_valid(nodes, movements, maximum_moves, row, col, direction, moves, next_direction):
    if 0 <= row and row < len(nodes) and 0 <= col and col < len(nodes[row]):
        if (direction, next_direction) not in [(RIGHT, LEFT), (LEFT, RIGHT), (UP, DOWN), (DOWN, UP)]:
            next_moves = moves+1 if direction == next_direction else 0
            if next_moves < maximum_moves:
                if not nodes[row][col][next_direction][next_moves].visited:
                    movements.append((row, col, next_direction, next_moves))
    return movements

def available_moves(nodes, row, col, direction, moves, minimum_moves, maximum_moves):
    movements = []
    if moves < minimum_moves-1:
        if direction == LEFT:
            append_if_valid(nodes, movements, maximum_moves, row, col-1, direction, moves, direction)
        elif direction == RIGHT:
            append_if_valid(nodes, movements, maximum_moves, row, col+1, direction, moves, direction)
        elif direction == UP:
            append_if_valid(nodes, movements, maximum_moves, row-1, col, direction, moves, direction)
        elif direction == DOWN:
            append_if_valid(nodes, movements, maximum_moves, row+1, col, direction, moves, direction)
        return movements
    append_if_valid(nodes, movements, maximum_moves, row, col-1, direction, moves, LEFT)
    append_if_valid(nodes, movements, maximum_moves, row, col+1, direction, moves, RIGHT)
    append_if_valid(nodes, movements, maximum_moves, row-1, col, direction, moves, UP)
    append_if_valid(nodes, movements, maximum_moves, row+1, col, direction, moves, DOWN)
    return movements

# This algorithm became very slow. It takes around 15 seconds to run. Maybe it is python's fault.
def dijkstra_algorithm(graph, minimum_moves=0, maximum_moves=3):
    nodes = [[[[Node() for _ in range(maximum_moves)] # Moves
               for _ in range(DIRECTIONS)]            # Directions
               for _ in range(len(graph[0]))]         # Columns
               for _ in range(len(graph))]            # Lines
    nodes_to_visit = []
    # Start nodes
    nodes[0][0][RIGHT][0].distance = 0
    nodes[0][0][DOWN][0].distance = 0
    nodes_to_visit.append(NodeToVisit(0, 0, RIGHT, 0, 0))
    nodes_to_visit.append(NodeToVisit(0, 0, DOWN, 0, 0))
    while len(nodes_to_visit) > 0:
        row, col, direction, moves = next_node(nodes_to_visit, nodes)
        nodes[row][col][direction][moves].visited = True
        # Update neighbors' distances
        for (i, j, dir, mov) in available_moves(nodes, row, col, direction, moves, minimum_moves, maximum_moves):
            dist = graph[i][j] + nodes[row][col][direction][moves].distance
            if dist <= nodes[i][j][dir][mov].distance:
                nodes[i][j][dir][mov].distance = dist
                insort(nodes_to_visit, NodeToVisit(i, j, dir, mov, dist), key=lambda x: x.distance)
    return min([nodes[len(nodes)-1][len(nodes[0])-1][dir][mov].distance for dir in range(DIRECTIONS) for mov in range(max(0,minimum_moves-1), maximum_moves)])

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
