#include "sample.hpp"
#include "mockable_stringstream.hpp"

namespace HoughPeakMatch{
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
    ret.sample_class_ = words.at(2);

    failed = false; return ret;
  }
}
