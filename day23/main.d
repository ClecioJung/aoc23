import std;

size_t findIndex(alias pred, R)(R range) {
    foreach (i, elem; range) {
        if (pred(elem)) {
            return i;
        }
    }
    return range.length;
}

size_t insertIfDontExist(T)(ref T[] range, T element) {
    auto index = findIndex!(t => t == element)(range);
    if (index >= range.length) {
        range ~= element;
        index = cast(long)range.length - 1;
    }
    return index;
}

Tuple!(int, int) findInitialPosition(const string[] map) {
    auto index = findIndex!(t => t == '.')(map[0]);
    if (index < map[0].length) {
        return tuple(0, cast(int)index);
    }
    throw new Exception("Didn't found initial position!");
}

bool isFinalPosition(const string[] map, const Tuple!(int, int) position) {
    auto height = map.length;
    return (position[0] >= height-1);
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

struct SearchPath {
    size_t node;
    int distance;
    static const int VISITED_LENGTH = 50;
    bool[VISITED_LENGTH] visited;

    this(const size_t node, const int distance, const size_t size) {
        this.node = node;
        this.distance = distance;
        assert(size < visited.length);
        this.visited[node] = true;
    }

    this(const size_t node, const int distance, const bool[] visited) {
        this.node = node;
        this.distance = distance;
        foreach (index, visit; visited) {
            this.visited[index] = visit;
        }
        this.visited[node] = true;
    }
}

struct Graph {
    size_t initial;
    size_t goal;
    int[][] adjacencyMatrix;

    this(const string[] map, const bool slippery) {
        this.initial = 0;
        this.goal = ulong.max;
        auto initialPos = findInitialPosition(map);
        // This first part uses BFS (Breadth First Search) to build a list of nodes and the paths between them
        Tuple!(int, int)[] nodes = [initialPos];
        Tuple!(size_t, size_t, int)[] paths; // (indexFrom, indexTo, distance)
        Node[] queue = [Node(initialPos, this.initial, 'v')];
        int queueIndex = 0;
        while (queueIndex < queue.length) {
            auto current = queue[queueIndex];
            queueIndex++;
            int distance = 0;
            while (true) {
                auto nextPositions = getNextPositions(map, current.pos, current.direction, slippery);
                distance++;
                if (nextPositions.length != 1) { // found intersection
                    auto to = insertIfDontExist(nodes, current.pos);
                    paths ~= tuple(current.index, to, distance);
                    if (to == (cast(long)nodes.length-1)) { // If a new node was created
                        foreach (nextPosition; nextPositions) {
                            auto position = nextPosition[0];
                            auto direction = nextPosition[1];
                            queue ~= Node(position, to, direction);
                        }
                    }
                    break;
                }
                auto position = nextPositions[0][0];
                if (isFinalPosition(map, position)) {
                    this.goal = insertIfDontExist(nodes, position);
                    paths ~= tuple(current.index, this.goal, distance);
                    break;
                }
                auto direction = nextPositions[0][1];
                current = Node(position, current.index, direction);
            }
        }
        assert(this.goal < nodes.length);
        // Compute Adjacency Matrix
        foreach (_; 0 .. nodes.length) {
            int[] row = new int[nodes.length];
            this.adjacencyMatrix ~= row;
        }
        foreach (path; paths) {
            this.adjacencyMatrix[path[0]][path[1]] = path[2];
        }
    }

    // DFS - Depth First Search
    int maxDistance() {
        int distance = -1;
        SearchPath[] stack;
        stack ~= SearchPath(this.initial, 0, adjacencyMatrix.length);
        while (stack.length > 0) {
            auto current = stack[$-1];
            stack.length--;
            for (size_t node = 0; node < adjacencyMatrix.length; node++) {
                auto weight = adjacencyMatrix[current.node][node];
                if (weight > 0) {
                    if (node == this.goal) {
                        distance = max(distance, weight + current.distance);
                    } else if (!current.visited[node]) {
                        stack ~= SearchPath(node, weight + current.distance, current.visited);
                    }
                }
            }
        }
        return distance;
    }
}

int part01(const string filepath) {
    const string[] map = readText(filepath).splitLines();
    Graph graph = Graph(map, true);
    return graph.maxDistance();
}

int part02(const string filepath) {
    const string[] map = readText(filepath).splitLines();
    Graph graph = Graph(map, false);
    return graph.maxDistance();
}

void main() {
    assert(part01("sample.txt") == 94);
    auto part01output = part01("input.txt");
    writeln("Part 01: ", part01output);
    assert(part01output == 2330);
    assert(part02("sample.txt") == 154);
    auto part02output = part02("input.txt");
    writeln("Part 02: ", part02output);
    assert(part02output == 6518);
}
