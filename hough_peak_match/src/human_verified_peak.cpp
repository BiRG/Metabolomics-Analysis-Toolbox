#include "utils.hpp"
#include "human_verified_peak.hpp"
#include <cassert>
#include <cstdlib>
#include "mockable_stringstream.hpp"

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

  std::string HumanVerifiedPeak::to_text_line() const{
    using namespace std;;
    ostringstream o;
    o << "human_verified_peak " 
      << sample_id() << " " 
      << peak_id() << " " 
      << ppm() << " " 
      << peak_group_id() << endl;
    return o.str();
  }

}
