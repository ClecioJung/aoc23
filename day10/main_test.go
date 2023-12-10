package main

import (
	"testing"
)

func Test1Part01(t *testing.T) {
	expected := 4
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
	expected := 8
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
	expected := 6846
	result, err := part01("input.txt")
	if err != nil {
		t.Errorf("Error reading file: %v", err)
		return
	}
	if result != expected {
		t.Errorf("Part01 returned %d, expected %d", result, expected)
	}
}

func Test1Part02(t *testing.T) {
	expected := 4
	result, err := part02("sample3.txt")
	if err != nil {
		t.Errorf("Error reading file: %v", err)
		return
	}
	if result != expected {
		t.Errorf("Part02 returned %d, expected %d", result, expected)
	}
}

func Test2Part02(t *testing.T) {
	expected := 4
	result, err := part02("sample4.txt")
	if err != nil {
		t.Errorf("Error reading file: %v", err)
		return
	}
	if result != expected {
		t.Errorf("Part02 returned %d, expected %d", result, expected)
	}
}

func Test3Part02(t *testing.T) {
	expected := 8
	result, err := part02("sample5.txt")
	if err != nil {
		t.Errorf("Error reading file: %v", err)
		return
	}
	if result != expected {
		t.Errorf("Part02 returned %d, expected %d", result, expected)
	}
}

func Test4Part02(t *testing.T) {
	expected := 10
	result, err := part02("sample6.txt")
	if err != nil {
		t.Errorf("Error reading file: %v", err)
		return
	}
	if result != expected {
		t.Errorf("Part02 returned %d, expected %d", result, expected)
	}
}

func TestResultPart02(t *testing.T) {
	expected := 325
	result, err := part02("input.txt")
	if err != nil {
		t.Errorf("Error reading file: %v", err)
		return
	}
	if result != expected {
		t.Errorf("Part02 returned %d, expected %d", result, expected)
	}
}
