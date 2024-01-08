import std;

Tuple!(int, int) findInitialPosition(const string[] map) {
    for (int i = 0; i < map[0].length; i++) {
        if (map[0][i] == '.') {
            return tuple(0, i);
        }
    }
    throw new Exception("Didn't found initial position!");
}

char mapAt(const string[] map, const Tuple!(int, int) pos) {
    return map[pos[0]][pos[1]];
}

Tuple!(int, int) sumPos(Tuple!(int, int) posA, Tuple!(int, int) posB) {
    return tuple(posA[0] + posB[0], posA[1] + posB[1]);
}

char opositeDirection(const char direction) {
    switch (direction) {
    case '<': return '>';
    case '>': return '<';
    case '^': return 'v';
    case 'v': return '^';
    default: throw new Exception("Unreachable!");
    }
}

Tuple!(Tuple!(int, int), char)[] getNextPositions(
    const string[] map,
    const Tuple!(int, int) pos,
    const char direction,
    const bool slippery
    ) {
    Tuple!(Tuple!(int, int), char)[] nextPositions;
    const Tuple!(Tuple!(int, int), char)[] moves = [
        tuple(tuple(-1, 0), '^'),
        tuple(tuple(1, 0), 'v'),
        tuple(tuple(0, -1), '<'),
        tuple(tuple(0, 1), '>')
    ];
    foreach (move; moves) {
        char newDirection = move[1];
        if (direction == opositeDirection(newDirection)) {
            continue;
        }
        auto newPos = sumPos(pos, move[0]);
        auto value = mapAt(map, newPos);
        switch (value) {
            case '#':
                break;
            case '.':
                nextPositions ~= tuple(newPos, newDirection);
                break;
            case '<':
            case '>':
            case '^':
            case 'v':
                if (!slippery || value == newDirection) {
                    nextPositions ~= tuple(newPos, newDirection);
                }
                break;
            default:
                throw new Exception("Unreachable! Unexpected value: " ~ value);
        }
    }
    return nextPositions;
}

bool isFinalPosition(const string[] map, const Tuple!(int, int) position) {
    auto height = map.length;
    return (position[0] >= height-1);
}

struct MapPoint {
    Tuple!(int, int) pos;
    int distance;
    char direction;

    this(const Tuple!(int, int) pos, const int distance, const char direction) {
        this.pos = pos;
        this.distance = distance;
        this.direction = direction;
    }
}

// BFS - Breadth First Search
int[] getMaxDistance(const string[] map) {
    auto initialPos = findInitialPosition(map);
    int[] distances;
    MapPoint[] queue;
    queue ~= MapPoint(initialPos, 0, 'v');
    int queueIndex = 0;
    while (queueIndex < queue.length) {
        auto current = queue[queueIndex];
        queueIndex++;
        while (true) {
            auto nextPositions = getNextPositions(map, current.pos, current.direction, true);
            auto distance = current.distance + 1;
            if (nextPositions.length == 1) {
                auto position = nextPositions[0][0];
                if (isFinalPosition(map, position)) {
                    distances ~= distance;
                    break;
                }
                auto direction = nextPositions[0][1];
                current = MapPoint(position, distance, direction);
            } else { // dead-end or intersection
                foreach (nextPosition; nextPositions) {
                    auto position = nextPosition[0];
                    auto direction = nextPosition[1];
                    queue ~= MapPoint(position, distance, direction);
                }
                break;
            }
        }
    }
    return distances;
}

int part01(const string filepath) {
    const string[] map = readText(filepath).splitLines();
    int[] distances = getMaxDistance(map);
    return maxElement(distances);
}

struct Node {
    Tuple!(int, int) pos;
    size_t index;
    char direction;

    this(const Tuple!(int, int) pos, const size_t index, const char direction) {
        this.pos = pos;
        this.index = index;
        this.direction = direction;
    }
}

struct Path {
    Tuple!(size_t, size_t) points;
    int distance;

    this(const size_t begin, const size_t end, const int distance) {
        this.points = tuple(min(begin, end), max(begin, end));
        this.distance = distance;
    }
}

struct Edge {
    size_t node;
    int distance;

    this(const size_t node, const int distance) {
        this.node = node;
        this.distance = distance;
    }
}

struct SearchPath {
    size_t node;
    int distance;
    size_t[] visited;

    this(const size_t node, const int distance, const size_t[] visited) {
        this.node = node;
        this.distance = distance;
        this.visited ~= visited ~ node;
    }
}

struct Graph {
    size_t initial;
    size_t goal;
    Tuple!(int, int)[] nodes;
    Path[] paths;

    this(const Tuple!(int, int) initialPos) {
        this.nodes ~= initialPos;
        this.goal = 0;
    }

    int findPos(const Tuple!(int, int) pos) {
        for (int i = 0; i < nodes.length; i++) {
            auto node = nodes[i];
            if (node[0] == pos[0] && node[1] == pos[1]) {
                return i;
            }
        }
        return -1;
    }

    int findPath(const size_t begin, const size_t end) {
        Tuple!(size_t, size_t) points = tuple(min(begin, end), max(begin, end));
        for (int i = 0; i < paths.length; i++) {
            auto path_points = paths[i].points;
            if (path_points[0] == points[0] && path_points[1] == points[1]) {
                return i;
            }
        }
        return -1;
    }

    int addPath(const size_t node, const Tuple!(int, int) pos, const int distance) {
        int to = findPos(pos);
        if (to >= 0) {
            if (findPath(node, cast(size_t)to) < 0) {
                this.paths ~= Path(node, cast(size_t)to, distance);
            }
            return -1;
        }
        this.nodes ~= pos;
        size_t end = this.nodes.length - 1;
        this.paths ~= Path(node, end, distance);
        return cast(int)end;
    }

    int setGoal(const size_t node, const Tuple!(int, int) pos, const int distance) {
        auto goal = addPath(node, pos, distance);
        if (goal >= 0) {
            this.goal = goal;
        }
        return goal;
    }

    // BFS - Breadth First Search
    static Graph build(const string[] map) {
        auto initialPos = findInitialPosition(map);
        Graph graph = Graph(initialPos);
        Node[] queue;
        queue ~= Node(initialPos, graph.initial, 'v');
        int queueIndex = 0;
        while (queueIndex < queue.length) {
            auto current = queue[queueIndex];
            queueIndex++;
            int distance = 0;
            while (true) {
                auto nextPositions = getNextPositions(map, current.pos, current.direction, false);
                distance++;
                if (nextPositions.length == 1) {
                    auto position = nextPositions[0][0];
                    if (isFinalPosition(map, position)) {
                        graph.setGoal(current.index, position, distance);
                        break;
                    }
                    auto direction = nextPositions[0][1];
                    current = Node(position, current.index, direction);
                } else { // dead-end or intersection
                    int nodeIndex = graph.addPath(current.index, current.pos, distance);
                    if (nodeIndex >= 0) { // If a new node was created
                        foreach (nextPosition; nextPositions) {
                            auto position = nextPosition[0];
                            auto direction = nextPosition[1];
                            queue ~= Node(position, nodeIndex, direction);
                        }
                    }
                    break;
                }
            }
        }
        return graph;
    }

    Edge[] getNextEdges(const size_t node) {
        Edge[] nextEdges;
        foreach (path; paths) {
            if (path.points[0] == node) {
                nextEdges ~= Edge(path.points[1], path.distance);
            } else if (path.points[1] == node) {
                nextEdges ~= Edge(path.points[0], path.distance);
            }
        }
        return nextEdges;
    }

    // DFS - Depth First Search
    int[] distances() {
        int[] distances;
        SearchPath[] stack;
        stack ~= SearchPath(this.initial, 0, [this.initial]);
        while (stack.length > 0) {
            auto current = stack[$-1];
            stack.length--;
            if (current.node == this.goal) {
                distances ~= current.distance;
            }
            auto nextEdges = getNextEdges(current.node);
            foreach (nextEdge; nextEdges) {
                if (find(current.visited, nextEdge.node).empty) {
                    auto distance = nextEdge.distance + current.distance;
                    //stack ~= SearchPath(nextEdge.node, distance, current.visited ~ nextEdge.node);
                    stack ~= SearchPath(nextEdge.node, distance, current.visited);
                }
            }
        }
        return distances;
    }
}

int part02(const string filepath) {
    const string[] map = readText(filepath).splitLines();
    Graph graph = Graph.build(map);
    int[] distances = graph.distances();
    return maxElement(distances);
}

// Part 01 was solved with a straightforward BFS applied directly to the provided input map.
// However, this approach proved inefficient for Part 02, prompting me to search for a more
// optimized strategy. I transformed and simplified the input map into a graph using BFS and
// subsequently employed DFS to explore all paths, enabling the discovery of the solution.
// Notably, this approach was not directly applicable to Part 01 due to its directional
// dependency, in contrast to the direction-independent nature of Part 02. Despite these
// optimizations, the implemented solution for Part 02 still exhibits suboptimal performance,
// taking approximately 1 minute and 20 seconds to execute on my machine.
void main()
{
    assert(part01("sample.txt") == 94);
    auto part01output = part01("input.txt");
    writeln("Part 01: ", part01output);
    assert(part01output == 2330);
    assert(part02("sample.txt") == 154);
    auto part02output = part02("input.txt");
    writeln("Part 02: ", part02output);
    assert(part02output == 6518);
}
