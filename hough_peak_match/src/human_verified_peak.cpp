#include "utils.hpp"
#include "human_verified_peak.hpp"
#include <cassert>
#include <cstdlib>
#include <sstream>

namespace HoughPeakMatch{
  HumanVerifiedPeak HumanVerifiedPeak::from_text_line
  (const std::vector<std::string>& words, bool& failed){
    failed = true;
    HumanVerifiedPeak ret;
    if(words.size() != 5){ 
      failed = true;  return ret; } 
    ret.initFrom(words, "human_verified_peak", failed);
    return ret;

    failed=false; return ret;
  }
}
