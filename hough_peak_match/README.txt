****************
* DEPENDENCIES * 
****************

To compile this, you need to install the following libraries (I've
given the ubuntu package names)

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

libgsl0-dev

( gnu scientific library - what I use for PCA )

rant

( the rant build system - the build scripts are ruby - maybe I'll make
  the dependency just ruby some day)

ruby 

( for rant - will be autoinstalled from apt-get )

g++

( gnu C++ compiler - you'll have to modify the rant file to compile on
  a system without gcc )

***************
* COMPILATION * 
***************

change to the directory with the source files

type "rant"


