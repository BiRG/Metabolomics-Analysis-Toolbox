///\file
///\brief Main routine and supporting code for the assign_peaks executable

#include <iostream>
#include <cstdlib> //For exit

///The main routine for assign_peaks

///\param argc The number of elements in the argv vector
///
///\param argv The command line arguments to this program - an array of strings
///
///\return error status to the operating system
int main(int argc, char**argv){
  if(argc != 4){
    ///\todo write print usage and exit
    exit(-1);
  }
  ///\todo main is stub
  std::cout << "# There were " << argc << " arguments:";
  for(int i = 1; i < argc; ++i){
    std::cout << "# " << argv[i] << "\n";
  }
  return 0;
}
