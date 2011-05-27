#include "key.hpp"
#include "param_stats.hpp"
#include "utils.hpp"
#include "mockable_stringstream.hpp"
#include <cassert>

namespace HoughPeakMatch{

ParamStats ParamStats::from_text_line
  (const std::vector<std::string>& words, bool& failed){
    ParamStats ret;
    if(words.size() < 2){
      failed = true; return ret; }

    if(words.at(0) != "param_stats"){
      failed = true; return ret; }

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
      failed = true; return ret; }

    failed = false; return ret;
  }

std::string ParamStats::to_text() const{
  std::ostringstream out;
  out << "param_stats";
  for(std::vector<double>::const_iterator it = frac_variances_.begin();
      it != frac_variances_.end(); ++it){
    out << " " << *it;
  }
  out << std::endl;
  return out.str();
}

std::vector<KeySptr> 
ParamStats::foreign_keys(const PeakMatchingDatabase&) const{
  return std::vector<KeySptr>();
}

}
