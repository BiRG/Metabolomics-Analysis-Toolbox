///\file
///\brief Main routine and supporting code for the equivalent_db executable

#include "peak_matching_database.hpp"
#include <iostream>
#include <fstream>
#include <cstdlib> //For exit

///Print error message and usage information before exiting with an error

///Prints the usage message for equivalent_db and then prints errMsg
///(followed by a newline) before finally exiting with a -1 error
///code.  Does not return.
///
///\param errMsg the error message to print after the usage message
void printUsageAndExit(std::string errMsg){
  std::cerr 
    << "Synopsis: equivalent_db database_1 database_2\n"
    << "\n"
    << "Reads the two given peak database files and reports whether \n"
    << "they describe equivalent databases, that is, databases that \n"
    << "describe the same real-world information but with file-level \n"
    << "differences like changes in line ordering or in object id numbers.\n"
    << "\n"
    << "Writes to standard output, prints:\n"
    << "    \"Databases ARE equivalent\" if the databases are equivalent,\n"
    << "    \"Databases ARE NOT equivalent\" if the databases are not \n"
    << "                                     equivalent\n"
    << "\n"
    << errMsg << "\n";
  std::exit(-1);
}

///\brief Returns the given database or aborts with an appropriate message
///
///Either returns the result of successfully reading and opening the
///given database file or executes printUsageAndExit with an
///appropriate error message.  On an error, does not return.
///
///\param file_name the name of the file to read the database from
///
///\param which_db A user-level identifier for the database that would
///fit in the blank in this sentence: <code> ERROR: Could not open
///____ database "db_filename.db" </code>
///
///\return (if it returns) the contents of the specified database file
HoughPeakMatch::PeakMatchingDatabase read_database(std::string file_name, 
						   std::string which_db){
  std::ifstream db_stream(file_name.c_str());
  if(!db_stream){
    std::string msg = 
      "ERROR: Could not open "+ which_db + " database \"" + file_name + "\"";
    printUsageAndExit(msg);
  }

  HoughPeakMatch::PeakMatchingDatabase db;
  bool success = db.read(db_stream);
  if(!success){
    std::string msg = 
      "ERROR: " + which_db + " database \"" + file_name + "\" is invalid";
    printUsageAndExit(msg);
  }

  return db;
}


///\brief The main routine for equivalent_db
///
///\param argc The number of elements in the argv vector
///
///\param argv The command line arguments to this program - an array of strings
///
///\return error status to the operating system
int main(int argc, char**argv){
  if(argc != 3){
    printUsageAndExit("ERROR: Wrong number of arguments");
  }

  HoughPeakMatch::PeakMatchingDatabase db1 = 
    read_database(argv[1],"the first");
  HoughPeakMatch::PeakMatchingDatabase db2 = 
    read_database(argv[2],"the second");

  ///\todo main is stub
  std::cout << "There were " << argc << " arguments:";
  for(int i = 1; i < argc; ++i){
    std::cout << argv[i] << "\n";
  }
  return 0;
}
