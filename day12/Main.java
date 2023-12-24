package day12;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;

enum Spring {
  OPERATIONAL,
  DAMAGED,
  UNKNOWN,
}

class SpringRow {
    List<Spring> springs;
    List<Integer> groups;

    public SpringRow() {
        this.springs = new ArrayList<>();
        this.groups = new ArrayList<>();
    }

    public SpringRow(SpringRow row) {
        this.springs = new ArrayList<>(row.springs);
        this.groups = new ArrayList<>(row.groups);
    }

    private boolean couldBeGroup(final int springIndex, final int group) {
        if ((springIndex + group) > springs.size()) {
            return false;
        }
        for (int i = springIndex; i < (springIndex + group); i++) {
            if (springs.get(i) == Spring.OPERATIONAL) {
                return false;
            }
        }
        if ((springIndex + group) == springs.size()) {
            return true;
        }
        if (springs.get(springIndex + group) == Spring.DAMAGED) {
            return false;
        }
        return true;
    }

    private long getCachedArrangements(long[][] cache, final int springIndex, final int groupIndex) {
        if (springIndex >= springs.size()) {
            if (groupIndex >= groups.size()) {
                return 1;
            }
            return 0;
        }
        if (groupIndex >= groups.size()) {
            for (int i = springIndex; i < springs.size(); i++) {
                if (springs.get(i) == Spring.DAMAGED) {
                    return 0;
                }
            }
            return 1;
        }
        if (cache[springIndex][groupIndex] != -1) {
            return cache[springIndex][groupIndex];
        }
        long arrangements = 0;
        final Spring spring = springs.get(springIndex);
        if (spring == Spring.UNKNOWN || spring == Spring.OPERATIONAL) {
            arrangements += getCachedArrangements(cache, springIndex+1, groupIndex);
        }
        final int group = groups.get(groupIndex);
        if (couldBeGroup(springIndex, group)) {
            arrangements += getCachedArrangements(cache, springIndex+group + 1, groupIndex+1);
        }
        cache[springIndex][groupIndex] = arrangements;
        return arrangements;
    }

    public long arrangements() {
        long[][] cache = new long[springs.size()][groups.size()];
        for (int i = 0; i < springs.size(); i++) {
            for (int j = 0; j < groups.size(); j++) {
                cache[i][j] = -1;
            }
        }
        return getCachedArrangements(cache, 0, 0);
    }
}

public class Main {
    private static List<SpringRow> parseContent(String content) {
        String[] lines = content.split("\\n");
        List<SpringRow> springs = new ArrayList<>();
        for (String line : lines) {
            String[] parts = line.split(" ");
            SpringRow row = new SpringRow();
            byte[] bytes = parts[0].getBytes();
            for (byte b : bytes) {
                switch (b) {
                    case '.':
                    row.springs.add(Spring.OPERATIONAL);
                    break;
                    case '#':
                    row.springs.add(Spring.DAMAGED);
                    break;
                    case '?':
                    row.springs.add(Spring.UNKNOWN);
                    break;
                }
            }
            String[] groups = parts[1].split(",");
            for (String group : groups) {
                row.groups.add(Integer.parseInt(group));
            }
            springs.add(row);
        }
        return springs;
    }

    private static long sumRowArrangements(List<SpringRow> springs) {
        long sum = 0;
        for (SpringRow spring : springs) {
            sum += spring.arrangements();
        }
        return sum;
    }
    
    public static long part01(String filepath) throws IOException {
        String content = new String(Files.readAllBytes(Paths.get(filepath)));
        List<SpringRow> springs = parseContent(content);
        return sumRowArrangements(springs);
    }

    private static List<SpringRow> unfoldRecords(List<SpringRow> springs) {
        List<SpringRow> unfoldedSprings = new ArrayList<>();
        for (SpringRow springRow : springs) {
            SpringRow newSpringRow = new SpringRow(springRow);
            for (int i = 0; i < 4; i++) {
                newSpringRow.springs.add(Spring.UNKNOWN);
                newSpringRow.springs.addAll(springRow.springs);
                newSpringRow.groups.addAll(springRow.groups);
            }
            unfoldedSprings.add(newSpringRow);
        }
        return unfoldedSprings;
    }

    public static long part02(String filepath) throws IOException {
        String content = new String(Files.readAllBytes(Paths.get(filepath)));
        List<SpringRow> springs = parseContent(content);
        List<SpringRow> unfoldedSprings = unfoldRecords(springs);
        return sumRowArrangements(unfoldedSprings);
    }

    public static void main(String[] args) {
        try {
            System.out.println("Part 01: " + part01("day12/input.txt"));
            System.out.println("Part 02: " + part02("day12/input.txt"));
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
