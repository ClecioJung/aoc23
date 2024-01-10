import java.io.File

fun MutableList<String>.addIfNotPresent(name: String): Int {
    var index = indexOf(name)
    if (index == -1) {
        index = size
        add(name)
    }
    return index
}

class Circuit(private val comp: MutableList<String>, private val conn: MutableList<Pair<Int, Int>>) {
    val components: Array<String> = comp.toTypedArray()
    val connections: Array<Pair<Int, Int>> = conn.toTypedArray()

    fun debugPrint() {
        println("Components:  ${components.joinToString(", ")}")
        val connAsStr = connections
            .map { "${components[it.first]}/${components[it.second]}" }
            .joinToString(", ")
        println("Connections: ${connAsStr}")
    }

    companion object {
        fun fromFile(filePath: String): Circuit {
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
            return Circuit(components, connections)
        }
    }

    fun intoAdjacencyMatrix(): Array<IntArray> {
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
    fun StoerWagnerMinCutAlgorithm(): Pair<Int, IntArray> {
        val adjacencyMatrix = intoAdjacencyMatrix()
        val N = adjacencyMatrix.size
        var vertices = mutableListOf<Int>()
        var minCut = Int.MAX_VALUE
        val co = MutableList(N) { mutableListOf(it) }
        for (phase in 1 until N) {
            val w = adjacencyMatrix[0].toMutableList()
            var s = 0; var t = 0
            for (subPhase in 0 until N-phase) {
                w[t] = Int.MIN_VALUE
                s = t; t = w.indexOf(w.max())
                for (i in 0 until N) {
                    w[i] += adjacencyMatrix[t][i];
                }
            }
            val currentMinCut = w[t] - adjacencyMatrix[t][t]
            if (currentMinCut < minCut) {
                minCut = currentMinCut
                vertices = co[t]
            }
            co[s].addAll(co[t])
            for (i in 0 until N) {
                adjacencyMatrix[s][i] += adjacencyMatrix[t][i];
                adjacencyMatrix[i][s] = adjacencyMatrix[s][i];
            }
            adjacencyMatrix[0][t] = Int.MIN_VALUE;
        }
        return Pair(minCut, vertices.toIntArray())
    }
}

fun part01(filePath: String): Int {
    val circuit = Circuit.fromFile(filePath)
    val (_, vertices) = circuit.StoerWagnerMinCutAlgorithm()
    return vertices.size * (circuit.components.size - vertices.size)
}

fun main() {
    assert(part01("sample.txt") == 54) { "Part 01 failed for sample.txt" }
    val part01output = part01("input.txt")
    println("Part 01: ${part01output}")
    assert(part01output == 551196) { "Part 01 failed for input.txt" }
}
