package day14;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;

public class Main {
    private static char[][] parseContent(String content) {
        String[] lines = content.split("\\n");
        char[][] table = new char[lines.length][];
        for (int i = 0; i < lines.length; i++) {
            table[i] = lines[i].toCharArray();
        }
        return table;
    }

    private static void rollNorth(char[][] table) {
        for (int col = 0; col < table[0].length; col++) {
            int nextValidRow = 0;
            for (int row = 0; row < table.length; row++) {
                switch (table[row][col]) {
                    case '#': // Cube-shaped rocks
                        nextValidRow = row + 1;
                        break;
                    case 'O': // Rounded rock
                        table[row][col] = '.';
                        table[nextValidRow][col] = 'O';
                        nextValidRow++;
                        break;
                }
            }
        }
    }

    private static void rollSouth(char[][] table) {
        for (int col = 0; col < table[0].length; col++) {
            int nextValidRow = table.length-1;
            for (int row = table.length-1; row >= 0; row--) {
                switch (table[row][col]) {
                    case '#': // Cube-shaped rocks
                        nextValidRow = row - 1;
                        break;
                    case 'O': // Rounded rock
                        table[row][col] = '.';
                        table[nextValidRow][col] = 'O';
                        nextValidRow--;
                        break;
                }
            }
        }
    }

    private static void rollWest(char[][] table) {
        for (int row = 0; row < table.length; row++) {
            int nextValidCol = 0;
            for (int col = 0; col < table[0].length; col++) {
                switch (table[row][col]) {
                    case '#': // Cube-shaped rocks
                        nextValidCol = col + 1;
                        break;
                    case 'O': // Rounded rock
                        table[row][col] = '.';
                        table[row][nextValidCol] = 'O';
                        nextValidCol++;
                        break;
                }
            }
        }
    }

    private static void rollEast(char[][] table) {
        for (int row = 0; row < table.length; row++) {
            int nextValidCol = table[0].length - 1;
            for (int col = table[0].length - 1; col >= 0; col--) {
                switch (table[row][col]) {
                    case '#': // Cube-shaped rocks
                        nextValidCol = col - 1;
                        break;
                    case 'O': // Rounded rock
                        table[row][col] = '.';
                        table[row][nextValidCol] = 'O';
                        nextValidCol--;
                        break;
                }
            }
        }
    }

    private static int computeLoad(final char[][] table) {
        int load = 0;
        for (int col = 0; col < table[0].length; col++) {
            for (int row = 0; row < table.length; row++) {
                if (table[row][col] == 'O') { // Rounded rock
                    final int weight = table.length - row;
                    load += weight;
                }
            }
        }
        return load;
    }

    private static int checkForPeriodicity(List<Integer> array) {
        for (int period = 2; period < array.size()/2; period++) {
            boolean isPeriodic = true;
            for (int k = 0; k < period; k++) {
                final int i = array.size() - 1 - k;
                final int j = i - period;
                if (!array.get(i).equals(array.get(j))) {
                    isPeriodic = false;
                    break;
                }
            }
            if (isPeriodic) {
                return period;
            }
        }
        return -1;
    }

    public static int part01(String filepath) throws IOException {
        String content = new String(Files.readAllBytes(Paths.get(filepath)));
        char[][] table = parseContent(content);
        rollNorth(table);
        return computeLoad(table);
    }

    public static int part02(String filepath) throws IOException {
        String content = new String(Files.readAllBytes(Paths.get(filepath)));
        char[][] table = parseContent(content);
        final int numberOfCycles = 1000000000;
        List<Integer> loadPerCycle = new ArrayList<>();
        int period = -1;
        for (int cycle = 0; cycle < numberOfCycles; cycle++) {
            rollNorth(table);
            rollWest(table);
            rollSouth(table);
            rollEast(table);
            loadPerCycle.add(computeLoad(table));
            period = checkForPeriodicity(loadPerCycle);
            if (period > 0) {
                break;
            }
        }
        final int index = loadPerCycle.size() - 1 - period + (numberOfCycles - loadPerCycle.size()) % period;
        return loadPerCycle.get(index);
    }

    public static void main(String[] args) {
        try {
            System.out.println("Part 01: " + part01("day14/input.txt"));
            System.out.println("Part 02: " + part02("day14/input.txt"));
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
