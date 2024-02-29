include ../include/Makefile.inc

OBJ         = $(shell find . -name *.o 2>/dev/null)
DEP         = $(OBJ:.o=.d)

# -include $(DEP)

all: test_point
test: test.o 
	g++ -o test_point test_point.o
test.o:
	g++ $(INCLUDE)  -c -o test_point.o test_point.cpp

.PHONY: clean
clean:
	rm -rf ./*.o ./test_point