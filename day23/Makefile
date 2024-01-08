
SRC = main.d
EXEC = main.exe

all: $(EXEC)

run: $(EXEC)
	./$(EXEC)

$(EXEC): $(SRC)
	dmd -of$@ -O -release -inline -noboundscheck $(filter %.d,$^)

clean:
	rm -f $(EXEC) *.o

.PHONY: run clean
