#include "sample.hpp"
#include "mockable_stringstream.hpp"
#include "utils.hpp"
#include <stdexcept>

namespace HoughPeakMatch{
  
  Sample::Sample(unsigned sample_id, std::string sample_class)
    :sample_id_(sample_id),sample_class_(sample_class){
    if(this->sample_class().size() == 0){
      throw std::invalid_argument("HoughPeakMatch::Sample received an "
				  "empty string for a sample class");
    }
    if(contains_white_space(this->sample_class())){
      throw std::invalid_argument("HoughPeakMatch::Sample received a "
			     "string containing white-space for "
			     "a sample class");
    }
  }


  Sample Sample::from_text_line
  (const std::vector<std::string>& words, bool& failed){
    Sample ret;
    if(words.size() != 3){
      failed = true;  return ret; } 

    if(words.at(0) != "sample"){
      failed = true;  return ret; } 

    int sample_id_temp;
    std::istringstream sample_id_in(words.at(1));
    if(!(sample_id_in >> sample_id_temp)){
      failed = true; return ret; }
    if(sample_id_temp < 0){ 
      failed = true; return ret; }
    ret.sample_id_ = sample_id_temp;

    if(words.at(2) == ""){
      failed = true; return ret; }
    if(contains_white_space(words.at(2))){
      failed = true; return ret; }
    ret.sample_class_ = words.at(2);

    failed = false; return ret;
  }
  
  std::string Sample::to_text_line() const{
    std::ostringstream out;
    out << "sample " << id() << " " << sample_class() << std::endl;
    return out.str();
  }
}
