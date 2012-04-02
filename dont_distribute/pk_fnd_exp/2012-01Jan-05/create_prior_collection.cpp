#include "common.hpp"
#include <iostream>
#include <utility>
#include <ctime>
#include <vector>
#include <GClasses/GApp.h>
#include <GClasses/GError.h>
#include <GClasses/GMatrix.h>
#include <GClasses/GRand.h>

using namespace GClasses;
using std::cerr;
using std::cout;
using std::endl;

///\brief Print usage and an optional message before throwing an
///"expected_exception"
void printUsageAndExit(std::ostream& out, const char*executableName, std::string msg=""){
  out 
    << "Usage: " << executableName << " num_samples seed\n"
    << "\n"
    << "Samples num_samples synthetic spectra from the prior distribution\n"
    << "used in the noise-reduction etc. test and prints them to stdout as\n"
    << "an xy.txt file.  The spectra in the collection alternate between\n"
    << "the sampled spectra and a special binary spectrum that is 1 if the\n"
    << "x location is the nearest to one of the peaks in the previous sampled\n"
    << "spectrum.  Thus there will be 2*num_samples spectra in the collection\n"
    << "\n"
    << "seed is an unsigned integer to be used as the starting point for the\n"
    << "random-number generator.\n"
    << "\n"
    << msg << "\n";
    ;
  throw expected_exception(-1);
}

void output_collection(GArgReader& args){
  const char* exe = args.pop_string();
  if(args.size() != 2){
    printUsageAndExit(cerr, exe, "Error: Wrong number of arguments.  Expected "
		      "2 arguments.");
  }

  const unsigned num_samp = args.pop_uint(); //# samples from the prior
  if(num_samp == 0){
    printUsageAndExit(cerr, exe, "Error: 0 samples requested from the prior.  "
		      "You must sample at least once.");
  }

  const unsigned seed = args.pop_uint();

  GClasses::GRandMersenneTwister rng(seed);;

  //Generate all the spectral data
  std::vector<std::vector<AmpAndIsPeak> > vals;
  vals.reserve(num_samp);
  for(unsigned i = 0; i < num_samp; ++i){
    PeakList pks = peaksFromPrior(rng);
    vals.push_back(ampsAndLocsFrom(pks));
  }

  //Main header
  std::time_t time;
  std::time(&time);
  std::cout 
    << "Collection ID\t-" << seed << "\n"
    << "Type\t SpectraCollection\n"
    << "Description\t Synthetic dataset generated from prior used for "
    << "prototype bayesian noise reduce and peak-finding with seed" 
    << seed << " on " << std::ctime(&time) //ctime string ends in \n
    << "Processing log\t\n";

  //Headers for spectral data columns
  std::cout << "X";
  for(unsigned samp=0; samp < num_samp; ++samp){
    std::cout << "\tY" << samp << "\tis_peak_" << samp;
  }
  std::cout << "\n";

  //Spectral data
  const unsigned n = Prior::freq_int_num_samp;
  for(unsigned row = 0; row < n; ++row){
    const double width = Prior::freq_int_max - Prior::freq_int_min;
    const double min = Prior::freq_int_min;
    const double x = row*(width/(n-1))+min;
    std::cout << x;
    for(unsigned samp=0; samp < num_samp; ++samp){
      std::cout << "\t" << vals.at(samp).at(row).amp 
		<< "\t" << (vals.at(samp).at(row).is_peak?1:0);
    }
    std::cout << "\n";
  }
 
  //Done
}

int main(int argc, char *argv[]){
  GApp::enableFloatingPointExceptions();
  
  int nRet = 0;
  try {
    GArgReader args(argc, argv);
    output_collection(args);
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

