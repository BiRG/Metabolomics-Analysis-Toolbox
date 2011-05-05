CC:=g++
CXX:=g++
VPATH:=src:obj:src/tests
CXXFLAGS:=-Wall -Wextra -Weffc++ -pedantic -g
EXECUTABLES:=assign_peaks hough_sample_params equivalent_db simple_hough \
	valid_db\
	tests/006-split_function.compiled.t\
	tests/007-collection_is.compiled.t
LIBRARYOBJS:=obj/peak_matching_database.o obj/utils.o
LDLIBS:=-ltap++

all: $(EXECUTABLES)

#############
# Executables
#############

assign_peaks: obj/assign_peaks.o $(LIBRARYOBJS)

hough_sample_params: obj/hough_sample_params.o $(LIBRARYOBJS)

equivalent_db: obj/equivalent_db.o $(LIBRARYOBJS)

simple_hough: obj/simple_hough.o $(LIBRARYOBJS)

valid_db: obj/valid_db.o $(LIBRARYOBJS)

tests/006-split_function.compiled.t: obj/tests/006-split_function.compiled.t.o $(LIBRARYOBJS)

tests/007-collection_is.compiled.t: obj/tests/007-collection_is.compiled.t.o $(LIBRARYOBJS)

#############
# Utility targets
#############

test: all
	cd tests; ./runalltests.pl

testverbose: all
	cd tests; ./runalltests.pl verbose


docs: doc/html/index.html

doc/html/index.html: src/*.cpp src/*.hpp
	doxygen Doxyfile

clean:
	-rm $(EXECUTABLES)
	-rm obj/*
	-rm doc/html/index.html

.PHONY: all clean test docs

############
# Automatic dependency generation
############

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
