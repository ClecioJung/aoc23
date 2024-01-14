import java.io.File

fun MutableList<String>.addIfNotPresent(name: String): Int {
    var index = indexOf(name)
    if (index == -1) {
        index = size
        add(name)
    }
    return index
}

fun IntArray.indexOfMax(): Int {
    var maxIndex = 0
    for (i in 1 until size) {
        if (this[i] > this[maxIndex]) {
            maxIndex = i
        }
    }
    return maxIndex
}

fun parseInput(filePath: String): Array<IntArray> {
    val components = mutableListOf<String>()
    val connections = mutableListOf<Pair<Int, Int>>()
    File(filePath).forEachLine {
        val res = it.split(":?\\s+".toRegex())
        val indexHead = components.addIfNotPresent(res[0])
        res.drop(1).forEach({ 
            val index = components.addIfNotPresent(it)
            connections.add(Pair(indexHead, index))
        })
    }
    val N = components.size
    val matrix = MutableList(N) { MutableList(N) { 0 } }
    connections.forEach {
        matrix[it.first][it.second] = 1
        matrix[it.second][it.first] = 1
    }
    return matrix.map { it.toIntArray() } .toTypedArray()
}

// I found this C++ algorithm from wikipedia, I just translated it to kotlin
// https://en.wikipedia.org/wiki/Stoer%E2%80%93Wagner_algorithm
fun StoerWagnerMinCutAlgorithm(adjacencyMatrix: Array<IntArray>): Pair<Int, IntArray> {
    var verticesIndex = -1
    var minCut = Int.MAX_VALUE
    val N = adjacencyMatrix.size
    val co = Array(N) { IntArray(1) { it } }
    for (phase in 1 until N) {
        val w = IntArray(N) { adjacencyMatrix[0][it] }
        var s = 0; var t = 0
        for (subPhase in 0 until N-phase) {
            w[t] = Int.MIN_VALUE
            s = t; t = w.indexOfMax()
            for (i in 0 until N) {
                w[i] += adjacencyMatrix[t][i];
            }
        }
        val currentMinCut = w[t] - adjacencyMatrix[t][t]
        if (currentMinCut < minCut) {
            minCut = currentMinCut
            verticesIndex = t
        }
        co[s] = co[s] + co[t]
        for (i in 0 until N) {
            adjacencyMatrix[s][i] += adjacencyMatrix[t][i];
            adjacencyMatrix[i][s] = adjacencyMatrix[s][i];
        }
        adjacencyMatrix[0][t] = Int.MIN_VALUE;
    }
    return Pair(minCut, co[verticesIndex])
}

fun part01(filePath: String): Int {
    val adjacencyMatrix = parseInput(filePath)
    val (minCut, vertices) = StoerWagnerMinCutAlgorithm(adjacencyMatrix)
    assert(minCut == 3) { "The cut should have weight 3" }
    return vertices.size * (adjacencyMatrix.size - vertices.size)
}

fun main() {
    assert(part01("sample.txt") == 54) { "Part 01 failed for sample.txt" }
    val part01output = part01("input.txt")
    println("Part 01: ${part01output}")
    assert(part01output == 551196) { "Part 01 failed for input.txt" }
}
