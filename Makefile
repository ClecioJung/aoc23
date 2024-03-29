
# ----------------------------------------
# Definitions
# ----------------------------------------

LIB = lib
JUNIT_LINK = https://repo1.maven.org/maven2/junit/junit/4.12/junit-4.12.jar
HAMCREST_LINK = https://repo1.maven.org/maven2/org/hamcrest/hamcrest-core/1.3/hamcrest-core-1.3.jar
JUNIT = $(LIB)/junit-4.12.jar
HAMCREST = $(LIB)/hamcrest-core-1.3.jar

PYTHON_INTERPRETER := $(shell which pypy3 2>/dev/null || echo python3)

DAYS = $(wildcard day*)
DAYS_TEST = $(addsuffix -test,$(DAYS))

# ----------------------------------------
# Rules
# ----------------------------------------

all: $(DAYS)

test: $(DAYS_TEST)

$(LIB):
	mkdir -p $@

$(JUNIT): | $(LIB)
	wget -P $(LIB) $(JUNIT_LINK)
	touch $@

$(HAMCREST): | $(LIB)
	wget -P $(LIB) $(HAMCREST_LINK)
	touch $@

day01 day02 day03 day04 day05:
	@echo "Running $@"
	cd $@ && cargo run --release
	@echo

day01-test day02-test day03-test day04-test day05-test:
	@echo "Running $@"
	cd $(patsubst %-test,%,$@) && cargo test --release
	@echo

day06 day07 day08 day09 day10:
	@echo "Running $@"
	cd $@ && go run main.go
	@echo

day06-test day07-test day08-test day09-test day10-test:
	@echo "Running $@"
	cd $(patsubst %-test,%,$@) && go test
	@echo

day11 day12 day13 day14 day15:
	@echo "Running $@"
	javac $@/Main.java && java $@.Main 
	@echo

day11-test day12-test day13-test day14-test day15-test: $(JUNIT) $(HAMCREST)
	@echo "Running $@"
	javac -cp .:$(JUNIT) $(patsubst %-test,%,$@)/MainTest.java $(patsubst %-test,%,$@)/Main.java
	java -cp .:$(JUNIT):$(HAMCREST) org.junit.runner.JUnitCore $(patsubst %-test,%,$@).MainTest
	@echo

day16 day16-test:
	@echo "Running $@"
	cd $(patsubst %-test,%,$@) && ./main.js
	@echo

day17 day17-test:
	@echo "Running $@"
	cd $(patsubst %-test,%,$@) && $(PYTHON_INTERPRETER) main.py
	@echo

day18 day18-test:
	@echo "Running $@"
	cd $(patsubst %-test,%,$@) && make -s run
	@echo

day19 day19-test:
	@echo "Running $@"
	cd $(patsubst %-test,%,$@) && ./main.lua
	@echo

day20 day20-test:
	@echo "Running $@"
	cd $(patsubst %-test,%,$@) && make -s run
	@echo

day21 day21-test:
	@echo "Running $@"
	cd $(patsubst %-test,%,$@) && ./main.jl
	@echo

day22:
	@echo "Running $@"
	cd $@ && ./main.pm
	@echo

day22-test:
	@echo "Running $@"
	cd $(patsubst %-test,%,$@) && ./main_test.t
	@echo

day23 day23-test:
	@echo "Running $@"
	cd $(patsubst %-test,%,$@) && make -s run
	@echo

day24:
	@echo "Running $@"
	cd $@ && ./main.php
	@echo

day24-test:
	@echo "Running $@"
	cd $(patsubst %-test,%,$@) && php -d zend.assertions=1 main.php
	@echo

day25 day25-test:
	@echo "Running $@"
	cd $(patsubst %-test,%,$@) && make -s run
	@echo

clean:
	rm -rf lib bin *.o *.exe *.class *.jar */target

install-julia:
	wget https://julialang-s3.julialang.org/bin/linux/x64/1.6/julia-1.6.7-linux-x86_64.tar.gz
	tar zxvf julia-1.6.7-linux-x86_64.tar.gz
	sudo mv julia-1.6.7/ /opt/
	sudo ln -s /opt/julia-1.6.7/bin/julia /usr/bin/julia
	rm julia*.tar.gz

remove-julia:
	sudo rm -rf /opt/julia-1.6.7/
	sudo rm -f /usr/bin/julia

install-dmd:
	wget -qO dmd.deb http://downloads.dlang.org/releases/2.x/2.106.1/dmd_2.106.1-0_amd64.deb
	sudo apt install -y ./dmd.deb
	rm -rf dmd.deb

install: install-julia install-dmd
	sudo apt-get update
	sudo apt-get -y install make cargo golang-go nodejs python3 pypy3 build-essential lua5.4 fpc perl php
	sudo apt-get -y install default-jdk default-jre kotlin

remove: remove-julia
	sudo apt remove -y cargo golang-go nodejs pypy3 lua5.4 fpc dmd
	sudo apt remove -y default-jdk default-jre kotlin
	sudo apt autoremove -y

.PHONY: all clean $(DAYS) $(DAYS_TEST) \
	install install-julia install-dmd \
	remove remove-julia

# ----------------------------------------
# End
# ----------------------------------------
