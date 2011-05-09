#include "peak.hpp"
#include "utils.hpp"
#include <sstream>

namespace HoughPeakMatch{
  void Peak::initFrom(const std::vector<std::string>& words, 
		      const std::string& expected_name, 
		      bool& failed){
    if(words.size() < 4){ 
      failed = true;  return; } 

    if(words.at(0) != expected_name){
      failed = true; return; }

    int sample_id_temp;
    std::istringstream sample_id_in(words.at(1));
    if(!(sample_id_in >> sample_id_temp)){
      failed = true; return; }
    if(sample_id_temp < 0){ 
      failed = true; return; }
    sample_id_ = sample_id_temp;

    int peak_id_temp;
    std::istringstream peak_id_in(words.at(2));
    if(!(peak_id_in >> peak_id_temp)){
      failed = true; return; }
    if(peak_id_temp < 0){ 
      failed = true; return; }
    peak_id_ = peak_id_temp;

    std::istringstream ppm_in(words.at(3));
    if(!(ppm_in >> ppm_)) { 
      failed = true; return; }
    if(is_special_double(ppm_)) { 
      failed = true; return; }

    failed = false; return;
  }
}
