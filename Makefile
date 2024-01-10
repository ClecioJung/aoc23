DAYS = $(wildcard day*)

all: $(DAYS)

day01 day02 day03 day04 day05:
	@echo "Running $@"
	cd $@ && cargo run --release
	@echo

day06 day07 day08 day09 day10:
	@echo "Running $@"
	cd $@ && go run main.go
	@echo

day11 day12 day13 day14 day15:
	@echo "Running $@"
	javac $@/Main.java && java $@.Main 
	@echo

day16:
	@echo "Running $@"
	cd $@ && ./main.js
	@echo

day17:
	@echo "Running $@"
	cd $@ && ./main.py
	@echo

day18:
	cd $@ && make -s run
	@echo

day19:
	@echo "Running $@"
	cd $@ && ./main.lua
	@echo

day20:
	@echo "Running $@"
	cd $@ && make -s run
	@echo

day21:
	@echo "Running $@"
	cd $@ && ./main.jl
	@echo

day22:
	@echo "Running $@"
	cd $@ && ./main.pm
	@echo

day23:
	@echo "Running $@"
	cd $@ && make -s run
	@echo

day24:
	@echo "Running $@"
	cd $@ && ./main.php
	@echo

day25:
	@echo "Running $@"
	cd $@ && make -s run
	@echo

clean:
	rm -rf *.o *.exe *.class */target */META-INF

.PHONY: all clean $(DAYS)