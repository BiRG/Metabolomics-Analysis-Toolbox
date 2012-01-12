#include <iostream>
#include <fstream>
#include <memory>
#include <utility>
#include <GClasses/GApp.h>
#include <GClasses/GError.h>
#include <GClasses/GMatrix.h>

#include <boost/archive/text_iarchive.hpp>
#include <boost/archive/text_oarchive.hpp>
#include <boost/serialization/vector.hpp>

#include "common.hpp"

using namespace GClasses;
using std::cerr;
using std::cout;
using std::endl;

///\brief Print usage and an optional message before throwing an
///"expected_exception"
void printUsageAndExit(std::ostream& out, const char*executableName, std::string msg=""){
  out 
    << "Usage: " << executableName << "discretization_file table_file\n"
    << "\n"
    << "Reads in discretization_file (which defines the discretizations of\n"
    << "the amplitudes and writes tables of counts of event occurrences to\n"
    << "table_file.\n"
    << "\n"
    << "table_file will be generated from random samples from the prior\n"
    << "distribution of peaks.  Letting p(l(i)=true) be the probability that\n"
    << "sample i is the nearest sample to a peak and p(a(i)=k) be the\n"
    << "probability that the noise-free amplitude at sample i is discretized\n"
    << "as k.  We collect counts for the events: \n"
    << "\n"
    << "1. a(i)=k and a(i+1)=j\n"
    << "2. a(i)=k and l(i)=j\n"
    << "3. l(i)=j and l(i+1)=k\n"
    << "\n"
    << "If table_file already exists, it will be read in and counts will\n"
    << "be added to it.  If it does not exist, it will be created.\n"
    << "\n"
    << "table_file will be written out every 15 minutes so that little\n"
    << "work will be lost by killing the create_table process.\n"

    << "\n"
    << msg << "\n";
    ;
  throw expected_exception(-1);
}

///\brief create_table (see usage message in printUsageAndExit)
void create_table(GArgReader& args){
  std::string s("");//Empty string to make easy to do string formatting
  const char* exe = args.pop_string();
  if(args.size() !=  2){
    printUsageAndExit(cerr, exe, "Error: Wrong number of arguments.  Expected "
		      "2 arguments.");
  }

  const char* disc_file = args.pop_string();
  const char* table_file= args.pop_string();

  std::vector<UniformDiscretization> discretizations;

  {
    std::ifstream disc_stream(disc_file);
    if(!disc_stream){
      printUsageAndExit(cerr, exe, s+"Error: could not open discretization "
			"file \""+disc_file+"\" for reading");
    }
    boost::archive::text_iarchive in(disc_stream);
    in & discretizations;
  }

  //TODO: declare table variable here

  {
    std::ifstream table_stream(table_file);
    if(!table_stream){
      //TODO: stub      
    }
  }

  //TODO: stub
  //Check whether the table and the discretization are compatible
  //Check that the table is what we are expecting to write (right
  //field names, number of variables etc)

  while(true){
    //TODO: stub
    //If the time limit has expired, write the current counts to the table
    //Generate another sample
    //Add the sample to the table
  }
  

}


///\brief start the create_table routine and handle uncaught exceptions
int main(int argc, char *argv[]){
  GApp::enableFloatingPointExceptions();
  
  int nRet = 0;
  try {
    GArgReader args(argc, argv);
    create_table(args);
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

