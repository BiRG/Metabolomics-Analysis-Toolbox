///\file
///\brief Main routine and supporting code for the duplicate_peak_match_db executable
#include "peak_matching_database.hpp"
#include <sstream>
#include <iostream>
#include <cstdlib> //For exit

///\brief Print error message and usage information before exiting with an error
///
///Prints the usage message for duplicate_peak_match_db and then prints errMsg
///(followed by a newline) before finally exiting with a -1 error
///code.  Does not return.
///
///\param errMsg the error message to print after the usage message
void print_usage_and_exit(std::string errMsg){
  std::cerr 
    << "Synopsis: duplicate_peak_match_db < input > output\n"
    << "\n"
    << "Takes a peak-matching database from standard input, parses it \n"
    << "and writes an equivalent database to standard output. Used for \n"
    << "testing the reading/writing routines.\n"
    << "\n"
    << errMsg << "\n";
  std::exit(-1);
}


///\brief The main routine for duplicate_peak_match_db
///
///\param argc The number of elements in the argv vector
///
///\param argv The command line arguments to this program - an array of strings
///
///\return error status to the operating system
int main(int argc, char**){
  using std::string;
  if(argc != 1){
    print_usage_and_exit("ERROR: Wrong number of arguments.");
  }

  HoughPeakMatch::PeakMatchingDatabase db;
  if(!db.read(std::cin)){
    print_usage_and_exit("ERROR: could not read database from standard input");
  }

  return !db.write(std::cout);
}
