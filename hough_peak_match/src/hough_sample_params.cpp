///\file
///\brief Main routine and supporting code for the hough_sample_params executable
#include "remove_sample_params_from.hpp"
#include "peak_matching_database.hpp"
#include <sstream>
#include <iostream>
#include <cstdlib> //For exit

///\brief Print error message and usage information before exiting with an error
///
///Prints the usage message for hough_sample_params and then prints errMsg
///(followed by a newline) before finally exiting with a -1 error
///code.  Does not return.
///
///\param errMsg the error message to print after the usage message
void print_usage_and_exit(std::string errMsg){
  std::cerr 
    << "Synopsis: hough_sample_params [options] fractionVariance < initial_db > db_with_sample_params\n"
    << "\n"
    << "Reads a peak database from standard input. Extracts the set \n"
    << "of peak_groups that have a representative in every sample. \n"
    << "Creates a set of sample parameters that accounts for at least \n"
    << "fractionVariance [0..1] of the variance of the peaks in those \n"
    << "peak groups. Outputs a database with these new sample parameters \n"
    << "along with a param_stats object added.\n"
    << "\n"
    << "If there are already sample_params objects in the database, then \n"
    << "three things differ. First, the number of parameters is set to be \n"
    << "the same as the number of parameters in the existing objects. \n"
    << "Second, only samples not associated with an extant sample_params \n"
    << "object are given new sample_params objects. Third, the \n"
    << "param_stats object will be updated.\n"
    << "\n"
    << "Options:\n"
    << "  --remove-sample-params  removes all sample_params objects from the \n"
    << "                          input database before processing it.\n"
    << "\n"
    << errMsg << "\n";
  std::exit(-1);
}

///\brief The main routine for hough_sample_params
///
///\param argc The number of elements in the argv vector
///
///\param argv The command line arguments to this program - an array of strings
///
///\return error status to the operating system
int main(int argc, char**argv){
  using namespace HoughPeakMatch;
  using std::string;
  if(argc != 2 && argc != 3){
    print_usage_and_exit("ERROR: Wrong number of arguments.");
  }

  double fraction_variance = -1;
  std::istringstream frac_var_in(argv[argc-1]);
  frac_var_in >> fraction_variance;
  if(fraction_variance < 0 || fraction_variance > 1){
    print_usage_and_exit("ERROR: fraction of variance must be between "
			 "0 and 1, inclusive.  You wrote: "+ 
			 string(argv[argc-1]));
  }
  bool should_remove_sample_params_first=
    argc==3 && argv[argc-2]==string("--remove-sample-params");

  PeakMatchingDatabase db;
  if(!db.read(std::cin)){
    print_usage_and_exit("ERROR: could not read database from standard input");
  }

  if(should_remove_sample_params_first){
    remove_sample_params_from(db);
  }
  
  return 0;
}
