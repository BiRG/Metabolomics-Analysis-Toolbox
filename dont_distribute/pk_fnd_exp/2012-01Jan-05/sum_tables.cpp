#include <iostream>
#include <GClasses/GApp.h>
#include <GClasses/GError.h>
#include <GClasses/GMatrix.h>

#include <boost/archive/text_oarchive.hpp>

#include "common.hpp"

using namespace GClasses;
using std::cerr;
using std::cout;
using std::endl;

///\brief Print usage and an optional message before throwing an
///"expected_exception"
void printUsageAndExit(std::ostream& out, const char*executableName, std::string msg=""){
  out 
    << "Usage: " << executableName << " table_file1 table_file2 > output\n"
    << "\n"
    << "Reads in two files of probability tables for the first experiment\n"
    << "and sums the counts in both, producing a new table that is written to\n"
    << "stdout.\n"

    << "\n"
    << msg << "\n";
    ;
  throw expected_exception(-1);
}

///\brief sum_tables (see usage message in printUsageAndExit)
void sum_tables(GArgReader& args){
  std::string s("");//Empty string to make easy to do string formatting
  const char* exe = args.pop_string();
  if(args.size() !=  2){
    printUsageAndExit(cerr, exe, "Error: Wrong number of arguments.  Expected "
		      "2 arguments.");
  }

  const char* table1_file = args.pop_string();
  const char* table2_file= args.pop_string();

  //Initialize the count tables from table_file - throws exception if
  //the tables cannot be read
  CountTablesForFirstExperiment tab1(table1_file);
  CountTablesForFirstExperiment tab2(table2_file);

  //Add the counts and write to stdout
  tab1.add(tab2);

  boost::archive::text_oarchive out(std::cout);
  out << tab1;
}


///\brief start the sum_tables routine and handle uncaught exceptions
int main(int argc, char *argv[]){
  GApp::enableFloatingPointExceptions();
  
  int nRet = 0;
  try {
    GArgReader args(argc, argv);
    sum_tables(args);
  } catch(const GException& e){
    cerr << "Error: " << e.what() << std::endl;
  } catch(const expected_exception& e){
    nRet = e.exit_status;
  } catch(const std::exception& e) {
    cerr << "Unhandled exception caught: " << e.what() << "\n";
    nRet = 1;
  }
  
  return nRet;
}

