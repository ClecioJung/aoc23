package main

import "testing"

func TestPart01(t *testing.T) {
	expected := 2
	result, err := part01("sample1.txt")
	if err != nil {
		t.Errorf("Error reading file: %v", err)
		return
	}
	if result != expected {
		t.Errorf("Part01 returned %d, expected %d", result, expected)
	}
}

func Test2Part01(t *testing.T) {
	expected := 6
	result, err := part01("sample2.txt")
	if err != nil {
		t.Errorf("Error reading file: %v", err)
		return
	}
	if result != expected {
		t.Errorf("Part01 returned %d, expected %d", result, expected)
	}
}

func ResultPart01(t *testing.T) {
	expected := 19099
	result, err := part01("input.txt")
	if err != nil {
		t.Errorf("Error reading file: %v", err)
		return
	}
	if result != expected {
		t.Errorf("Part01 returned %d, expected %d", result, expected)
	}
}

func TestPart02(t *testing.T) {
	expected := 6
	result, err := part02("sample3.txt")
	if err != nil {
		t.Errorf("Error reading file: %v", err)
		return
	}
	if result != expected {
		t.Errorf("Part02 returned %d, expected %d", result, expected)
	}
}

func ResultPart02(t *testing.T) {
	expected := 17099847107071
	result, err := part02("input.txt")
	if err != nil {
		t.Errorf("Error reading file: %v", err)
		return
	}
	if result != expected {
		t.Errorf("Part02 returned %d, expected %d", result, expected)
	}
}
