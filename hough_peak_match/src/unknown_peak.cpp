#include "utils.hpp"
#include "unknown_peak.hpp"
#include <cassert>
#include <cstdlib>
#include "mockable_stringstream.hpp"

namespace HoughPeakMatch{
  UnknownPeak UnknownPeak::from_text_line
  (const std::vector<std::string>& words, bool& failed){
    failed = true;
    UnknownPeak ret;
    if(words.size() != 4){ 
      failed = true;  return ret; } 
    ret.initFrom(words, "unknown_peak", failed);
    return ret;
  }

  std::string UnknownPeak::to_text() const{
    std::ostringstream out;
    out << "unknown_peak" << " " << sample_id() << " " 
	<< peak_id() << " " << ppm() << std::endl;
    return out.str();
  }

}
