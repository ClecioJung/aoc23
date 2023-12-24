package day13;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;

class Pattern {
    List<String> lines;
    
    Pattern(List<String> lines) {
        this.lines = new ArrayList<String>(lines);
    }

    private int rows() {
        return lines.size();
    }

    private int columns() {
        return lines.get(0).length();
    }

    private int rowsDifferences(int i, int j) {
        int differences = 0;
        for (int k = 0; k < columns(); k++) {
            if (lines.get(i).charAt(k) != lines.get(j).charAt(k)) {
                differences++;
            }
        }
        return differences;
    }

    private int colsDifferences(int i, int j) {
        int differences = 0;
        for (String line : lines) {
            if (line.charAt(i) != line.charAt(j)) {
                differences++;
            }
        }
        return differences;
    }

    private int horizontalDifferences(int lines) {
        int differences = 0;
        for (int i = lines, j = lines+1; i >= 0 && j < rows(); i--, j++) {
            differences += rowsDifferences(i, j);
        }
        return differences;
    }

    private int verticalDifferences(int col) {
        int differences = 0;
        for (int i = col, j = col+1; i >= 0 && j < columns(); i--, j++) {
            differences += colsDifferences(i, j);
        }
        return differences;
    }
    
    int horizontalReflection(final int differences) {
        for (int rowReflection = 0; (rowReflection + 1) < rows(); rowReflection++) {
            if (horizontalDifferences(rowReflection) == differences) {
                return rowReflection+1;
            }
        }
        return -1;
    }

    public int verticalReflection(final int differences) {
        for (int colReflection = 0; (colReflection + 1) < columns(); colReflection++) {
            if (verticalDifferences(colReflection) == differences) {
                return colReflection+1;
            }
        }
        return -1;
    }
}

public class Main {
    private static List<Pattern> parseContent(String content) {
        String[] lines = content.split("\\n");
        List<String> currentPattern = new ArrayList<>();
        List<Pattern> patterns = new ArrayList<>();
        for (String line : lines) {
            if (line.length() == 0) {
                patterns.add(new Pattern(currentPattern));
                currentPattern.clear();
                continue;
            }
            currentPattern.add(line);
        }
        patterns.add(new Pattern(currentPattern));
        return patterns;
    }

    private static int sumReflections(String filepath, final int differences) throws IOException {
        String content = new String(Files.readAllBytes(Paths.get(filepath)));
        List<Pattern> patterns = parseContent(content);
        List<Integer> reflections = new ArrayList<>();
        for (Pattern pattern : patterns) {
            int verticalReflection = pattern.verticalReflection(differences);
            int horizontalReflection = pattern.horizontalReflection(differences);
            if (verticalReflection > horizontalReflection) {
                reflections.add(verticalReflection);
            } else {
                reflections.add(100 * horizontalReflection);
            }
        }
        return reflections.stream().reduce(0, Integer::sum);
    }
    
    public static int part01(String filepath) throws IOException {
        return sumReflections(filepath, 0);
    }

    public static int part02(String filepath) throws IOException {
        return sumReflections(filepath, 1);
    }

    public static void main(String[] args) {
        try {
            System.out.println("Part 01: " + part01("day13/input.txt"));
            System.out.println("Part 02: " + part02("day13/input.txt"));
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
