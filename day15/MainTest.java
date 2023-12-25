package day15;

import org.junit.Test;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.fail;

import java.io.IOException;

public class MainTest {
    @Test
    public void testPart1() {
        try {
            assertEquals(1320, Main.part01("day15/sample.txt"));
        } catch (IOException e) {
            fail("Shouldn't raise an exception!");
        }
    }

    @Test
    public void testResultPart1() {
        try {
            assertEquals(512283, Main.part01("day15/input.txt"));
        } catch (IOException e) {
            fail("Shouldn't raise an exception!");
        }
    }

    @Test
    public void testPart2() {
        try {
            assertEquals(145, Main.part02("day15/sample.txt"));
        } catch (IOException e) {
            fail("Shouldn't raise an exception!");
        }
    }
    
    @Test
    public void testResultPart2() {
        try {
            assertEquals(215827, Main.part02("day15/input.txt"));
        } catch (IOException e) {
            fail("Shouldn't raise an exception!");
        }
    }
}
