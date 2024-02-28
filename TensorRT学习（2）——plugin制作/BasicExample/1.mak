include ../../include/Makefile.inc

SOURCE_CU   = $(shell find . -name '*.cu' 2>/dev/null)
SOURCE_PY   = $(shell find . -name '*.py' 2>/dev/null)
OBJ         = $(shell find . -name *.o 2>/dev/null)
DEP         = $(OBJ:.o=.d)
TARGET_SO   = $(SOURCE_CU:.cu=.so)

# all:
# 	@echo $(OBJ)
# 	@echo $(DEP)
# 	@echo $(SOURCE_CU)
# 	@echo $(TARGET_SO)
# 	@echo $(NVCC)
# 	@echo $(SOFLAG)
# 	@echo $(LDFLAG)
# 	@echo $(CUFLAG)


-include $(DEP)

all: $(TARGET_SO)


# $@ 指的是 %.so   即目标文件名
# $< 指的是 %.o  第一个依赖文件
# $+ 指的是 所有依赖文件, 与 $^ 很像，只是不去掉重复的依赖目标
%.so: %.o
	$(NVCC) $(SOFLAG) $(LDFLAG) -o $@ $+    

%.o: %.cu
	$(NVCC) $(CUFLAG) $(INCLUDE) -M -MT $@ -o $(@:.o=.d) $<
#	$(NVCC) $(CUFLAG) $(INCLUDE)  $@ -o $(@:.o=.d) $<
	$(NVCC) $(CUFLAG) $(INCLUDE) -o $@ -c $<

.PHONY: test
test:
	make clean
	make
	python3 $(SOURCE_PY)

.PHONY: clean
clean:
	rm -rf ./*.d ./*.o ./*.so ./*.exe ./*.plan
