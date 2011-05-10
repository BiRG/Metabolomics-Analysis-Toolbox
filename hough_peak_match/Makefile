CC:=g++
CXX:=g++
VPATH:=src:obj:src/tests
CXXFLAGS:=-Wall -Wextra -Weffc++ -pedantic -g -O0 -fprofile-arcs -ftest-coverage -fno-default-inline
EXECUTABLES:=assign_peaks hough_sample_params equivalent_db simple_hough \
	valid_db\
	tests/006-split_function.compiled.t\
	tests/007-from_text_line_funcs.compiled.t
LIBRARYOBJS:=obj/peak_matching_database.o obj/utils.o \
	obj/parameterized_peak_group.o \
	obj/detected_peak_group.o \
	obj/unverified_peak.o \
	obj/unknown_peak.o \
	obj/human_verified_peak.o\
	obj/sample_params.o\
	obj/param_stats.o\
	obj/known_peak.o\
	obj/sample.o\
	obj/peak.o 
LDLIBS:=-ltap++
LDFLAGS:=-fprofile-arcs
all: $(EXECUTABLES)

#############
# Executables
#############

#Note: this rule requires gnu ar to work correctly 
libbirgpeakmatch.a: $(LIBRARYOBJS)
	ar rsc libbirgpeakmatch.a $?

assign_peaks: obj/assign_peaks.o libbirgpeakmatch.a

hough_sample_params: obj/hough_sample_params.o libbirgpeakmatch.a

equivalent_db: obj/equivalent_db.o libbirgpeakmatch.a

simple_hough: obj/simple_hough.o libbirgpeakmatch.a

valid_db: obj/valid_db.o libbirgpeakmatch.a

tests/006-split_function.compiled.t: obj/tests/006-split_function.compiled.t.o libbirgpeakmatch.a

tests/007-from_text_line_funcs.compiled.t: obj/tests/007-from_text_line_funcs.compiled.t.o libbirgpeakmatch.a


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
	-rm obj/* obj/tests/* *.a
	-rm *.gcov
	-rm doc/html/index.html

.PHONY: all clean test testverbose docs

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

-include obj/*.deps obj/tests/*.deps

