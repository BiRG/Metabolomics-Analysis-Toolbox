///\file
///\brief Main routine and supporting code for the simple_hough executable

#include <iostream>
#include <cstdlib> //For exit

///The main routine for simple_hough

///\param argc The number of elements in the argv vector
///
///\param argv The command line arguments to this program - an array of strings
///
///\return error status to the operating system
int main(int argc, char**argv){
  if(argc != 5){
    ///\todo write print usage and exit
    exit(-1);
  }
  ///\todo main is stub
  std::cout << "There were " << argc << " arguments:";
  for(int i = 0; i < argc; ++i){
    std::cout << argv[i] << "\n";
  }
  return 0;
}
