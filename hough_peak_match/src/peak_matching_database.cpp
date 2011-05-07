///\file
///\brief Definitions members of the PeakMatchingDatabase class

#include "peak_matching_database.hpp"
#include "utils.hpp"
#include <string>
#include <vector>

namespace HoughPeakMatch{
  void PeakMatchingDatabase::make_empty(){
    parameterized_peak_groups.clear();
    detected_peak_groups.clear();
    human_verified_peaks.clear();
    unverified_peaks.clear();
    unknown_peaks.clear();
    samples.clear();
    sample_params.clear();
    param_statistics.clear();
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
	///\todo finish writing the actual object creation code.
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
	}else{
	  make_empty(); return false;
	}
      }
      ///\todo write the referential integrity code
    }
    return true;
  }
}
