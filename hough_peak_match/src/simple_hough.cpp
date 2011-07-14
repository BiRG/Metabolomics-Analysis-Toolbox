///\file
///\brief Main routine and supporting code for the simple_hough executable

#include "peak_matching_database.hpp"
#include "utils.hpp"
#include <boost/program_options.hpp>
#include <boost/math/distributions/normal.hpp>
#include <iostream>
#include <cstdlib> //For exit
#include <algorithm>
#include <cmath>
#include <fstream>

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
    double length() const{ 
      assert(max >= min);
      return max-min;
    }
    ///\brief Return the fraction of the way along the interval that
    ///\a val represents
    ///
    ///Imagine that val is a point in the interval.  Then if val is at
    ///the maximum end point, it is all the way along the interval and
    ///a 1 is returned.  If not, then linearly interpolate from the
    ///minimum end point being 0.
    ///
    ///If val is not in the interval then it is treated as one of the
    ///end-points.
    ///
    ///\param val The value to determine where it is in the interval
    ///
    ///\return the fraction of the way along the interval that
    ///\a val represents
    double fraction(double val) const{
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
    bool contains(double val) const{
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
    int which_cell(double val) const{
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

    ///\brief Return the value that would fall in the center of the
    ///cell with the given \a index
    ///
    ///Whether the index is in bounds or not is ignored
    ///
    ///\param index The index of the cell whose center value should be given
    ///
    ///\return the value that would fall in the center of the cell
    ///with the given \a index
    double center_value_at(int index) const{
      if(num_cells > 0){
	double cell_width = range.length()/num_cells;
	return (index+0.5)*cell_width+range.min;
      }else{
	return (range.min+range.max)/2;
      }
    }

    ///\brief Return the index of the cell into which the given value
    ///would fall if there were a cell for every integer
    ///
    ///\param val The value whose cell index is sought
    ///
    ///\return the index of the cell into which the given value would
    ///fall if there were a cell for every integer
    int which_cell_unbounded(double val) const{
      if(num_cells == 0 || range.length() == 0){
	return 0;
      }else{
	double frac = (val-range.min)/range.length();
	return (int)(std::floor(frac*num_cells));
      }
    }

    ///\brief Returns the range of values contained in the given cell
    ///
    ///For any valid cell index, returns the range [lower, upper] of
    ///values that will fall into that cell.  If the index is invalid,
    ///returns the bounds as if the cells continued far enough in the
    ///correct direction to make it a valid index.
    ///
    ///Really, the range would be a half-open interval [lower,upper)
    ///for all but the last cell.  However, that is significantly more
    ///complicated to implement with no real gains in this context, so
    ///I just reuse my closed interval for all cells.
    ///
    ///\param cell_index the index of the cell whose bounds are sought
    ///
    ///\returns the range of values contained in the given cell
    Range cell_bounds(int cell_index) const{
      double cell_width = range.length()/num_cells;
      return Range(range.min+cell_index*cell_width, 
		   range.min+(cell_index+1)*cell_width);
    }
  };

  ///\brief Represents a closed interval over the integers
  struct DiscreteRange{
    ///\brief The minimum element in the range - always maintain <= max
    int min;
    ///\brief The maximum element in the range
    int max;

    ///\brief Create a range [min,max]
    ///\param min The minimum element in the range
    ///\param max The maximum element in the range
    DiscreteRange(int min, int max):min(min), max(max){
      assert(min <= max);
    }
  };

  ///\brief Holds a frequency histogram with evenly spaced bins
  class Histogram{
    ///\brief The discretization used in this histogram
    DiscretizedRange r;
    
    ///\brief The counts of the bins for the histogram
    std::vector<std::size_t> counts;
  public:
    ///\brief Create a histogram with zeroed counts using bins
    ///described by \a range
    ///
    ///\params range The discretization to use for the bins
    Histogram(DiscretizedRange range):r(range), counts(range.num_cells,0){}

    ///\brief Add one count to the bin containing \a val
    ///
    ///If \a val is not in range, no bin is incremented
    ///
    ///\param val the value that determines which bin to increment
    void add(double val){
      int idx = r.which_cell(val);
      if(idx >= 0){
	++counts.at(idx);
      }
    }

    friend std::ostream& operator<<(std::ostream& out, Histogram& h);
  };

  ///\brief Print \a h to \a out.
  ///
  ///\param out The stream on which to print the histogram
  ///
  ///\param h The histogram to print
  ///
  ///\return \a out after printing
  std::ostream& operator<<(std::ostream& out, Histogram& h){
    using std::setw; using std::endl;
    out << setw(16) << "Bin Min" << setw(16) << "Bin Center" 
	<< setw(16) << "Bin Max" << setw(16) << "Bin Count" << endl;
    for(std::size_t i = 0; i < h.r.num_cells; ++i){
      Range rng = h.r.cell_bounds(i);
      double center = h.r.center_value_at(i);
      std::size_t count = h.counts.at(i);
      out << setw(16) << rng.min << setw(16) << center
	  << setw(16) << rng.max << setw(16) << count << endl;
    }
    return out;
  }

  ///\brief A buffer that can hold a 1D slice of a SimpleAccumulator
  ///along the ppm axis and accumulate Gaussians.
  ///
  ///A better name might be SliceGaussianAccumulator but that is too
  ///long to type all the time
  class SliceBuffer{
    ///\brief Describes the size of the slice in both ppm and number
    ///of accumulators
    DiscretizedRange ppm_range_;

    ///\brief The standard deviation of the Gaussians to accumulate
    ///
    ///Will always be non-negative
    double std_dev_;    
    
    ///\brief The accumulator cells for the slice buffer
    std::vector<double> cells_;
  public:
    ///\brief A constant iterator through the accumulators
    ///*iterator will give a const double
    typedef std::vector<double>::const_iterator const_iterator;

    ///\brief Create a zeroed slice buffer that accumulates Gaussians with \a
    ///standard_deviation
    ///
    ///\param standard_deviation The standard deviation of the
    ///Gaussians to accumulate
    ///
    ///\param ppm_range Describes the size of the slice in both ppm
    ///and number of accumulators
    SliceBuffer(DiscretizedRange ppm_range, double standard_deviation)
      :ppm_range_(ppm_range),std_dev_(std::abs(standard_deviation)),
       cells_(ppm_range.num_cells,0) {}

    ///\brief Return an iterator to the beginning of the accumulator cells
    ///
    ///\return Return an iterator to the beginning of the accumulator cells
    const_iterator begin() const{ 
      return cells_.begin(); }

    ///\brief Return a one-past-the-end iterator to the accumulator cells
    ///
    ///\return a one-past-the-end iterator to the accumulator cells
    const_iterator end() const{ 
      return cells_.end(); }

    ///\brief Fill the accumulators of this SliceBuffer with zeroes
    void zero_fill(){
      std::fill(cells_.begin(), cells_.end(), 0);
    }

    ///\brief Accumulate a Gaussian with area \a weight, mean \a mean
    ///and the standard deviation given on creation of this
    ///SliceBuffer
    ///
    ///Doesn't add the whole Gaussian, just 5 standard deviations
    ///
    ///\param mean The mean of the Gaussian to add (in ppm)
    ///
    ///\param weight The total area of the gaussian to add
    void add_gaussian(double mean, double weight);
  };

  void SliceBuffer::add_gaussian(double mean, double weight){
    using std::size_t; using boost::math::cdf;
    //Ensure this is a sane slice
    if(ppm_range_.num_cells == 0){ 
      return; 
    }
    //Limit to 5 standard deviations
    int lower_bound = ppm_range_.which_cell_unbounded(mean-5*std_dev_);
    int upper_bound = ppm_range_.which_cell_unbounded(mean+5*std_dev_);
    if(lower_bound >= (int)cells_.size()){ return; }
    if(upper_bound < 0){ return; }
    if(lower_bound < 0){ lower_bound = 0; }
    if(upper_bound >= (int)cells_.size()){ upper_bound = cells_.size()-1; }
    //Within that range add the Gaussian values
    boost::math::normal n(mean,std_dev_);
    for(int index = lower_bound; index <= upper_bound; ++index){
      Range cell = ppm_range_.cell_bounds(index);
      cells_.at(index) += weight*(cdf(n, cell.max)-cdf(n, cell.min));
    }
  }

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

    ///\brief The index of the current slice, considering the votes as a 1-d
    ///array of slices
    std::size_t slice_num_;

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

    ///\brief Return the peak parameter vector in effect at this slice
    ///
    ///\return the peak parameter vector in effect at this slice
    std::vector<double> params() const{
      std::vector<double> ret; ret.reserve(dims_.size()-1);
      std::vector<DiscretizedRange>::const_iterator dim = dims_.begin();
      std::vector<std::size_t>::const_iterator param = params_indices_.begin();
      for(++dim; dim != dims_.end(); ++dim,++param){
	ret.push_back(dim->center_value_at(*param));
      }
      return ret;
    }

    ///\brief Set the votes in the slice pointed to by this iterator
    ///to the max of those votes and those in \a buf
    ///
    ///\param buf The votes that will become the new votes if they are
    ///greater
    void set_to_max(const SliceBuffer& buf){
      SliceBuffer::const_iterator b = buf.begin();
      std::vector<double>::iterator v = 
	votes_.begin() + slice_num_*dims_.at(0).num_cells;
      std::vector<double>::iterator end = v + dims_.at(0).num_cells;
      while(v != end){
	*v = std::max(*b,*v);
	++b; ++v;
      }
    }

    ///\brief Return true iff this and \a si differ
    ///
    ///\param si The slice iterator being compared with this one
    ///
    ///\warning The result of this comparison is undefined if the
    ///iterators are iterating over different collections of votes or
    ///sets of dimensions
    ///
    ///\return true iff this and \a si differ
    bool operator!=(const SliceIterator& si) const{
      if(at_end_ != si.at_end_){
	return true;
      }else{
	if(at_end_){ 
	  return false;
	}else{
	  return slice_num_ != si.slice_num_ || 
	    params_indices_ != si.params_indices_;
	}
      }
    }

    ///\brief Point to the next slice
    ///
    ///\return Return this iterator after incrementing
    SliceIterator& operator++(){
      if(at_end_){
	return *this; }
      ++slice_num_;
      std::size_t idx;
      for(idx = 0; idx < params_indices_.size(); ++idx){
	if((params_indices_.at(idx)+1) < dims_.at(idx+1).num_cells){
	  ++params_indices_.at(idx);
	  break;
	}else{
	  params_indices_.at(idx) = 0;
	}
      }
      if(idx == params_indices_.size()){
	at_end_ = true;
      }
      return *this;
    }
  };

  SliceIterator::SliceIterator(const AtBeginning, 
			       const std::vector<DiscretizedRange>& dims,
			       std::vector<double>& votes)
    :dims_(dims),votes_(votes),slice_num_(0),
     params_indices_(dims.size()-1,0),at_end_(false){
    for(std::vector<DiscretizedRange>::const_iterator d = dims.begin();
	d != dims.end(); ++d){
      at_end_ = at_end_ || d->num_cells==0;
    }
  }

  SliceIterator::SliceIterator(const AtEnd, 
			       const std::vector<DiscretizedRange>& dims,
			       std::vector<double>& votes)
    :dims_(dims),votes_(votes),slice_num_(0),
     params_indices_(dims.size()-1,0),at_end_(true){}

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
    ///Assumes that the database has exactly one ParamStats object.
    ///The accumulator is created initially zero-filled.
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
    ///\param db The database that this accumulator will accumulate
    ///over
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

    ///\brief Return a histogram of the votes in this accumulator
    ///
    ///\param num_bins The number of bins into which to divide the
    ///range of votes
    ///
    ///\return a histogram of the votes in this accumulator
    Histogram histogram(unsigned num_bins) const;

    ///\brief Return a SliceIterator to the first slice
    ///\return a SliceIterator to the first slice
    SliceIterator begin_slice(){ 
      return SliceIterator(AtBeginning(), dims_, votes_); }

    ///\brief Return a SliceIterator to one-past-the-end slice
    ///\return a SliceIterator to one-past-the-end slice
    SliceIterator end_slice(){ 
      return SliceIterator(AtEnd(), dims_, votes_); }

    ///\brief Accumulate the votes for all the peaks in the given database
    ///
    ///Accumulates votes all peaks fuzzified by a gaussian of width \a
    ///std_dev ppm.
    ///
    ///Assumes that all samples in the database are parameterized.
    ///
    ///\param db The database containing the peaks
    ///
    ///\param standard_deviation The standard deviation to use in
    ///fuzzifying the votes along th ppm axis
    void accumulate(const PeakMatchingDatabase& db, double standard_deviation);

    ///\brief Writes images for ppm x dimension for each parameter in turn
    ///
    ///\param base_name the image file names are formed by adding a
    ///suffix to the base_name.
    ///
    ///\return true iff all images were successfully written
    bool write_to_images(std::string base_name);
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
    :dims_(1+db.param_stats().at(0).frac_variances().size(),param_base_dimension),
     votes_(){
    //Set the first dimension to ppm_dimension
    dims_.at(0)=ppm_dimension;
    //Rescale the other dimensions according to their proportion of
    //maximum variance explained
    ParamStats ps(db.param_stats().at(0));
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
  
  namespace{
    ///\brief A parameterized sample with all its peaks included
    struct FlatSample{
      ///\brief the uniqe id for this sample within the original database
      unsigned sample_id;

      ///\brief The class of this sample
      std::string sample_class;

      ///\brief the sample parameters describing the global
      ///characteristics of this sample
      std::vector<double> params;

      ///\brief the ppms of the peaks in this sample
      std::vector<double> ppms;

      ///\brief Create a sample like \a s with no peaks
      ///
      ///\param s the sample to copy
      FlatSample(const ParameterizedSample& s)
	:sample_id(s.id()), sample_class(s.sample_class()), 
	 params(s.params()), ppms(){}

      ///\brief Create a sample with no peaks, class, or parameters,
      ///just the given sample_id
      ///
      ///Intended for allowing easy searches of associative
      ///containers for a sample with the given id
      ///
      ///\param sample_id The sample_id of the new sample
      FlatSample(unsigned sample_id)
	:sample_id(sample_id), sample_class("!nOT_iN_a_cLASS"),
	 params(), ppms(){}
      
      ///\brief Sort on sample_id
      ///
      ///\param rhs the right hand size of the less-than operator
      ///
      ///\return true iff sample_id < rhs.sample_id
      bool operator<(const FlatSample& rhs) const{
	return sample_id < rhs.sample_id;
      }
    };
  }

  Histogram SimpleAccumulator::histogram(unsigned num_bins) const{
    if(votes_.size() == 0){ 
      Histogram h(DiscretizedRange(Range(0,0),num_bins));
      return h;
    }
    double min = *std::min_element(votes_.begin(), votes_.end());
    double max = *std::max_element(votes_.begin(), votes_.end());
    Histogram h(DiscretizedRange(Range(min,max), num_bins));
    for(std::vector<double>::const_iterator it = votes_.begin();
	it != votes_.end(); ++it){
      h.add(*it);
    }
    return h;
  }

  void SimpleAccumulator::accumulate(const PeakMatchingDatabase& db, 
				     double std_dev){
    using std::set; using std::vector; using std::string;
    using std::vector; 
    //Extract the classes and FlatSamples from the database
    set<string> classes;
    set<FlatSample> all_samples;
    {
      vector<ParameterizedSample>::const_iterator samp;
      for(samp = db.parameterized_samples().begin(); 
	  samp != db.parameterized_samples().end(); ++samp){
	all_samples.insert(*samp);
	classes.insert(samp->sample_class());
      }
    }{
      vector<UnknownPeak>::const_iterator peak;
      for(peak = db.unknown_peaks().begin(); peak != db.unknown_peaks().end();
	  ++peak){
	FlatSample key = peak->sample_id();
	set<FlatSample>::iterator samp = all_samples.find(key);
	assert(samp != all_samples.end());
	double ppm =peak->ppm();
	//The const is there to keep from modifying the ordering in
	//the set.  The ppms field will not change the ordering, so I
	//can cast away const-ness
	FlatSample& flatsamp = const_cast<FlatSample&>(*samp);
	flatsamp.ppms.push_back(ppm);
      }
    }{
      vector<UnverifiedPeak>::const_iterator peak;
      for(peak = db.unverified_peaks().begin(); 
	  peak != db.unverified_peaks().end(); ++peak){
	FlatSample key = peak->sample_id();
	set<FlatSample>::iterator samp = all_samples.find(key);
	assert(samp != all_samples.end());
	double ppm =peak->ppm();
	FlatSample& flatsamp = const_cast<FlatSample&>(*samp);
	flatsamp.ppms.push_back(ppm);
      }
    }{
      vector<HumanVerifiedPeak>::const_iterator peak;
      for(peak = db.human_verified_peaks().begin(); 
	  peak != db.human_verified_peaks().end(); ++peak){
	FlatSample key = peak->sample_id();
	set<FlatSample>::iterator samp = all_samples.find(key);
	assert(samp != all_samples.end());
	double ppm =peak->ppm();
	FlatSample& flatsamp = const_cast<FlatSample&>(*samp);
	flatsamp.ppms.push_back(ppm);
      }
    }

    for(std::set<string>::const_iterator classs = classes.begin();
	classs != classes.end(); ++classs){
      //For each class extract the flat-samples with that class
      std::vector<FlatSample> samples; samples.reserve(all_samples.size());
      for(set<FlatSample>::const_iterator samp = all_samples.begin();
	  samp != all_samples.end(); ++samp){
	if(samp->sample_class == *classs){
	  samples.push_back(*samp);
	  if(samp->params.size() != 1){//DEBUG
	    std::cerr << "Inequal\n";//DEBUG
	  }//DEBUG
	}
      }
      //Then accumulate weighted gaussians in the buffer for all peaks
      //in samples of that class
      double weight = 1.0/samples.size();
      SliceBuffer buf(dims_.at(0), std_dev);
      for(SliceIterator it = begin_slice(); it != end_slice(); ++it){
	std::vector<double> peak_params = it.params();
	buf.zero_fill();
	for(vector<FlatSample>::const_iterator samp = samples.begin();
	    samp != samples.end(); ++samp){
	  if(samp->params.size() != 1){//DEBUG
	    std::cerr << "Inequal\n";//DEBUG
	  }//DEBUG
	  double shift = dot(peak_params, samp->params);
	  for(vector<double>::const_iterator ppm = samp->ppms.begin();
	      ppm != samp->ppms.end(); ++ppm){
	    double mean = *ppm - shift;
	    buf.add_gaussian(mean, weight);
	  }
	}
	it.set_to_max(buf);
      }
    }
  }

  ///\brief Simple 2D gray-scale image class (since boost::gil gave so
  ///many headaches
  ///
  ///\tparam T the type for a pixel
  template<class T>
  class Image{
    ///\brief The image's pixels (stored row-major)
    std::vector<T> pix_;

    ///\brief The width of this image in pixels
    std::size_t width_;
  public:
    ///\brief Create an image with the given dimensions and initial value
    ///\param width the width of the image
    ///\param height the height of the image
    ///\param initial_value the initial value for the pixels in the image
    Image(std::size_t width, std::size_t height, T initial_value)
      :pix_(width*height, initial_value), width_(width){}

    ///\brief constant iterator of the pixels in this image
    typedef typename std::vector<T>::const_iterator const_iterator;
    ///\brief iterator of the pixels in this image
    typedef typename std::vector<T>::iterator iterator;

    ///\brief Return the pixel at \a x \a y
    ///\param x The x coordinate of the pixel to return
    ///\param y The y coordinate of the pixel to return
    ///\return the pixel at \a x \a y
    T& operator()(unsigned x, unsigned y){ 
      return pix_.at(x+y*width_); }

    ///\brief Return the pixel at \a x \a y
    ///\param x The x coordinate of the pixel to return
    ///\param y The y coordinate of the pixel to return
    ///\return the pixel at \a x \a y
    T operator()(unsigned x, unsigned y) const{ 
      return pix_.at(x+y*width_); }

    ///\brief Return an iterator to the top-left pixel in the image
    ///\return an iterator to the top-left pixel in the image
    const_iterator begin() const{ return pix_.begin(); }

    ///\brief Return an iterator to the one-past-the-end pixel in the image
    ///\return an iterator to the one-past-the-end pixel in the image
    const_iterator end() const{ return pix_.end(); }

    ///\brief Return an iterator to the top-left pixel in the image
    ///\return an iterator to the top-left pixel in the image
    iterator begin() { return pix_.begin(); }

    ///\brief Return an iterator to the one-past-the-end pixel in the image
    ///\return an iterator to the one-past-the-end pixel in the image
    iterator end() { return pix_.end(); }

    ///\brief Return the height of this image
    ///\return the height of this image
    std::size_t height() const{ return pix_.size()/width_; }

    ///\brief Return the width of this image
    ///\return the width of this image
    std::size_t width() const{ return width_; }
  };

  ///\brief Write \a im to the file \a filename in pgm format
  ///
  ///\param im The image to write
  ///
  ///\param filename the name of the file where the image will be
  ///written -- this will be overwritten
  ///
  ///\return true iff writing succeeds
  bool write_pgm(std::string filename, const Image<unsigned char>& im){
    std::ofstream out(filename.c_str());
    if(!out){ 
      return false;}
    out << "P5\n" << im.width() << "\n" << im.height() << "\n" << "255\n";
    if(!out){ 
      return false;}
    return out.write(reinterpret_cast<const char*>(&(*im.begin())), 
		     im.width()*im.height());
  }

  bool SimpleAccumulator::write_to_images(std::string base_name){
    using namespace boost::gil;
    using std::size_t;
    size_t width = dims_.at(0).num_cells;
    Range ppm_range = dims_.at(0).range;
    size_t prev_skip = width;
    for(size_t dim = 1; dim < dims_.size(); ++dim){
      //Make a 2D projection onto this dimension and ppm
      size_t height = dims_.at(dim).num_cells;
      size_t skip = prev_skip * height;
      Range vert_range = dims_.at(dim).range;
      Image<double> projection(width,height,0.0);
      for(size_t idx = 0; idx < votes_.size(); ++idx){
	size_t x = idx % width;
	size_t y = (idx % skip) / prev_skip;
	projection(x,y) += votes_.at(idx);
      }

      //Find extrema
      double max = *std::max_element(projection.begin(), projection.end());
      double min = *std::min_element(projection.begin(), projection.end());
      float range = max-min; 
      if(range <= 0) {
	range = 1;
      }
      double scale = 255/range;

      //Convert to 8-bit
      Image<unsigned char> projection8(width, height, 0);
      for (size_t y = 0; y < height; ++y) {
	for (size_t x = 0; x < width; ++x){
	  projection8(x,y) = std::floor(scale*(projection(x,y)-min)+0.5);
	}
      }

      std::ostringstream name;
      name << base_name << "_" << dim << ".pgm";
      if(!write_pgm(name.str(), projection8)){
	return false;
      }

      prev_skip = skip;
    }
    return true;
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
  int histogram_bins;
  string pgm_base_name;

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
    ("histogram_bins",
     value<int>(&histogram_bins)->default_value(15), 
     "Gives the number of bins to use for generating a histogram.")
    ("to-pgm", value<string>(&pgm_base_name), "If present, the dimesions of "
     "Hough accumuators will be written to files beginning with this prefix.")
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
     .positional(pos_opt)
     .style(po::command_line_style::default_style ^ 
	    po::command_line_style::allow_guessing).run(), opts);
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

  acc.accumulate(db, standard_deviation);

  if(opts.count("histogram") > 0){
    std::ofstream out(histogram_file.c_str());
    if(out){
      Histogram h = acc.histogram(histogram_bins);
      out << h;
    }else{
      print_usage_and_exit("Could not open file to write histogram", opt_desc);
    }
  }

  if(opts.count("to-pgm") > 0){
    acc.write_to_images(pgm_base_name);
  }

  ///\todo stub
  std::cout << "These parameters would require " << estimated_size
	    << " GiB of RAM.\n";

  return 0;
}
