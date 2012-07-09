#include <iostream>
#include <GClasses/GApp.h>
#include <GClasses/GError.h>
#include <GClasses/GMatrix.h>

#include <boost/archive/text_oarchive.hpp>

#include "FactorGraph.hpp"
#include "common.hpp"

using namespace GClasses;
using std::cerr;
using std::cout;
using std::endl;

///\brief Print usage and an optional message before throwing an
///"expected_exception"
void printUsageAndExit(std::ostream& out, const char*executableName, std::string msg=""){
  out 
    << "Usage: " << executableName << " table_file in_spectrum out_spectrum out_distribution\n"
    << "\n"
    << "Reads in a table of counts from the prior distribution and a noisy\n"
    << "spectrum and outputs the most likely spectrum and the posterior\n"
    << "marginal distribution of amplitudes as a ppm\n"
    << "\n"

    << "\n"
    << msg << "\n";
    ;
  throw expected_exception(-1);
}

///\brief denoise (see usage message in printUsageAndExit)
void denoise(GArgReader& args){
  std::string s("");//Empty string to make easy to do string formatting
  const char* exe = args.pop_string();
  if(args.size() !=  4){
    printUsageAndExit(cerr, exe, "Error: Wrong number of arguments.  Expected "
		      "4 arguments.");
  }

  const char* table_filename = args.pop_string();
  const char* in_spectrum_filename = args.pop_string();
  const char* out_spectrum_filename = args.pop_string();
  const char* out_distribution_filename = args.pop_string();

  //Initialize the count tables from table_file - throws exception if
  //the tables cannot be read
  CountTablesForFirstExperiment tab(table_filename);


}


///\brief start the denoise routine and handle uncaught exceptions
int main(int argc, char *argv[]){
  GApp::enableFloatingPointExceptions();
  
  int nRet = 0;
  try {
    GArgReader args(argc, argv);
    denoise(args);
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

