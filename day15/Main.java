package day15;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;

class Lens {
    public String label;
    public int focalLength;

    Lens(String label, int focalLength) {
        this.label = label;
        this.focalLength = focalLength;
    }
}

public class Main {
    private static int hash(String str) {
        int value = 0;
        for (int i = 0; i < str.length(); i++) {
            value += str.charAt(i);
            value *= 17;
            value %= 256;
        }
        return value;
    }

    public static long part01(String filepath) throws IOException {
        String content = new String(Files.readAllBytes(Paths.get(filepath)));
        String[] sequences = content.split(",");
        long sum = 0;
        for (String sequence : sequences) {
            sum += hash(sequence);
        }
        return sum;
    }

    private static int findLens(List<Lens> lens, String label) {
        for (int i = 0; i < lens.size(); i++) {
            if (lens.get(i).label.equals(label)) {
                return i;
            }
        }
        return -1;
    }

    public static long part02(String filepath) throws IOException {
        String content = new String(Files.readAllBytes(Paths.get(filepath)));
        String[] sequences = content.split(",");
        List<List<Lens>> box = new ArrayList<>();
        for (int i = 0; i < 256; i++) {
            box.add(new ArrayList<>());
        }
        for (String sequence : sequences) {
            final int dashIndex = sequence.indexOf('-');
            if (dashIndex >= 0) {
                final String label = sequence.substring(0, dashIndex);
                final int boxIndex = hash(label);
                final int lensIndex = findLens(box.get(boxIndex), label);
                if (lensIndex >= 0) {
                    box.get(boxIndex).remove(lensIndex);
                }
            } else {
                final int equalsIndex = sequence.indexOf('=');
                final String label = sequence.substring(0, equalsIndex);
                final int focalLength = Integer.parseInt(sequence.substring(equalsIndex+1));
                final int boxIndex = hash(label);
                final int lensIndex = findLens(box.get(boxIndex), label);
                if (lensIndex >= 0) {
                    box.get(boxIndex).get(lensIndex).focalLength = focalLength;
                } else {
                    box.get(boxIndex).add(new Lens(label, focalLength));
                }
            }
        }
        long focusingPower = 0;
        for (int i = 0; i < box.size(); i++) {
            for (int j = 0; j < box.get(i).size(); j++) {
                focusingPower += (i+1) * (j+1) * box.get(i).get(j).focalLength;
            }
        }
        return focusingPower;
    }

    public static void main(String[] args) {
        try {
            System.out.println("Part 01: " + part01("day15/input.txt"));
            System.out.println("Part 02: " + part02("day15/input.txt"));
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
