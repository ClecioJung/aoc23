
SRC = main.kt
EXEC = main.jar

all: $(EXEC)

run: $(EXEC)
	java -ea -jar $(EXEC)

$(EXEC): $(SRC)
	kotlinc $(filter %.kt,$^) -include-runtime -d $@

clean:
	rm -rf *.jar

.PHONY: run clean
