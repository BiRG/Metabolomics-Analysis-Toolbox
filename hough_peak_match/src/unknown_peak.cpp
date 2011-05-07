#include "utils.hpp"
#include "unknown_peak.hpp"
#include <cassert>
#include <cstdlib>
#include <sstream>

namespace HoughPeakMatch{
  UnknownPeak UnknownPeak::fromTextLine
  (const std::vector<std::string>& words, bool& failed){
    failed = true;
    UnknownPeak ret;
    if(words.size() != 4){ 
      failed = true;  return ret; } 
    ret.initFrom(words, "unknown_peak", failed);
    return ret;
  }
}
