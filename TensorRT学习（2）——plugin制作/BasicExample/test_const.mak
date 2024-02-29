include ../include/Makefile.inc

OBJ         = $(shell find . -name *.o 2>/dev/null)
DEP         = $(OBJ:.o=.d)

# -include $(DEP)

all: test_const
test: test.o 
	g++ -o test_const test_const.o
test.o:
	g++ $(INCLUDE)  -c -o test_const.o test_const.cpp

.PHONY: clean
clean:
	rm -rf ./*.o ./test_const