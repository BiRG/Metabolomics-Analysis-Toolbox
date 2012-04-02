#include <iostream>
#include <utility>
#include <GClasses/GApp.h>
#include <GClasses/GError.h>
#include <GClasses/GMatrix.h>
#include <GClasses/GRand.h>

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
    << "Usage: " << executableName << " num_divisions num_initial_samples seed\n"
    << "\n"
    << "Create a discretization discretizing each amplitude into \n"
    << "num_divisions bins using num_initial_samples samples from the prior\n"
    << "distribution to decide on discretization characteristics.  You \n"
    << "must divide each attribute into at least two bins.\n"
    << "\n"
    << "seed is the seed to initialize the random number generator\n"
    << "\n"
    << "The resulting discretizations will be written to stdout\n"

    << "\n"    
    << msg << "\n";
    ;
  throw expected_exception(-1);
}


void print_discretization(GClasses::GArgReader& args){
  const char* exe = args.pop_string();
  if(args.size() !=  3){
    printUsageAndExit(cerr, exe, "Error: Wrong number of arguments.  Expected "
		      "3 arguments.");
  }

  const unsigned num_div = args.pop_uint(); //# bins for each amplitude
  if(num_div < 2){
    using GClasses::to_str; std::string s("");
    printUsageAndExit(cerr, exe, s+"Error: "+to_str(num_div)+" bins requested "
		      "per amplitude. Each amplitude must be divided into "
		      "at least 2 bins.");
  }


  const unsigned num_samp = args.pop_uint(); //# samples from the prior
  if(num_samp == 0){
    printUsageAndExit(cerr, exe, "Error: 0 samples requested from the prior.  "
		      "You must sample at least once.");
  }

  const unsigned seed = args.pop_uint();
  GClasses::GRandMersenneTwister rng(seed);;

  const unsigned num_amp = Prior::freq_int_num_samp;
  const double inf = std::numeric_limits<double>::infinity();

  //Create the samples and record their extrema
  std::vector<double> mins(num_amp, inf);
  std::vector<double> maxes(num_amp, -inf);
  for(unsigned samp_num = 0; samp_num < num_samp; ++samp_num){
    std::vector<AmpAndIsPeak> samp = ampsAndLocsFrom(peaksFromPrior(rng));
    for(unsigned i=0; i < samp.size(); ++i){
      if(i > samp.size() || i > mins.size() || i > maxes.size()){
	std::cerr << "foo\n";
      }
      double a = samp.at(i).amp;
      if(a < mins.at(i)){
	mins[i] = a;
      }
      if(a > maxes.at(i)){
	maxes[i] = a;
      }
    }
  }

  //Use the extrema to create the discretizations
  std::vector<UniformDiscretization> discretizations;
  discretizations.reserve(num_amp);
  for(unsigned i = 0; i < num_amp; ++i){
    discretizations.push_back(UniformDiscretization(mins[i],maxes[i], num_div));
  }

  //Write to stdout
  boost::archive::text_oarchive out(std::cout);
  out & discretizations;
}

int main(int argc, char *argv[]){
  GApp::enableFloatingPointExceptions();
  
  int nRet = 0;
  try {
    GArgReader args(argc, argv);
    print_discretization(args);
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

