
CXX = g++
CXXFLAGS = -std=c++17 -Wall -Wextra -Werror -pedantic

SRC = main.cpp
EXEC = main.exe

all: $(EXEC)

run: $(EXEC)
	./$(EXEC)

$(EXEC): $(SRC)
	$(CXX) $(CXXFLAGS) -o $@ $(filter %.cpp,$^)

clean:
	rm -f $(EXEC)

.PHONY: run clean
