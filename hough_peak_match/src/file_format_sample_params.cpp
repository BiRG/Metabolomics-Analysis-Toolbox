#include "file_format_sample_params.hpp"
#include "utils.hpp"
#include "mockable_stringstream.hpp"
#include <cassert>

namespace HoughPeakMatch{
  FileFormatSampleParams FileFormatSampleParams::from_text_line
  (const std::vector<std::string>& words, bool& failed){
    FileFormatSampleParams ret;
    if(words.size() < 3){
      failed = true;  return ret; } 

    if(words.at(0) != "sample_params"){
      failed = true;  return ret; } 

    int sample_id_temp;
    std::istringstream sample_id_in(words.at(1));
    if(!(sample_id_in >> sample_id_temp)){
      failed = true; return ret; }
    if(sample_id_temp < 0){ 
      failed = true; return ret; }
    ret.sample_id_ = sample_id_temp;

    for(size_t i = 2; i < words.size(); ++i){
      double param_temp;
      std::istringstream param_in(words.at(i));
      if(!(param_in >> param_temp)) { 
	failed = true; return ret; }
      if(is_special_double(param_temp)) { 
	failed = true; return ret; }
      ret.params_.push_back(param_temp);
    }
    assert(ret.params().size() != 0);

    failed = false; return ret;
  }

  std::string FileFormatSampleParams::to_text_line() const{
    std::ostringstream out;
    out << "sample_params " << sample_id();
    for(std::vector<double>::const_iterator it = params_.begin();
	it != params_.end(); ++it){
      out << " " << *it;
    }
    out << std::endl;
    return out.str();
  }
}
