///\file
///\brief Main routine and supporting code for the simple_hough executable

#include "peak_matching_database.hpp"
#include <boost/program_options.hpp>
#include <iostream>
#include <cstdlib> //For exit
#include <algorithm>
#include <cmath>

namespace HoughPeakMatch{
  ///\brief A closed interval of the real line represented by its
  ///minimum and maximum values
  struct Range{
    ///\brief The minimum value in the range
    double min;
    ///\brief The maximum value in the range (keep it >= min)
    double max;

    ///\brief Create an uninitialized range
    Range():min(),max(){};

    ///\brief Create a range from \a min to \a max
    ///
    ///Assumes that min <= max
    ///
    ///\param min The minimum value in the range
    ///
    ///\param max The maximum value in the range
    Range(double min, double max):min(min),max(max){
      assert(min <= max);
    };

    ///\brief Return the length of the closed interval (max-min)
    ///\return the length of the closed interval (max-min)
    double length(){ 
      assert(max >= min);
      return max-min;
    }
    ///\brief Return the fraction of the way along the interval that
    ///val represents
    ///
    ///Imagine that val is a point in the interval.  Then if val is at
    ///the maximum end point, it is all the way along the interval and
    ///a 1 is returned.  If not, then linearly interpolate from the
    ///minimum end point being 0.
    ///
    ///If val is not in the interval then it is treated as one of the
    ///end-points.
    double fraction(double val){
      assert(max >= min);
      if(max == min || val >= max){ 
	return 1;
      }else{
	double dist = val - min;
	if(dist <= 0){
	  return 0;
	}else{
	  return dist/length();
	}
      }
    }

    ///\brief Return true iff \a val is in the interval represented by
    ///this Range
    ///
    ///\param val the value whose containment is tested
    ///
    ///\return true iff \a val is in the interval represented by
    ///this Range
    bool contains(double val){
      assert(max >= min);
      return val <= max && val >= min;
    }

  };
  ///\brief A closed interval represented by a certain number of
  ///discrete cells
  struct DiscretizedRange{
    ///\brief The range of values that is discretized
    Range range;
    ///\brief The number of cells the range is broken into
    std::size_t num_cells;

    //\brief Create an uninitialized discretized range
    DiscretizedRange():range(),num_cells(){}

    ///\brief Create a Discretized range using \a range and \a num_cells
    ///
    ///\param range The range of values that is discretized
    ///
    ///\param num_cells The number of cells the range is broken into
    DiscretizedRange(Range range, std::size_t num_cells)
      :range(range), num_cells(num_cells){}

    ///\brief Return the index of the cell into which the given value
    ///falls (-1 if outside range)
    ///
    ///\param val The value whose cell index is sought
    ///
    ///\return the index of the cell into which the given value
    ///falls (-1 if outside range)
    int which_cell(double val){
      if(num_cells == 0){
	return -1;
      }else if(range.contains(val)){
	double frac = range.fraction(val);
	if(frac == 1.0){
	  return num_cells - 1;
	}else{
	  return (int)(frac*num_cells);
	}
      }else{
	return -1;
      }
    }
  };

  ///\brief A marker class given to indicate that an iterator should
  ///start at the beginning
  class AtBeginning{};

  ///\brief A marker class given to indicate that an iterator should
  ///start at the beginning
  class AtEnd{};

  ///\brief Iterates through ppm-slices of a given SimpleAccumulator
  class SliceIterator{
    ///\brief A reference to the dims_ structure in the source
    ///SimpleAccumulator
    const std::vector<DiscretizedRange>& dims_;
    
    ///\brief A reference to the votes structure of the source accumulator
    std::vector<double>& votes_;

    ///\brief params_indices[i] is the coordinate along dimension
    ///given by dims_[i+1]
    std::vector<std::size_t> params_indices_;

    ///\brief true iff the iterator is one-past-the-end
    ///
    ///This is used for quick comparisons to the end iterator.  If it
    ///is true, all other fields are ignored.
    bool at_end_;
  public:
    ///\brief Create a slice iterator that starts at the beginning 
    ///
    ///\param tag An empty class telling the compiler in a readable
    ///way to start the iterator at the beginning
    ///
    ///\param dims the dims_ member of a SimpleAccumulator
    ///
    ///\param votes the votes_ member of a SimpleAccumulator
    SliceIterator(const AtBeginning tag, 
		  const std::vector<DiscretizedRange>& dims,
		  std::vector<double>& votes);

    ///\brief Create a slice iterator that starts at the end 
    ///
    ///\param tag An empty class telling the compiler in a readable
    ///way to start the iterator at the end
    ///
    ///\param dims the dims_ member of a SimpleAccumulator
    ///
    ///\param votes the votes_ member of a SimpleAccumulator
    SliceIterator(const AtEnd tag, 
		  const std::vector<DiscretizedRange>& dims,
		  std::vector<double>& votes);
  };

  SliceIterator::SliceIterator(const AtBeginning, 
			       const std::vector<DiscretizedRange>& dims,
			       std::vector<double>& votes)
    :dims_(dims),votes_(votes),params_indices_(dims.size(),0),at_end_(false){
    for(std::vector<DiscretizedRange>::const_iterator d = dims.begin();
	d != dims.end(); ++d){
      at_end_ = at_end_ || d->num_cells==0;
    }
  }

  SliceIterator::SliceIterator(const AtEnd, 
			       const std::vector<DiscretizedRange>& dims,
			       std::vector<double>& votes)
    :dims_(dims),votes_(votes),params_indices_(dims.size(),0),at_end_(true){}

  ///\brief A multi-dimensional array for accumulating votes for
  ///peak-group locations
  class SimpleAccumulator{
    ///\brief dim_[i] is a DiscretizedRange describing the ith dimension
    ///
    ///The first dimension is ppm, the rest of the dimensions are the
    ///peak-parameters in turn
    std::vector<DiscretizedRange> dims_;

    ///\brief All the votes in this accumulator
    ///
    ///The votes are actually a multidimensional array layed out with
    ///the first dimension moving fastest, then the second dimension
    ///and so forth.  So, if there were such an operator
    ///votes.at(a,b,c) (where a,b, and c are the cell locations on
    ///dimensions 0,1,and 2) would be located at
    ///a+dims_[0].num_cells*(b+dims_[1].num_cells*c)
    std::vector<double> votes_;
  public:
    ///\brief Create an accumulator that can hold the data from \a db
    ///with the specified resolutions
    ///
    ///Assumes that the database has exactly one ParamStats object
    ///
    ///\param ppm_dimension Describes the range and the number of
    ///cells to use for the ppm location dimension
    ///
    ///\param param_base_dimension Describes the range for all
    ///parameters and the number of cells to use for the most
    ///important parameter.  The other dimensions will have numbers of
    ///cells allocated according to their importance.  If the most
    ///important parameter explains x% of the variance and another
    ///parameter explains y% of the variance then the other parameter
    ///will be allocated ceil(\a base_res * y/x) cells.
    ///
    ///\param ps a ParamStats object giving the fractional variances
    ///explained for the different parameters
    SimpleAccumulator(DiscretizedRange ppm_dimension,
		      DiscretizedRange param_base_dimension,
		      const PeakMatchingDatabase& db);

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
    return location_res*
      non_loc_size*sizeof(double)/(1024*1024*1024);
  }


  SimpleAccumulator::SimpleAccumulator
  (DiscretizedRange ppm_dimension,
   DiscretizedRange param_base_dimension,
   const PeakMatchingDatabase& db)
    :dims_(1+db.param_stats()[0].frac_variances().size(),param_base_dimension),
     votes_(){
    //Set the first dimension to ppm_dimension
    dims_.at(0)=ppm_dimension;
    //Rescale the other dimensions according to their proportion of
    //maximum variance explained
    ParamStats ps(db.param_stats()[0]);
    const std::vector<double>& fv = ps.frac_variances();
    if(fv.size() > 0){
      double max_var=*std::max_element(fv.begin(),fv.end());
      assert(max_var >= 0);
      if(max_var > 0){
	for(unsigned i = 1; i < dims_.size(); ++i){
	  double cur_var = fv.at(i-1);
	  if(cur_var != max_var){
	    std::size_t& cur_cells = dims_.at(i).num_cells;
	    cur_cells=std::ceil(cur_cells * cur_var/max_var);
	  }
	}
      }
    }

    //The product of the dimensions is the total number of cells
    std::size_t num_cells = 1;
    std::vector<DiscretizedRange>::const_iterator dim;
    for(dim = dims_.begin(); dim != dims_.end(); ++dim){
      num_cells *= dim->num_cells;
    }
    votes_.resize(num_cells,0);
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
      << "       max_param_value standardDeviation max_GiB_RAM < \n"
      << "       initial_db > db_with_detected_peaks\n";
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
  using std::size_t; using po::value; using std::string;
  //Parse command line options
  size_t central_location_resolution;
  size_t base_resolution;
  double max_param_value;
  double standard_deviation;
  double max_gb_ram;
  string histogram_file;
  double histogram_bins;

  po::options_description opt_desc("Options");
  opt_desc.add_options()
    ("help,?", "produce help message")
    ("central_location_resolution",value<size_t>(&central_location_resolution),
     "The number of steps to use in defining the central location of the peaks")
    ("base_resolution",value<size_t>(&base_resolution),
     "The number of steps to use for the first principal component. "
     "If another principal component explains 25% of the variance of "
     "the first it will be given 25% of the steps")
    ("max_param_value",value<double>(&max_param_value),
     "The maximum value that any of the parameters can take on.  A search "
     "will be made between -max_param_value and +max_param_value.  Any "
     "negative value will be made positive.")
    ("standard_deviation",value<double>(&standard_deviation),
     "The standard deviation of the Gaussian used in \"fuzzifying\" the "
     "Hough transform")
    ("max_gb_ram", value<double>(&max_gb_ram), "gives the maximum number "
     "of GiB of RAM to use. The program will either use partitioning methods "
     "to try and meet this constraint or exit with an error. The program "
     "calculates only an estimate, so this is more of a suggestion than a "
     "hard rule.")
    ("histogram",value<string>(&histogram_file), "If present, the "
     "space-separated data for a histogram of the accumulated values "
     "will be written to this file.")
    ("histogram_bins",value<double>(&histogram_bins), 
     "Gives the number of bins to use for generating a histogram.")
    ;

  const unsigned num_pos_opt = 5;
  const char* pos_opt_strs[num_pos_opt]=
    {"central_location_resolution", "base_resolution", "max_param_value", 
     "standard_deviation", "max_gb_ram"};

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

  unsigned num_arguments_present = 0;
  for(const char** opt = pos_opt_strs; opt != pos_opt_strs+num_pos_opt; ++opt){
    num_arguments_present+= (opts.count(*opt) > 0) ? 1 : 0;
  }
  if(num_arguments_present != num_pos_opt){
    print_usage_and_exit("ERROR: did not specify all command line arguments",
			 opt_desc);
  }

  if(max_param_value < 0){ max_param_value = -max_param_value; }

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


  DiscretizedRange ppm_dim(Range(-4,14),central_location_resolution);
  DiscretizedRange base_dim(Range(-max_param_value, max_param_value),
			    base_resolution);
  SimpleAccumulator acc(ppm_dim, base_dim, db);
  

  ///\todo add code for histogram

  ///\todo stub
  std::cout << "These parameters would require " << estimated_size
	    << " GiB of RAM.\n";

  return 0;
}
