
SRC = main.pas
EXEC = main.exe

all: $(EXEC)

run: $(EXEC)
	./$(EXEC)

$(EXEC): $(SRC)
	fpc -o$@ $(filter %.pas,$^)

clean:
	rm -f $(EXEC) *.o

.PHONY: run clean
