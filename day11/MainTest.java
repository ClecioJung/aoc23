package day11;


import org.junit.Test;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.fail;

import java.io.IOException;

public class MainTest {
    @Test
    public void testPart1() {
        try {
            assertEquals(374, Main.part01("day11/sample.txt"));
        } catch (IOException e) {
            fail("Shouldn't raise an exception!");
        }
    }

    @Test
    public void testResultPart1() {
        try {
            assertEquals(9724940, Main.part01("day11/input.txt"));
        } catch (IOException e) {
            fail("Shouldn't raise an exception!");
        }
    }

    @Test
    public void test1Part2() {
        try {
            assertEquals(1030, Main.parseAndComputeShortestPath("day11/sample.txt", 10));
        } catch (IOException e) {
            fail("Shouldn't raise an exception!");
        }
    }

    @Test
    public void test2Part2() {
        try {
            assertEquals(8410, Main.parseAndComputeShortestPath("day11/sample.txt", 100));
        } catch (IOException e) {
            fail("Shouldn't raise an exception!");
        }
    }

    @Test
    public void testResultPart2() {
        try {
            assertEquals(569052586852L, Main.part02("day11/input.txt"));
        } catch (IOException e) {
            fail("Shouldn't raise an exception!");
        }
    }
}
