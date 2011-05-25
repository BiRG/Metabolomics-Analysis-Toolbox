#include "utils.hpp"
#include "unverified_peak.hpp"
#include <cassert>
#include <cstdlib>
#include "mockable_stringstream.hpp"

namespace HoughPeakMatch{
  UnverifiedPeak UnverifiedPeak::from_text_line
  (const std::vector<std::string>& words, bool& failed){
    failed = true;
    UnverifiedPeak ret;
    if(words.size() != 5){ 
      failed = true;  return ret; } 
    ret.initFrom(words, "unverified_peak", failed);
    return ret;

    failed=false; return ret;
  }

  std::string UnverifiedPeak::to_text() const{
    std::ostringstream out;
    out << "unverified_peak" << " " << sample_id() 
	<< " " << peak_id() << " " << ppm() << " " << peak_group_id() 
	<< std::endl;
    return out.str();
  }

}
