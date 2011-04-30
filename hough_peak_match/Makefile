CC:=g++
CXX:=g++
VPATH:=src:obj
CXXFLAGS:=-Wall -Wextra -Weffc++ -pedantic

EXECUTABLES:=assign_peaks hough_sample_params equivalent_db simple_hough valid_db

all: $(EXECUTABLES)

obj/%.o : %.c
	$(COMPILE.c) -MD -o $@ $<
	@cp obj/$*.d obj/$*.deps; \
	sed -e 's/#.*//' -e 's/^[^:]*: *//' -e 's/ *\\$$//' \
	    -e '/^$$/ d' -e 's/$$/ :/' < obj/$*.d >> obj/$*.deps; \
	    rm -f obj/$*.d

obj/%.o : %.cpp
	$(COMPILE.cpp) -MD -o $@ $<
	@cp obj/$*.d obj/$*.deps; \
	sed -e 's/#.*//' -e 's/^[^:]*: *//' -e 's/ *\\$$//' \
	    -e '/^$$/ d' -e 's/$$/ :/' < obj/$*.d >> obj/$*.deps; \
	    rm -f obj/$*.d

test:
	cd tests; ./runalltests.pl

testverbose:
	cd tests; ./runalltests.pl verbose


clean:
	-rm $(EXECUTABLES)
	-rm obj/*

.PHONY: all clean test