package day11;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Vector;

class Galaxy {
    public long x;
    public long y;

    public Galaxy(long x, long y) {
        this.x = x;
        this.y = y;
    }

    public long shortestPath(Galaxy other) {
        long x = Math.abs(this.x - other.x);
        long y = Math.abs(this.y - other.y);
        return x + y;
    }
}

public class Main {
    private static Vector<Galaxy> parseContent(String content) {
        String[] lines = content.split("\\n");
        Vector<Galaxy> galaxies = new Vector<>();
        long row = 0;
        for (String line : lines) {
            long col = 0;
            byte[] bytes = line.getBytes();
            for (byte b : bytes) {
                if (b == '#') {
                    galaxies.add(new Galaxy(row, col));
                }
                col++;
            }
            row++;
        }
        return galaxies;
    }

    private static long computeExpandedDimension(long position, Vector<Long> filledPositions, long factor) {
        long expanded = 0;
        for (long dimension = 0; dimension < position; dimension++) {
            if (!filledPositions.contains(dimension)) {
                expanded += factor - 1;
            }
        }
        return position + expanded;
    }
    
    private static Vector<Galaxy> expandGalaxies(Vector<Galaxy> galaxies, long factor) {
        Vector<Long> filledRows = new Vector<>();
        Vector<Long> filledCols = new Vector<>();
        for (Galaxy galaxy : galaxies) {
            if (!filledRows.contains(galaxy.x)) {
                filledRows.add(galaxy.x);
            }
            if (!filledCols.contains(galaxy.y)) {
                filledCols.add(galaxy.y);
            }
        }
        Vector<Galaxy> expandedGalaxies = new Vector<>();
        for (Galaxy galaxy : galaxies) {
            long expandedX = computeExpandedDimension(galaxy.x, filledRows, factor);
            long expandedY = computeExpandedDimension(galaxy.y, filledCols, factor);
            expandedGalaxies.add(new Galaxy(expandedX, expandedY));
        }
        return expandedGalaxies;
    }

    private static long sumShortestPath(Vector<Galaxy> galaxies) {
        long sum = 0;
        for (int i = 0; i < galaxies.size(); i++) {
            for (int j = i+1; j < galaxies.size(); j++) {
                sum += galaxies.get(i).shortestPath(galaxies.get(j));
            }
        }
        return sum;
    }

    public static long parseAndComputeShortestPath(String filepath, long factor) throws IOException {
        String content = new String(Files.readAllBytes(Paths.get(filepath)));
        Vector<Galaxy> galaxies = parseContent(content);
        Vector<Galaxy> expandedGalaxies = expandGalaxies(galaxies, factor);
        return sumShortestPath(expandedGalaxies);
    }

    public static long part01(String filepath) throws IOException {
        return parseAndComputeShortestPath(filepath, 2);
    }

    public static long part02(String filepath) throws IOException {
        return parseAndComputeShortestPath(filepath, 1000000);
    }

    public static void main(String[] args) {
        try {
            System.out.println("Part 01: " + part01("day11/input.txt"));
            System.out.println("Part 02: " + part02("day11/input.txt"));
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
