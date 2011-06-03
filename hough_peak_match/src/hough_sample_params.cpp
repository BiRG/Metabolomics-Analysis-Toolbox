///\file
///\brief Main routine and supporting code for the hough_sample_params executable
#include "remove_sample_params_from.hpp"
#include "peak_matching_database.hpp"
#include "peak_group_key.hpp"
#include "gsl_vector.hpp"
#include "gsl_matrix.hpp"
#include <gsl/gsl_linalg.h>
#include <sstream>
#include <iostream>
#include <cstdlib> //For exit
#include <utility>
#include <set>
#include <map>


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
  ///Assumes that there are no detected peak groups, parameterized
  ///peak groups, or parameterized samples in the database.
  ///
  ///\param db The database whose peak-groups are to be returned
  ///
  ///\return keys for those peak-groups that have a representative in
  ///every sample in \a db
  std::set<PeakGroupKey> peak_groups_in_all_samples(const PeakMatchingDatabase& db){
    using std::set; using std::auto_ptr; using std::map; using std::vector;
    using std::pair;
    assert(db.detected_peak_groups().size() == 0);
    assert(db.parameterized_peak_groups().size() == 0);
    assert(db.parameterized_samples().size() == 0);

    set<unsigned> all_sample_ids;
    for(vector<UnparameterizedSample>::const_iterator s = 
	  db.unparameterized_samples().begin();
	s != db.unparameterized_samples().end(); ++s){
      all_sample_ids.insert(s->id());
    }
    unsigned num_sample_ids = all_sample_ids.size();
    
    //Contains ids of peak groups that have multiple peaks in one or
    //more samples
    set<unsigned> multiple_entries;
    //where_represented maps peak group ids to sample ids where that
    //peak group has a representative
    map<unsigned, set<unsigned> > where_represented;
    for(vector<HumanVerifiedPeak>::const_iterator pk = 
	  db.human_verified_peaks().begin();
	pk != db.human_verified_peaks().end(); ++pk){
      unsigned pgid = pk->peak_group_id();
      pair<set<unsigned>::iterator, bool> 
	result = where_represented[pgid].insert(pk->sample_id());
      if(!result.second){ multiple_entries.insert(pgid); }
    }
    for(vector<UnverifiedPeak>::const_iterator pk = 
	  db.unverified_peaks().begin();
	pk != db.unverified_peaks().end(); ++pk){
      unsigned pgid = pk->peak_group_id();
      pair<set<unsigned>::iterator, bool> 
	result = where_represented[pgid].insert(pk->sample_id());
      if(!result.second){ multiple_entries.insert(pgid); }
    }

    std::set<PeakGroupKey> ret;
    for(map<unsigned, set<unsigned> >::const_iterator pr =
	  where_represented.begin(); pr != where_represented.end(); ++pr){
      if(multiple_entries.count(pr->first) == 0 &&
	 pr->second.size() == num_sample_ids){
	ret.insert(PeakGroupKey(db, pr->first));
      }
    }
    return ret;
  }

  ///\brief subtract the mean of each row from each value in the row
  ///
  ///\param m The matrix whose rows will have the mean subtracted
  void mean_center_rows(GSL::Matrix& m){
    if(m.cols() < 1){  //Skip empty matrix
      return; }
    for(std::size_t row = 0; row < m.rows(); ++row){
      double sum = 0;
      for(std::size_t col = 0; col < m.cols(); ++col){
	sum += m.at(row,col);
      }
      double mean = sum / m.cols();
      for(std::size_t col = 0; col < m.cols(); ++col){
	m.at(row,col) -= mean;
      }
    }
  }
  
  ///\brief Calculate the sample parameters for all samples in \a db
  ///using the peak_groups in \a pg_in_all_samples
  ///
  ///Uses PCA on a matrix whose variables are the peak positions of
  ///the peak in each peak-group in each sample to calculate a set of
  ///parameters affecting peak positions in each sample that account
  ///for at least \a frac_variance fraction of the peak_position variance.
  ///
  ///Assumes db has no ParameterizedSample objects
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
  ///\param should_print_matrices if true, then some of the generated
  ///matrices, including peak-position are printed to std::cerr
  ///
  ///\return A pair consisting of the parameters inferred for each
  ///sample and the fractional variances of those parameters
  std::pair<std::vector<ParameterizedSample>,ParamStats>
  calculate_sample_parameters(const PeakMatchingDatabase& db, 
			      const std::set<PeakGroupKey>& pg_in_all_samples,
			      double frac_variance, 
			      bool should_print_matrices){    
    using std::map; using namespace GSL;
    assert(db.parameterized_samples().size() == 0);

    //Make the matrix of peak positions (each column is a sample, each
    //row is a peak-group) and record the mapping between sample_ids
    //and columns and peak_group_ids and rows
    GSL::Matrix peak_pos(pg_in_all_samples.size(),
			 db.unparameterized_samples().size());
    map<unsigned, unsigned> 
      row_to_pg_id, pg_id_to_row, //pg_id = peak_group_id
      col_to_sample_id, sample_id_to_col;
    {
      std::vector<UnparameterizedSample>::const_iterator cur_samp;
      for(cur_samp = db.unparameterized_samples().begin();
	  cur_samp != db.unparameterized_samples().end(); ++cur_samp){
	unsigned col = cur_samp - db.unparameterized_samples().begin();
	col_to_sample_id[col] = cur_samp->id();
	sample_id_to_col[cur_samp->id()] = col;
      }
    }

    {
      std::set<PeakGroupKey>::const_iterator cur_pg;
      unsigned row = 0;
      for(cur_pg = pg_in_all_samples.begin(); 
	  cur_pg != pg_in_all_samples.end(); ++cur_pg, ++row){
	row_to_pg_id[row] = cur_pg->id();
	pg_id_to_row[cur_pg->id()] = row;
      }
    }

    {
      std::vector<HumanVerifiedPeak>::const_iterator cur_peak;
      for(cur_peak = db.human_verified_peaks().begin(); 
	  cur_peak != db.human_verified_peaks().end(); ++cur_peak){
	unsigned col = sample_id_to_col[cur_peak->sample_id()];
	unsigned row = pg_id_to_row[cur_peak->peak_group_id()];
	peak_pos.at(row,col)=cur_peak->ppm();
      }
    }
    {
      std::vector<UnverifiedPeak>::const_iterator cur_peak;
      for(cur_peak = db.unverified_peaks().begin(); 
	  cur_peak != db.unverified_peaks().end(); ++cur_peak){
	unsigned col = sample_id_to_col[cur_peak->sample_id()];
	unsigned row = pg_id_to_row[cur_peak->peak_group_id()];
	peak_pos.at(row,col)=cur_peak->ppm();
      }
    }

    if(should_print_matrices){
      std::cerr << "Initial peak positions:\n" << peak_pos;
    }
    
    //Mean center the rows
    mean_center_rows(peak_pos);

    //SVD
    GSL::Matrix u(1,1),v(1,1);
    GSL::Vector sigma(1);
    bool more_groups_than_samples = peak_pos.rows() > peak_pos.cols();
    if(more_groups_than_samples){
      u = peak_pos; 
    }else{
      u = peak_pos.transpose();
    }
    v = GSL::Matrix(u.cols(), u.cols());
    sigma = GSL::Vector(u.cols());
    gsl_linalg_SV_decomp_jacobi(u.ptr(), v.ptr(), sigma.ptr());    

    //Copy the correct matrix to the sample-params object
    //Sample params has one row for each sample and each column
    //corresponds to a parameter.  The variance explained by the ith
    //column is proportional to the square of the ith element of sigma
    GSL::Matrix sample_params(1,1);
    if(more_groups_than_samples){
      sample_params = v;
    }else{
      sample_params = u;
    }

    //Convert sigmas to fractional variances && determine how many are needed
    {
      double sum = 0;
      for(std::size_t i = 0; i < sigma.size(); ++i){
	sigma[i] *= sigma[i];
	sum += sigma[i];
      }
      if(sum > 0){
	for(std::size_t i = 0; i < sigma.size(); ++i){
	  sigma[i]/=sum;
	}
      }
    }

    std::size_t num_components = 0;
    double sum_of_used_variances = 0.0;
    while(sum_of_used_variances < frac_variance && 
	  num_components < sigma.size()){
      sum_of_used_variances += sigma[num_components];
      ++num_components;
    }
    
    //Convert fractional variances to ParamStats object (copying to a
    //stl vector is necessary because you can't (always) pointer-index
    //through a gsl vector
    std::vector<double> vars(num_components); 
    for(std::size_t i = 0; i < num_components; ++i){
      vars.at(i) = sigma[i];
    }
    ParamStats param_stats(vars.begin(), vars.end());

    //Convert rows of sample_params matrix to sample parameter objects
    std::vector<ParameterizedSample> samples;
    for(std::size_t row=0; row < sample_params.rows(); ++row){
      for(std::size_t col=0; col < num_components; ++col){
	vars.at(col)=sample_params.at(row,col);
      }
      const UnparameterizedSample &orig=db.unparameterized_samples()[row];
      samples.push_back(ParameterizedSample(orig.id(), orig.sample_class(), 
					    vars.begin(), vars.end()));
    }
    
    //Pack results into a pair and return
    return std::make_pair(samples, param_stats);
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
  ///\param params the parameterized versions of all unparameterized
  ///samples in the database
  ///
  ///\param stats the param_stats object to add to the database
  void add_params_to_db
  (PeakMatchingDatabase& db, 
   const std::vector<ParameterizedSample>& params,
   const ParamStats stats){
    assert(db.unparameterized_samples().size() == params.size());
    assert(db.parameterized_samples().size() == 0);
    assert(db.param_stats().size() == 0);
    db.unparameterized_samples().clear();
    db.parameterized_samples()=params;
    db.param_stats().push_back(stats);
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
  if(argc != 2 && argc != 3){
    print_usage_and_exit("ERROR: Wrong number of arguments.");
  }

  bool should_print_matrices = argc==3;

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

  std::pair<std::vector<ParameterizedSample>, ParamStats> params = 
    calculate_sample_parameters(db, pg_in_all_samples, fraction_variance, 
				should_print_matrices);

  add_params_to_db(db, params.first, params.second);
  
  return !db.write(std::cout);
}
