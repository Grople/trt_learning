include ../include/Makefile.inc

OBJ         = $(shell find . -name *.o 2>/dev/null)
DEP         = $(OBJ:.o=.d)

# -include $(DEP)

all: test
test: test.o 
	g++ -o test test.o
test.o:
	g++ $(INCLUDE)  -c -o test.o test.cpp

.PHONY: clean
clean:
	rm -rf ./*.o ./test