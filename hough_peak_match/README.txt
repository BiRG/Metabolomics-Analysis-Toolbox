****************
* DEPENDENCIES * 
****************

To compile this, you need to install the following libraries (I've
given the ubuntu package names)

*********
* Intrinsic dependencies
*********

libgsl0-dev

( gnu scientific library - what I use for PCA )

The next two are not package names (but you already have them
installed, don't you?)

gmake

( gnu make - if you can't use this and gcc, you'll have to figure out
  how to build things yourself )

g++

( gnu C++ compiler - you'll have to modify the Makefile to compile on
  a system without gcc )

*********
* Dependencies for source-level documentation
*********

doxygen

( the doxygen documentation generator )

*********
* Dependencies for tests
*********

libboost-dev

( boost libraries: the best C++ libraries out there - what should have
  been in the standard )

libperl--        

( https://github.com/Leont/libperl-- - library which has libtap++,
  which allows easy generation of unit test output in c++)

perl 5.10.0 

( earlier versions will probably work just fine, but this is what I've
  tested )

libtest-simple-perl 

( perl module Test::Simple )

libtest-harness-perl 

( perl module TAP::Harness )


***************
* COMPILATION * 
***************

change to the directory with the source files

type "make"
type "make test" (to run the unit tests)


****************
* CODING STYLE *
****************

I can't keep to these 100% successfully myself, but I will make my best
effort, assisted by whatever CASE tools I can find.  Anyone else
writing the code should do the same.

1. All files, functions, members, namespaces, classes and anything
else that can be documented will have Doxygen documentation, with the
following exception: functions written exclusively for testing do not
need to have documentation.

2. Function documentation will document at least the parameters and
return values

3. All documented items will have a brief documentation line

4. All code will have test cases that exercise it - at least to the
branch level.

5. If possible, the test cases should be written before the code.

6. Test cases will use the Test Anything Protocol and integrated into
the test suite in tests/

7. Classes and namespaces will be named using cammel case starting
with an upper-case letter.  (ThisIsACammelCaseIdentifier)

8. Macros and enums will be named in all upper-case.  (ALL_UPPER_CASE)

9. Functions, member variables, and local variables will be named
using all lower-case separated by underscores.

10. Functions and control structures should be indented using the "One
True Brace Style" (see wikipedia article on "Indent style").  That is,
opening braces should be on the same line with the statement governing
them and closing braces should be indented to the same level as that
statement.

11. C++ headers should be *.hpp and source *.cpp.  Templates should be
defined in the file in which they are declared.

12. Lines should usually be 80 characters or less.

13. No tabs

14. Base-indent: 2 spaces.

15. Headers must have an include guard

16. System headers must be included after all local headers if
possible.  (This helps ensure that local headers are including
everything they need to.)

17. Include statements must be made at the top of the file.



