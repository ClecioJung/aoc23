package day12;

import org.junit.Test;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.fail;

import java.io.IOException;

public class MainTest {
    @Test
    public void testPart1() {
        try {
            assertEquals(21, Main.part01("day12/sample.txt"));
        } catch (IOException e) {
            fail("Shouldn't raise an exception!");
        }
    }

    @Test
    public void testResultPart1() {
        try {
            assertEquals(7191, Main.part01("day12/input.txt"));
        } catch (IOException e) {
            fail("Shouldn't raise an exception!");
        }
    }

    @Test
    public void testPart2() {
        try {
            assertEquals(525152, Main.part02("day12/sample.txt"));
        } catch (IOException e) {
            fail("Shouldn't raise an exception!");
        }
    }
    
    @Test
    public void testResultPart2() {
        try {
            assertEquals(6512849198636L, Main.part02("day12/input.txt"));
        } catch (IOException e) {
            fail("Shouldn't raise an exception!");
        }
    }
}
