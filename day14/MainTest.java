package day14;

import org.junit.Test;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.fail;

import java.io.IOException;

public class MainTest {
    @Test
    public void testPart1() {
        try {
            assertEquals(136, Main.part01("day14/sample.txt"));
        } catch (IOException e) {
            fail("Shouldn't raise an exception!");
        }
    }

    @Test
    public void testResultPart1() {
        try {
            assertEquals(108889, Main.part01("day14/input.txt"));
        } catch (IOException e) {
            fail("Shouldn't raise an exception!");
        }
    }

    @Test
    public void testPart2() {
        try {
            assertEquals(64, Main.part02("day14/sample.txt"));
        } catch (IOException e) {
            fail("Shouldn't raise an exception!");
        }
    }
    
    @Test
    public void testResultPart2() {
        try {
            assertEquals(104671, Main.part02("day14/input.txt"));
        } catch (IOException e) {
            fail("Shouldn't raise an exception!");
        }
    }
}
