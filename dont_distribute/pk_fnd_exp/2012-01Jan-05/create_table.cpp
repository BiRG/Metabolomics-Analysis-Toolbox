#include <iostream>
#include <fstream>
#include <memory>
#include <utility>
#include <ctime>
#include <GClasses/GApp.h>
#include <GClasses/GError.h>
#include <GClasses/GMatrix.h>
#include <GClasses/GRand.h>

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
    << "Usage: " << executableName << " seed discretization_file table_file\n"
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
    << "seed gives the seed used to initialize the random number generator.\n"
    << "\n"
    << "To stop the run, make the file stop_running readable in the current\n"
    << "directory.\n"


    << "\n"
    << msg << "\n";
    ;
  throw expected_exception(-1);
}

///\brief create_table (see usage message in printUsageAndExit)
void create_table(GArgReader& args){
  std::string s("");//Empty string to make easy to do string formatting
  const char* exe = args.pop_string();
  if(args.size() !=  3){
    printUsageAndExit(cerr, exe, "Error: Wrong number of arguments.  Expected "
		      "3 arguments.");
  }

  const unsigned seed = args.pop_uint();
  GClasses::GRandMersenneTwister rng(seed);;

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
    in >> discretizations;
  }

  //Abbreviation for number of samples
  const std::size_t ns = Prior::freq_int_num_samp;

  //Check that discretization loaded is compatible with the expected
  //number of samples
  if(discretizations.size() != ns){
    printUsageAndExit(cerr, exe, s+"Error: discretization in file "
		      "file \""+disc_file+"\" had a different number of "
		      "samples than expected.");
  }

  //amp_pairs[i] has counts the occurrences of a(i) and a(i+1)
  std::vector<CountTable2DSparse> amp_pairs;
  //l_pairs[i] has counts of the occurrences of l(i) and l(i+1)
  std::vector<CountTable2DDense> l_pairs;
  //l_amp[i] has counts of the occurrences of l(i) and amp(i)
  std::vector<CountTable2DDense> l_amp;

  //Initialize the count tables -- either from table_file (if it can
  //be read) or empty
  {
    std::ifstream table_stream(table_file);
    if(table_stream){
      boost::archive::text_iarchive in(table_stream);
      in >> amp_pairs >> l_pairs >> l_amp;
    }else{
      amp_pairs.reserve(ns-1);
      l_pairs.reserve(ns-1);
      l_amp.reserve(ns);
      for(std::size_t samp = 0; samp < ns; ++samp){
	CountTableVariable a0("a",samp,discretizations.at(samp).num_bins());
	CountTableVariable l0("l",samp,2);
	if(samp+1 < ns){
	  CountTableVariable a1
	    ("a",samp+1,discretizations.at(samp+1).num_bins());
	  CountTableVariable l1("l",samp+1,2);
	  amp_pairs.push_back(CountTable2DSparse(a0,a1));
	  l_pairs.push_back(CountTable2DDense(l0,l1));
	}
	l_amp.push_back(CountTable2DDense(l0,a0));
      }
    }
  }

  //Check whether the table and the discretization are compatible
  //(really only necessary when loading from the file, but it doesn't
  //take much time and it gives a check that my other table-initialization
  //code is correct
  bool compatible = true;
  for(std::size_t samp = 0; samp < ns; ++samp){
    if(samp+1 < ns){
      compatible &= amp_pairs.at(samp).variables().at(0).num_vals() == 
	discretizations.at(samp).num_bins();
      compatible &= amp_pairs.at(samp).variables().at(1).num_vals() == 
	discretizations.at(samp+1).num_bins();
    }
    compatible &= l_amp.at(samp).variables().at(1).num_vals() == 
      discretizations.at(samp).num_bins();
  }

  if(!compatible){
    ThrowError("Error: The loaded discretization and the structure of the "
	       "tables differs.");
  }

  //last_time is the last time the data was written to a file
  //Assuming time_t is an integral number of seconds (probably safe
  //and this is research code anyway)
  time_t last_time = std::time(0);
  time_t last_stop_check = std::time(0);
  const unsigned fifteen_minutes = 1;//60*15;  //For testing, write much more often
  while(true){
    //If the time limit has expired, write the current counts to the
    //file
    time_t cur_time = std::time(0);
    if(last_time + fifteen_minutes >= cur_time){
      last_time = cur_time;
      std::ofstream table_stream(table_file);
      if(table_stream){
	boost::archive::text_oarchive out(table_stream);
        out << amp_pairs << l_pairs << l_amp;
      }else{
	std::cerr << "Error: could not write to " << table_file 
		  << " continuing.";
      }
    }
    
    
    if(cur_time != last_stop_check){
      last_stop_check = cur_time;
      std::ifstream stop_file("stop_running");
      if(stop_file){ return; }
    }

    //Generate another sample
    std::vector<AmpAndIsPeak> samp = ampsAndLocsFrom(peaksFromPrior(rng));

    //Discretize the amplitudes and location variables
    std::vector<unsigned> amps(samp.size());
    std::vector<unsigned> locs(samp.size());
    for(unsigned i = 0; i < samp.size(); ++i){
      amps[i]=discretizations[i].bin_for(samp[i].amp);
      locs[i]=samp[i].is_peak ? 1:0;
    }
    

    //Add the sample to the tables
    for(unsigned i = 0; i < ns; ++i){
      if(i+1 < ns){
	amp_pairs[i].inc(amps[i],amps[i+1]);
	l_pairs[i].inc(locs[i],locs[i+1]);
      }
      l_amp[i].inc(locs[i], amps[i]);
    }
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

