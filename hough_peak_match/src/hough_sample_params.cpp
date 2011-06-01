///\file
///\brief Main routine and supporting code for the hough_sample_params executable
#include "remove_sample_params_from.hpp"
#include "peak_matching_database.hpp"
#include "peak_group_key.hpp"
#include "file_format_sample_params.hpp"
#include <sstream>
#include <iostream>
#include <cstdlib> //For exit
#include <utility>
#include <set>

///\brief Print error message and usage information before exiting with an error
///
///Prints the usage message for hough_sample_params and then prints errMsg
///(followed by a newline) before finally exiting with a -1 error
///code.  Does not return.
///
///\param errMsg the error message to print after the usage message
void print_usage_and_exit(std::string errMsg){
  std::cerr 
    << "Synopsis: hough_sample_params [options] fractionVariance < initial_db > db_with_sample_params\n"
    << "\n"
    << "Reads a peak database from standard input. Extracts the set \n"
    << "of peak_groups that have a representative in every sample. \n"
    << "Creates a set of sample parameters that accounts for at least \n"
    << "fractionVariance [0..1] of the variance of the peaks in those \n"
    << "peak groups. Outputs a database with these new sample parameters \n"
    << "along with a param_stats object added.\n"
    << "\n"
    << "If there are already sample_params objects in the database, then \n"
    << "three things differ. First, the number of parameters is set to be \n"
    << "the same as the number of parameters in the existing objects. \n"
    << "Second, only samples not associated with an extant sample_params \n"
    << "object are given new sample_params objects. Third, the \n"
    << "param_stats object will be updated.\n"
    << "\n"
    << "Options:\n"
    << "  --remove-sample-params  removes all sample_params objects from the \n"
    << "                          input database before processing it.\n"
    << "\n"
    << errMsg << "\n";
  std::exit(-1);
}

namespace HoughPeakMatch{

  ///\brief Return keys for those peak-groups that have a representative in
  ///every sample in \a db
  ///
  ///\param db The database whose peak-groups are to be returned
  ///
  ///\return keys for those peak-groups that have a representative in
  ///every sample in \a db
  std::set<PeakGroupKey> peak_groups_in_all_samples(const PeakMatchingDatabase& db){
    std::set<PeakGroupKey> ret;
    ///\todo stub
    return ret;
  }
  
  ///\brief Calculate the sample parameters for all samples in \a db
  ///using the peak_groups in \a pg_in_all_samples
  ///
  ///Uses PCA on a matrix whose variables are the peak positions of
  ///the peak in each peak-group in each sample to calculate a set of
  ///parameters affecting peak positions in each sample that account
  ///for at least \a frac_variance fraction of the peak_position variance.
  ///
  ///\param db The database for whose samples to calculate the parameters
  ///
  ///\param pg_in_all_samples the peak groups to use in calculating
  ///the parameters - each peak group is assumed to have exactly one
  ///peak in each sample.
  ///
  ///\param frac_variance The fraction of the peak-position variance
  ///that must be captured by the calculated parameters
  ///
  ///\return A pair consisting of the parameters inferred for each
  ///sample and the fractional variances of those parameters
  std::pair<std::set<FileFormatSampleParams>,ParamStats> 
  calculate_sample_parameters(const PeakMatchingDatabase& db, 
			      const std::set<PeakGroupKey>& pg_in_all_samples,
			      double frac_variance){
    ///\todo stub
    std::vector<double> d;
    return std::make_pair(std::set<FileFormatSampleParams>(),
			  ParamStats(d.begin(),d.end()));
  }
  
  ///\brief set the parameters for all samples in the database to
  ///those given in \a params and the param_stats to \a stats
  ///
  ///Assumes that the database has no parameterized sample objects and
  ///no sample_params objects
  ///
  ///\param db The database to modify - should have no parameterized
  ///samples
  ///
  ///\param params the sample_params objects to add to the existing samples
  ///
  ///\param stats the param_stats object to add to the database
  void add_params_to_db
  (PeakMatchingDatabase& db, 
   const std::set<FileFormatSampleParams>& params,
   const ParamStats stats){
    ///\todo stub  
  }
}

///\brief The main routine for hough_sample_params
///
///\param argc The number of elements in the argv vector
///
///\param argv The command line arguments to this program - an array of strings
///
///\return error status to the operating system
int main(int argc, char**argv){
  using namespace HoughPeakMatch;
  using std::string;
  if(argc != 2){
    print_usage_and_exit("ERROR: Wrong number of arguments.");
  }

  double fraction_variance = -1;
  std::istringstream frac_var_in(argv[argc-1]);
  frac_var_in >> fraction_variance;
  if(fraction_variance < 0 || fraction_variance > 1){
    print_usage_and_exit("ERROR: fraction of variance must be between "
			 "0 and 1, inclusive.  You wrote: "+ 
			 string(argv[argc-1]));
  }

  PeakMatchingDatabase db;
  if(!db.read(std::cin)){
    print_usage_and_exit("ERROR: could not read database from standard input");
  }

  //Remove all references to old parameters from the database,
  //preserving the rest of its structure.
  remove_sample_params_from(db);

  db.parameterized_peak_groups().clear();
  db.detected_peak_groups().clear();
  db.param_stats().clear();

  std::set<PeakGroupKey> pg_in_all_samples = peak_groups_in_all_samples(db);
  if(pg_in_all_samples.size() == 0){
    std::cerr << "WARNING: no known peak groups were in all samples -- "
      "thus no sample params have been generated.\n";
    return !db.write(std::cout);  
  }

  std::pair<std::set<FileFormatSampleParams>, ParamStats> params = 
    calculate_sample_parameters(db, pg_in_all_samples, fraction_variance);

  add_params_to_db(db, params.first, params.second);
  
  return !db.write(std::cout);
}
