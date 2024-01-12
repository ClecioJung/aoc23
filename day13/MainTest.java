package day13;

import org.junit.Test;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.fail;

import java.io.IOException;

public class MainTest {
    @Test
    public void testPart1() {
        try {
            assertEquals(405, Main.part01("day13/sample.txt"));
        } catch (IOException e) {
            fail("Shouldn't raise an exception!");
        }
    }

    @Test
    public void testResultPart1() {
        try {
            assertEquals(31265, Main.part01("day13/input.txt"));
        } catch (IOException e) {
            fail("Shouldn't raise an exception!");
        }
    }

    @Test
    public void testPart2() {
        try {
            assertEquals(400, Main.part02("day13/sample.txt"));
        } catch (IOException e) {
            fail("Shouldn't raise an exception!");
        }
    }
    
    @Test
    public void testResultPart2() {
        try {
            assertEquals(39359, Main.part02("day13/input.txt"));
        } catch (IOException e) {
            fail("Shouldn't raise an exception!");
        }
    }
}
