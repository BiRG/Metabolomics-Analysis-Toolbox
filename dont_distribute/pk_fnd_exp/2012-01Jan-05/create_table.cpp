#include <iostream>
#include <utility>
#include <GClasses/GApp.h>
#include <GClasses/GError.h>
#include <GClasses/GMatrix.h>
#include "common.hpp"

using namespace GClasses;
using std::cerr;
using std::cout;
using std::endl;

///\brief Print usage and an optional message before throwing an
///"expected_exception"
void printUsageAndExit(std::ostream& out, const char*executableName, std::string msg=""){
  out 
    << "Usage: " << executableName << " this is a stub\n"
    << "\n"
    << "\n"
    << msg << "\n";
    ;
  throw expected_exception(-1);
}



int main(int argc, char *argv[]){
  GApp::enableFloatingPointExceptions();
  
  int nRet = 0;
  try {
    GArgReader args(argc, argv);
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

