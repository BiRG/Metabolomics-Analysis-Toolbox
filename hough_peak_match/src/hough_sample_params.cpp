///\file
///\brief Main routine and supporting code for the hough_sample_params executable

#include <iostream>
#include <cstdlib> //For exit

///The main routine for hough_sample_params

///\param argc The number of elements in the argv vector
///
///\param argv The command line arguments to this program - an array of strings
///
///\return error status to the operating system
int main(int argc, char**argv){
  if(argc != 2 && argc != 3){
    ///\todo write print usage and exit
    exit(-1);
  }
  double fractionVariance = atof(argv[argc-1]);
  bool shouldRemoveSampleParamsFirst=argc==3;
  ///\todo main is stub
  std::cout << "fractionVariance="<<fractionVariance 
	    << "\nremoveSampleParams="<<shouldRemoveSampleParamsFirst<<"\n";
  return 0;
}
