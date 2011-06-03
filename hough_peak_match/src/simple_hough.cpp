///\file
///\brief Main routine and supporting code for the simple_hough executable

#include <boost/program_options.hpp>
#include <iostream>
#include <cstdlib> //For exit
namespace po = boost::program_options;

///\brief The main routine for simple_hough
///
///\param argc The number of elements in the argv vector
///
///\param argv The command line arguments to this program - an array of strings
///
///\return error status to the operating system
int main(int argc, char**argv){
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
  
  unsigned num_positional_options = 0;
  for(const char** opt = pos_opt_strs; opt != pos_opt_strs+num_pos_opt; ++opt){
    num_positional_options+= (opts.count(*opt) > 0) ? 1 : 0;
  }
  if(opts.count("help") > 0 || num_positional_options != 4){
    std::cerr << 
      "Usage: simple_hough centralLocationResolution baseResolution standardDeviation max_GiB_RAM < initial_db > db_with_detected_peaks";
    std::cerr << opt_desc << std::endl;
    exit(-1);
  }

  ///\todo main is stub
  std::cout << "# There were " << argc << " arguments:\n";
  for(int i = 0; i < argc; ++i){
    std::cout << "# "<< argv[i] << "\n";
  }
  return 0;
}
