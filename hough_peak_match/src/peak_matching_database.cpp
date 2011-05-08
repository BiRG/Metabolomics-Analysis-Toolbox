///\file
///\brief Definitions members of the PeakMatchingDatabase class

#include "peak_matching_database.hpp"
#include "utils.hpp"
#include <string>
#include <vector>
#include <set>
#include <algorithm>

namespace HoughPeakMatch{
  void PeakMatchingDatabase::make_empty(){
    parameterized_peak_groups.clear();
    detected_peak_groups.clear();
    human_verified_peaks.clear();
    unverified_peaks.clear();
    unknown_peaks.clear();
    samples.clear();
    sample_params.clear();
    param_stats.clear();
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
	    ParameterizedPeakGroup::fromTextLine(words, failed);
	  if(failed){ 
	    make_empty(); return false; 
	  }
	  parameterized_peak_groups.push_back(g);
	}else if(line_type == "detected_peak_group"){
	  DetectedPeakGroup g = 
	    DetectedPeakGroup::fromTextLine(words, failed);
	  if(failed){ 
	    make_empty(); return false; 
	  }
	  detected_peak_groups.push_back(g);
	}else if(line_type == "human_verified_peak"){
	  HumanVerifiedPeak p = 
	    HumanVerifiedPeak::fromTextLine(words, failed);
	  if(failed){ 
	    make_empty(); return false; 
	  }
	  human_verified_peaks.push_back(p);
	}else if(line_type == "unverified_peak"){
	  UnverifiedPeak p = 
	    UnverifiedPeak::fromTextLine(words, failed);
	  if(failed){ 
	    make_empty(); return false; 
	  }
	  unverified_peaks.push_back(p);
	}else if(line_type == "unknown_peak"){
	  UnknownPeak p = 
	    UnknownPeak::fromTextLine(words, failed);
	  if(failed){ 
	    make_empty(); return false; 
	  }
	  unknown_peaks.push_back(p);
	}else if(line_type == "sample"){
	  Sample s = 
	    Sample::fromTextLine(words, failed);
	  if(failed){ 
	    make_empty(); return false; 
	  }
	  samples.push_back(s);
	}else if(line_type == "sample_params"){
	  SampleParams sp = 
	    SampleParams::fromTextLine(words, failed);
	  if(failed){ 
	    make_empty(); return false; 
	  }
	  sample_params.push_back(sp);
	}else if(line_type == "param_stats"){
	  ParamStats ps = 
	    ParamStats::fromTextLine(words, failed);
	  if(failed){ 
	    make_empty(); return false; 
	  }
	  param_stats.push_back(ps);
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
    ///<code>KeyType get_key_from(const object_type&) const; </code>
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
  }

  bool PeakMatchingDatabase::satisfies_constraints(){
    using std::pair;
    std::set<unsigned> peak_group_ids;
    bool unique_ids = 
      has_unique_ids<unsigned>(peak_group_ids, 
			       parameterized_peak_groups.begin(),
			       parameterized_peak_groups.end())
      && has_unique_ids<unsigned>(peak_group_ids, 
				  detected_peak_groups.begin(),
				  detected_peak_groups.end());
    std::set<pair<unsigned, unsigned> > peak_ids;
    unique_ids = unique_ids
      && has_unique_ids<pair<unsigned,unsigned> >
      (peak_ids, human_verified_peaks.begin(), 
       human_verified_peaks.end())
      && has_unique_ids<pair<unsigned,unsigned> >
      (peak_ids, unverified_peaks.begin(),
       unverified_peaks.end())
      && has_unique_ids<pair<unsigned,unsigned> >
      (peak_ids, unknown_peaks.begin(),
       unknown_peaks.end());
    
    std::set<unsigned> sample_ids;
    unique_ids = unique_ids
      && has_unique_ids<unsigned>(sample_ids, samples.begin(),
				  samples.end());

    bool correct_num_param_stats = param_stats.size() <= 1;
    
    bool ref_integrity = 
      all_foreign_keys_in_a_are_ids_in_b
      (SampleIDExtractor(), 
       unknown_peaks.begin(), unknown_peaks.end(),
       samples.begin(), samples.end())
      &&
      all_foreign_keys_in_a_are_ids_in_b
      (SampleIDExtractor(), 
       unverified_peaks.begin(), unverified_peaks.end(),
       samples.begin(), samples.end())
      &&
      all_foreign_keys_in_a_are_ids_in_b
      (SampleIDExtractor(), 
       human_verified_peaks.begin(), human_verified_peaks.end(),
       samples.begin(), samples.end())
      &&
      all_foreign_keys_in_a_are_ids_in_b
      (SampleIDExtractor(), 
       sample_params.begin(), sample_params.end(),
       samples.begin(), samples.end())
      ;
      

    ///\todo write other constraints: all params members have the same number of elements
    return unique_ids && correct_num_param_stats && ref_integrity;
  }

}
