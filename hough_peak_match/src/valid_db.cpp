#include "peak_matching_database.h"
#include <iostream>
#include <fstream>
#include <cstdlib> //For exit
#include <string>

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
  return 0;
}
