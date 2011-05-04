///\file
///\brief Main routine and supporting code for the valid_db executable
#include "peak_matching_database.hpp"
#include <iostream>
#include <fstream>
#include <cstdlib> //For exit
#include <string>


///Print error message and usage information before exiting with an error

///Prints the usage message for valid_db and then prints errMsg
///(followed by a newline) before finally exiting with a -1 error
///code.  Does not return.
///
///\param errMsg the error message to print after the usage message
void printUsageAndExit(std::string errMsg){
  std::cerr 
    << "Synopsis: valid_db db_file\n"
    << "\n"
    << "Checks whether the given file parses as a valid peak-matching\n"
    << "database or not.\n"
    << "\n"
    << "Prints \"Valid\" or \"Invalid\" to stdout depending on whether the\n"
    << "database is valid or not.\n"
    << "\n"
    << errMsg << "\n";
  std::exit(-1);
}


///The main routine for valid_db

///\param argc The number of elements in the argv vector
///
///\param argv The command line arguments to this program - an array of strings
///
///\return error status to the operating system
int main(int argc, char**argv){
  if(argc != 2){
    printUsageAndExit("ERROR: Wrong number of arguments");
  }

  char const * const db_file_name = argv[1];
  std::ifstream db_stream(db_file_name);
  if(!db_stream){
    printUsageAndExit(std::string("ERROR: Could not open \"")+
		      db_file_name+"\"");
  }

  HoughPeakMatch::PeakMatchingDatabase db;
  bool success = db.read(db_stream);
  if(success){
    std::cout << "Valid\n";
  }else{
    std::cout << "Invalid\n";
  }
  return 0;
}
