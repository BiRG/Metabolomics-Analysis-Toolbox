#include "param_stats.hpp"
#include "utils.hpp"
#include <sstream>
#include <cassert>

namespace HoughPeakMatch{
  ParamStats ParamStats::fromTextLine
  (const std::vector<std::string>& words, bool& failed){
    ParamStats ret;
    if(words.size() < 2){
      failed = true;  return ret; } 

    if(words.at(0) != "param_stats"){
      failed = true;  return ret; } 

    double fracvar_sum = 0;
    for(size_t i = 1; i < words.size(); ++i){
      double fracvar_temp;
      std::istringstream fracvar_in(words.at(i));
      if(!(fracvar_in >> fracvar_temp)) { 
	failed = true; return ret; }
      if(is_special_double(fracvar_temp)) { 
	failed = true; return ret; }
      if(fracvar_temp < 0){
	failed = true; return ret; }
      ret.frac_variances_.push_back(fracvar_temp);
      fracvar_sum += fracvar_temp;
    }
    assert(ret.frac_variances().size() != 0);

    if(fracvar_sum > 1){
      failed = true;  return ret; } 

    failed = false; return ret;
  }
}
