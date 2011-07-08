#include "peak.hpp"
#include "utils.hpp"
#include "mockable_stringstream.hpp"
#include <stdexcept>
#include <sstream>

namespace HoughPeakMatch{
  Peak::Peak(unsigned sample_id, unsigned peak_id, double ppm, 
	     std::string report_errors_as)
    :sample_id_(sample_id),peak_id_(peak_id),ppm_(ppm){
    if(is_special_double(ppm)){
      std::ostringstream msg;
      msg << report_errors_as << " was passed an invalid ppm value: " 
	  << ppm;
      throw std::invalid_argument(msg.str());
    }
  }


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
