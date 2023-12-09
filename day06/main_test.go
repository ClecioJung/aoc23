package main

import (
	"testing"
)

func TestPart01(t *testing.T) {
	expected := 288
	result, err := part01("sample.txt")
	if err != nil {
		t.Errorf("Error reading file: %v", err)
		return
	}
	if result != expected {
		t.Errorf("Part01 returned %d, expected %d", result, expected)
	}
}

func TestResultPart01(t *testing.T) {
	expected := 303600
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
	expected := 71503
	result, err := part02("sample.txt")
	if err != nil {
		t.Errorf("Error reading file: %v", err)
		return
	}
	if result != expected {
		t.Errorf("Part02 returned %d, expected %d", result, expected)
	}
}

func TestResultPart02(t *testing.T) {
	expected := 23654842
	result, err := part02("input.txt")
	if err != nil {
		t.Errorf("Error reading file: %v", err)
		return
	}
	if result != expected {
		t.Errorf("Part02 returned %d, expected %d", result, expected)
	}
}
