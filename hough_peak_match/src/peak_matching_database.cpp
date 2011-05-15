///\file
///\brief Definitions members of the PeakMatchingDatabase class

#include "peak_matching_database.hpp"
#include "utils.hpp"
#include <string>
#include <vector>
#include <set>
#include <algorithm>
#include <iterator>
#include <fstream>


namespace HoughPeakMatch{
  void PeakMatchingDatabase::make_empty(){
    parameterized_peak_groups_.clear();
    detected_peak_groups_.clear();
    human_verified_peaks_.clear();
    unverified_peaks_.clear();
    unknown_peaks_.clear();
    samples_.clear();
    sample_params_.clear();
    param_stats_.clear();
  }


  bool PeakMatchingDatabase::read(std::istream& in){
    using namespace std;
    string line;
    while(getline(in,line)){
      //Skip comments
      if(line.size() > 0 && line[0] == '#'){ 
	continue; }
      //Extract words from the line
      vector<string> words = split(line);
      //Skip blank lines
      if(words.size() == 0) { 
	continue; }
      //Add the object to the database
      string line_type = words[0];
      {
	bool failed = false;
	if(line_type == "parameterized_peak_group"){
	  ParameterizedPeakGroup g = 
	    ParameterizedPeakGroup::from_text_line(words, failed);
	  if(failed){ 
	    make_empty(); return false; 
	  }
	  parameterized_peak_groups_.push_back(g);
	}else if(line_type == "detected_peak_group"){
	  DetectedPeakGroup g = 
	    DetectedPeakGroup::from_text_line(words, failed);
	  if(failed){ 
	    make_empty(); return false; 
	  }
	  detected_peak_groups_.push_back(g);
	}else if(line_type == "human_verified_peak"){
	  HumanVerifiedPeak p = 
	    HumanVerifiedPeak::from_text_line(words, failed);
	  if(failed){ 
	    make_empty(); return false; 
	  }
	  human_verified_peaks_.push_back(p);
	}else if(line_type == "unverified_peak"){
	  UnverifiedPeak p = 
	    UnverifiedPeak::from_text_line(words, failed);
	  if(failed){ 
	    make_empty(); return false; 
	  }
	  unverified_peaks_.push_back(p);
	}else if(line_type == "unknown_peak"){
	  UnknownPeak p = 
	    UnknownPeak::from_text_line(words, failed);
	  if(failed){ 
	    make_empty(); return false; 
	  }
	  unknown_peaks_.push_back(p);
	}else if(line_type == "sample"){
	  Sample s = 
	    Sample::from_text_line(words, failed);
	  if(failed){ 
	    make_empty(); return false; 
	  }
	  samples_.push_back(s);
	}else if(line_type == "sample_params"){
	  SampleParams sp = 
	    SampleParams::from_text_line(words, failed);
	  if(failed){ 
	    make_empty(); return false; 
	  }
	  sample_params_.push_back(sp);
	}else if(line_type == "param_stats"){
	  ParamStats ps = 
	    ParamStats::from_text_line(words, failed);
	  if(failed){ 
	    make_empty(); return false; 
	  }
	  param_stats_.push_back(ps);
	}else{
	  make_empty(); return false;
	}
      }
    }
    //Ensure that the completed database satisfies the various
    //referential integrity and other constraints on the database's
    //structure.
    if( ! this->satisfies_constraints() ){
      make_empty(); return false;
    }	
    return true;
  }
  
  namespace{
    ///\brief The id member in each object returns a value not
    ///\brief repeated by any other object in the collection.
    ///
    ///\param used_ids In/Out parameter - on input contains a list of
    ///ids that should not be used by any member of the collection
    ///because they are already used.  On output, if this collection
    ///has unique ids, then it contains all ids used by this
    ///collection and any that were used previously.  If this
    ///collection duplicates an id, (i.e. return value is false) then
    ///the contents of used_ids are not specified.
    ///
    ///\param begin Iterator pointing to the first item in the collection
    ///
    ///\param end Iterator pointing one past the last item in the collection
    ///
    ///\return true if no id for one element of the collection appears
    ///also as an id of another element.  returns false if there are
    ///duplicate ids.
    template<class IDType, class InputIter>
      bool has_unique_ids(std::set<IDType>& used_ids, 
			  InputIter begin, InputIter end){
      ;
      for(InputIter cur = begin; cur != end; ++cur){
	if(used_ids.count(cur->id()) == 0){
	  used_ids.insert(cur->id());
	}else{
	  return false;
	}
      }
      return true;
    }
    
    ///\brief Returns whether the foreign keys in collection A are all
    ///\brief ids in collection B
    ///
    ///Elements of collection B must have a const id() function that
    ///returns get_key_from::KeyType
    ///
    ///\param get_key_from A function/function object that returns the
    ///desired foreign key given an object of the type contained in
    ///collection a.  It must have a type member KeyType that gives
    ///the type returned from operator().  The prototype is
    /// <code> KeyType get_key_from(const object_type&) const; </code>
    ///
    ///\param a_begin An iterator pointing to the first item in collection A
    ///
    ///\param a_end An iterator pointing to one-past the last item in
    ///collection A
    ///
    ///\param b_begin An iterator pointing to the first item in collection B
    ///
    ///\param b_end An iterator pointing to one-past the last item in
    ///collection B
    ///
    ///\return true if the set of foreign keys in A's objects is a
    ///subset of the set of ids in B's objects
    template<class KeyExtractor, class InputIterA, class InputIterB>
      bool all_foreign_keys_in_a_are_ids_in_b
      (const KeyExtractor& get_key_from, 
       InputIterA a_begin, InputIterA a_end,
       InputIterB b_begin, InputIterB b_end){
      typedef typename KeyExtractor::KeyType KeyType;
      //Get the keys from a
      std::set<KeyType> keys;
      for(InputIterA cur = a_begin; cur != a_end; ++cur){
	keys.insert(get_key_from(*cur));
      }
      //Get the ids from b
      std::set<KeyType> ids;
      for(InputIterB cur = b_begin; cur != b_end; ++cur){
	ids.insert(cur->id());
      }
      return std::includes(ids.begin(), ids.end(), keys.begin(), keys.end());
    }

    ///\brief KeyExtractor that extracts peak_id foreign keys
    ///
    ///For use with all_foreign_keys_in_a_are_ids_in_b
    struct PeakIDExtractor{
      ///\brief The type of the peak_id
      typedef unsigned KeyType;

      ///\brief Returns the peak_id of an object of type T
      ///
      ///\param t The object whose peak_id is to be returned
      ///
      ///\returns the peak_id of an object of type T
      template<class T>
      KeyType operator()( const T& t) const { return t.peak_id(); }
    };

    ///\brief KeyExtractor that extracts sample_id foreign keys
    ///
    ///For use with all_foreign_keys_in_a_are_ids_in_b
    struct SampleIDExtractor{
      ///\brief The type of the sample_id
      typedef unsigned KeyType;

      ///\brief Returns the sample_id of an object of type T
      ///
      ///\param t The object whose sample_id is to be returned
      ///
      ///\returns the sample_id of an object of type T
      template<class T>
      KeyType operator()( const T& t) const{ return t.sample_id(); }
    };

    ///\brief Functional that extracts the number of parameter vectors
    ///\brief implied by a given object's members.
    struct NumParamsExtractor{
      ///\brief Returns the number of parameters for an object of type T
      ///
      ///\param t The object whose parameters are being counted
      ///
      ///\return the number of parameters for the particular object of type T
      template<class T>
      inline std::size_t operator()(const T& t) const{ 
	return t.params().size(); }
    };
    
    /// @cond SUPPRESS

    ///\brief Specialization returning the number of parameters in a
    ///\brief ParamStats object
    ///
    ///\param ps The ParamStats object whose parameters are being counted
    ///
    ///\return the number of parameters for the ParamStats object
    template<>
      inline std::size_t NumParamsExtractor::operator()(const ParamStats& ps) const{ 
      return ps.frac_variances().size(); }

    /// @endcond 
  }



  bool PeakMatchingDatabase::satisfies_constraints(){
    using std::pair;

    //Check that all object ids are unique over all items that have
    //that class
    std::set<unsigned> peak_group_ids;
    bool unique_ids = 
      has_unique_ids<unsigned>(peak_group_ids, 
			       parameterized_peak_groups_.begin(),
			       parameterized_peak_groups_.end())
      && has_unique_ids<unsigned>(peak_group_ids, 
				  detected_peak_groups_.begin(),
				  detected_peak_groups_.end());
    std::set<pair<unsigned, unsigned> > peak_ids;
    unique_ids = unique_ids
      && has_unique_ids<pair<unsigned,unsigned> >
      (peak_ids, human_verified_peaks_.begin(), 
       human_verified_peaks_.end())
      && has_unique_ids<pair<unsigned,unsigned> >
      (peak_ids, unverified_peaks_.begin(),
       unverified_peaks_.end())
      && has_unique_ids<pair<unsigned,unsigned> >
      (peak_ids, unknown_peaks_.begin(),
       unknown_peaks_.end());
    
    std::set<unsigned> sample_ids;
    unique_ids = unique_ids
      && has_unique_ids<unsigned>(sample_ids, samples_.begin(),
				  samples_.end());

    //Check that at most one param_stats object

    bool correct_num_param_stats = param_stats_.size() <= 1;
    
    //Check referential integrity constraints

    bool ref_integrity = 
      all_foreign_keys_in_a_are_ids_in_b
      (SampleIDExtractor(), 
       unknown_peaks_.begin(), unknown_peaks_.end(),
       samples_.begin(), samples_.end())
      &&
      all_foreign_keys_in_a_are_ids_in_b
      (SampleIDExtractor(), 
       unverified_peaks_.begin(), unverified_peaks_.end(),
       samples_.begin(), samples_.end())
      &&
      all_foreign_keys_in_a_are_ids_in_b
      (SampleIDExtractor(), 
       human_verified_peaks_.begin(), human_verified_peaks_.end(),
       samples_.begin(), samples_.end())
      &&
      all_foreign_keys_in_a_are_ids_in_b
      (SampleIDExtractor(), 
       sample_params_.begin(), sample_params_.end(),
       samples_.begin(), samples_.end())
      ;
      
    //Check that all param counts are equal

    std::set<std::size_t> param_counts;
    std::insert_iterator<std::set<std::size_t> > inserter = 
      std::inserter(param_counts, param_counts.begin());

    std::transform(parameterized_peak_groups_.begin(),
		   parameterized_peak_groups_.end(),
		   inserter, NumParamsExtractor());
    
    std::transform(detected_peak_groups_.begin(),
		   detected_peak_groups_.end(),
		   inserter, NumParamsExtractor());
    
    std::transform(sample_params_.begin(),
		   sample_params_.end(),
		   inserter, NumParamsExtractor());

    std::transform(param_stats_.begin(),
		   param_stats_.end(),
		   inserter, NumParamsExtractor());

    
    bool all_param_counts_equal = param_counts.size() <= 1;
    
    return unique_ids && correct_num_param_stats && ref_integrity 
      && all_param_counts_equal;
  }


  PeakMatchingDatabase read_database(std::string file_name, 
				     std::string which_db,
				     void (*print_error_and_exit)(std::string)){
    std::ifstream db_stream(file_name.c_str());
    if(!db_stream){
      std::string msg = 
	"ERROR: Could not open "+ which_db + " database \"" + file_name + "\"";
      print_error_and_exit(msg);
    }
    
    PeakMatchingDatabase db;
    bool success = db.read(db_stream);
    if(!success){
      std::string msg = 
	"ERROR: " + which_db + " database \"" + file_name + "\" is invalid";
      print_error_and_exit(msg);
    }
    
    return db;
  }


}
