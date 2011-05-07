#include "utils.hpp"
#include "unverified_peak.hpp"
#include <cassert>
#include <cstdlib>
#include <sstream>

namespace HoughPeakMatch{
  UnverifiedPeak UnverifiedPeak::fromTextLine
  (const std::vector<std::string>& words, bool& failed){
    failed = true;
    UnverifiedPeak ret;
    if(words.size() != 5){ 
      failed = true;  return ret; } 
    ret.initFrom(words, "unverified_peak", failed);
    return ret;

    failed=false; return ret;
  }
}
