#include "utils.hpp"
#include "detected_peak_group.hpp"
#include <cassert>
#include <cstdlib>
#include <sstream>

namespace HoughPeakMatch{
  DetectedPeakGroup DetectedPeakGroup::fromTextLine
  (const std::vector<std::string>& words, bool& failed){
    failed = true;
    DetectedPeakGroup ret;
    if(words.size() < 4){ 
      failed = true;  return ret; } 
    
    if(words.at(0) != "detected_peak_group"){ 
      failed = true; return ret; }
    
    int id_temp = atoi(words.at(1).c_str());
    if(id_temp < 0){ 
      failed = true; return ret; }
    ret.peak_group_id = id_temp;
    
    std::istringstream ppm_in(words.at(2));
    if(!(ppm_in >> ret.ppm_)) { 
      failed = true; return ret; }
    if(is_special_double(ret.ppm())) { 
      failed = true; return ret; }
    
    
    for(size_t i = 3; i < words.size(); ++i){
      double param_temp;
      std::istringstream param_in(words.at(i));
      if(!(param_in >> param_temp)) { 
	failed = true; return ret; }
      if(is_special_double(param_temp)) { 
	failed = true; return ret; }
      ret.params_.push_back(param_temp);
    }
    assert(ret.params().size() != 0);
    
    failed=false; return ret;
  }
}
