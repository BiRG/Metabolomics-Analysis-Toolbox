CC:=g++
CXX:=g++
VPATH:=src:obj:src/tests
CXXFLAGS:=-Wall -Wextra -Weffc++ -pedantic -g $(GCOV_OPTS) $(PREDEFINE)
EXECUTABLES:=assign_peaks hough_sample_params equivalent_db simple_hough \
	valid_db\
	tests/006-split_function.compiled.t\
	tests/007-from_text_line_funcs.compiled.t\
	tests/008-mockable_stringstream.compiled.t\
	tests/010-to_text_line_and_constructors.compiled.t\
	tests/011-pmobject_method_overloads.compiled.t\
	stringstream_sandbox
LIBRARYOBJS:=obj/peak_matching_database.o obj/utils.o \
	obj/parameterized_peak_group.o \
	obj/detected_peak_group.o \
	obj/unverified_peak.o \
	obj/unknown_peak.o \
	obj/human_verified_peak.o\
	obj/file_format_sample_params.o\
	obj/param_stats.o\
	obj/known_peak.o\
	obj/file_format_sample.o\
	obj/sample.o\
	obj/unparameterized_sample.o\
	obj/parameterized_sample.o\
	obj/peak.o \
	obj/mockable_stringstream.o\
	obj/peak_key.o\
	obj/peak_group_key.o\
	obj/sample_key.o
LDLIBS:=-ltap++
LDFLAGS:=$(GCOV_LDOPTS)

all: mock_executables

executables: $(EXECUTABLES)


mock_executables: 
	@if [ -e normal_executables ]; then $(MAKE) --no-print-directory clean; fi
	@$(MAKE) --no-print-directory PREDEFINE=-DUSE_MOCK_ISTRINGSTREAM GCOV_OPTS="$(GCOV_OPTS)" GCOV_LDOPTS="$(GCOV_LDOPTS)" executables
	touch mock_executables

normal_executables: 
	@if [ -e mock_executables ]; then $(MAKE) --no-print-directory clean; fi
	@$(MAKE) --no-print-directory executables
	touch normal_executables

gcov: GCOV_OPTS:=-fprofile-arcs -ftest-coverage 
gcov: GCOV_LDOPTS:=-fprofile-arcs
gcov: mock_executables


#To do the lcov analysis: 1) make clean 2) make gcov 3) make test 4) make lcov

lcov:
	rm -rf lcov_output
	mkdir -p lcov_output
	lcov --directory obj --capture --output-file lcov_output/lcov.info -b .
	genhtml -o lcov_output lcov_output/lcov.info

.PHONY: lcov

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

tests/008-mockable_stringstream.compiled.t: obj/tests/008-mockable_stringstream.compiled.t.o libbirgpeakmatch.a

tests/010-to_text_line_and_constructors.compiled.t: obj/tests/010-to_text_line_and_constructors.compiled.t.o libbirgpeakmatch.a

tests/011-pmobject_method_overloads.compiled.t: obj/tests/011-pmobject_method_overloads.compiled.t.o libbirgpeakmatch.a

stringstream_sandbox: obj/stringstream_sandbox.o libbirgpeakmatch.a

#############
# Utility targets
#############

test: mock_executables
	cd tests; ./runalltests.pl

testverbose: mock_executables
	cd tests; ./runalltests.pl verbose


docs: doc/html/index.html

doc/html/index.html: src/*.cpp src/*.hpp src/tests/*.[ch]pp
	doxygen Doxyfile

zerocounts:
	-rm obj/*.gcda tests/*.gcda
.PHONY: zerocounts

clean:
	-rm $(EXECUTABLES) obj/* obj/tests/* *.a *.gcov 
	-rm doc/html/index.html normal_executables mock_executables
	-rm -rf lcov_output

.PHONY: all clean test testverbose docs executables normal_executables mock_executables

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

