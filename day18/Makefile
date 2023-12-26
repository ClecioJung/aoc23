
CXX = g++
CXXFLAGS = -std=c++17 -Wall -Wextra -Werror -pedantic

SRC = main.cpp
EXEC = main.exe

all: $(EXEC)

$(EXEC): $(SRC)
	$(CXX) $(CXXFLAGS) -o $@ $(filter %.cpp,$^)

clean:
	rm -f $(EXEC)
