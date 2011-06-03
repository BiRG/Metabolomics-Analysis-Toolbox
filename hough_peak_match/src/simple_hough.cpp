///\file
///\brief Main routine and supporting code for the simple_hough executable

#include "peak_matching_database.hpp"
#include <boost/program_options.hpp>
#include <iostream>
#include <cstdlib> //For exit
#include <algorithm>
#include <cmath>

namespace HoughPeakMatch{
  class SimpleAccumulator{
  public:
    ///\brief Return an estimate of the size in gibibytes that would
    ///be required for a Simple accumulator with the given parameters
    ///
    ///\param location_res the number of cells to use for the ppm
    ///location dimension
    ///
    ///\param base_res the number of cells to use for the most
    ///important parameter.  If the most important parameter explains
    ///x% of the variance and another parameter explains y% of the
    ///variance then the other parameter will be allocated ceil(\a
    ///base_res * y/x) cells.
    ///
    ///\param ps a ParamStats object giving the fractional variances
    ///explained for the different parameters
    ///
    ///\return An estimate of the size in gibibytes that would be
    ///required for a Simple accumulator with the given parameters
    static double size_estimate(std::size_t location_res,
			 std::size_t base_res,
			 ParamStats ps);
  };

  double SimpleAccumulator::size_estimate(std::size_t location_res,
					  std::size_t base_res,
					  ParamStats ps){
    using std::vector; using std::size_t;
    vector<double> fvars = ps.frac_variances();
    if(fvars.size() == 0){
      return location_res*sizeof(double);
    }
    double max = 
      *(max_element(fvars.begin(), fvars.end()));
    double non_loc_size = 1;
    if(max > 0){
      for(vector<double>::const_iterator cur = fvars.begin(); 
	  cur != fvars.end(); ++cur){
	double cur_res = std::ceil(base_res * (*cur/max));
	non_loc_size *= cur_res;
      }
    }
    return location_res*non_loc_size*sizeof(double)/(1024*1024*1024);
  }
}

///\brief Print error message and usage information before exiting with an error
///
///Prints the usage message for hough_sample_params and then prints errMsg
///(followed by a newline) before finally exiting with a -1 error
///code.  Does not return.
///
///\param error_message the error message to print after the usage message
///
///\param od the options description that generates the majority of
///the usage message
void print_usage_and_exit(std::string error_message, 
			  boost::program_options::options_description od){
    std::cerr 
      << "Usage: simple_hough centralLocationResolution baseResolution \n"
      << "       standardDeviation max_GiB_RAM < initial_db >\n"
      << "       db_with_detected_peaks\n";
    std::cerr 
      << od << "\n"
      << "\n"
      << error_message << "\n";
    exit(-1);
}

///\brief The main routine for simple_hough
///
///\param argc The number of elements in the argv vector
///
///\param argv The command line arguments to this program - an array of strings
///
///\return error status to the operating system
int main(int argc, char**argv){
  namespace po = boost::program_options;
  using namespace HoughPeakMatch;
  using std::size_t; using po::value;
  //Parse command line options
  size_t central_location_resolution;
  size_t base_resolution;
  double standard_deviation;
  double max_gb_ram;

  po::options_description opt_desc("Options");
  opt_desc.add_options()
    ("help,?", "produce help message")
    ("central_location_resolution",value<size_t>(&central_location_resolution),
     "The number of steps to use in defining the central location of the peaks")
    ("base_resolution",value<size_t>(&base_resolution),
     "The number of steps to use for the first principal component. "
     "If another principal component explains 25% of the variance of "
     "the first it will be given 25% of the steps")
    ("standard_deviation",value<double>(&standard_deviation),
     "The standard deviation of the Gaussian used in \"fuzzifying\" the "
     "Hough transform")
    ("max_gb_ram", value<double>(&max_gb_ram), "gives the maximum number "
     "of GiB of RAM to use. The program will either use partitioning methods "
     "to try and meet this constraint or exit with an error. The program "
     "calculates only an estimate, so this is more of a suggestion than a "
     "hard rule.")
    ;

  const unsigned num_pos_opt = 4;
  const char* pos_opt_strs[num_pos_opt]=
    {"central_location_resolution", "base_resolution", "standard_deviation", 
     "max_gb_ram"};

  po::positional_options_description pos_opt;
  for(const char** opt = pos_opt_strs; opt != pos_opt_strs+num_pos_opt; ++opt){
    pos_opt.add(*opt,1);
  }
  po::variables_map opts;
  po::store
    (po::command_line_parser(argc,argv).options(opt_desc)
     .positional(pos_opt).run(), opts);
  po::notify(opts);
  

  if(opts.count("help") > 0){
    print_usage_and_exit("",opt_desc);
  }

  unsigned num_positional_options = 0;
  for(const char** opt = pos_opt_strs; opt != pos_opt_strs+num_pos_opt; ++opt){
    num_positional_options+= (opts.count(*opt) > 0) ? 1 : 0;
  }
  if(num_positional_options != 4){
    print_usage_and_exit("ERROR: did not specify all command line arguments",
			 opt_desc);
  }

  PeakMatchingDatabase db;
  if(!db.read(std::cin)){
    print_usage_and_exit("ERROR: could not read database from standard input",
			 opt_desc);
  }

  if(db.param_stats().size() != 1){
    print_usage_and_exit("ERROR: the input database must have a "
			 "param_stats object",
			 opt_desc);
  }

  double estimated_size = SimpleAccumulator::size_estimate
    (central_location_resolution, base_resolution, db.param_stats().at(0));

  if(estimated_size > max_gb_ram){
    std::ostringstream msg;
    msg << "ERROR: the required resolution would require " << estimated_size
	<< "GiB of RAM and only " << max_gb_ram << " is permitted.";
    print_usage_and_exit(msg.str(), opt_desc);
  }

  ///\todo stub
  std::cout << "These parameters would require " << estimated_size
	    << " GiB of RAM.\n";

  return 0;
}
