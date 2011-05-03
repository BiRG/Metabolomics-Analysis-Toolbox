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


