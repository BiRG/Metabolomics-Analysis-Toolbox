///\file
///\brief Declares the HumanVerifiedPeak class

#ifndef HOUGH_PEAK_MATCH_HUMAN_VERIFIED_PEAK
#define HOUGH_PEAK_MATCH_HUMAN_VERIFIED_PEAK

#include "known_peak.hpp"

namespace HoughPeakMatch{

///A peak whose peak-group membership has been verified by a human being
class HumanVerifiedPeak:public KnownPeak{
public:
  virtual ~HumanVerifiedPeak(){}
};

}
#endif //HOUGH_PEAK_MATCH_HUMAN_VERIFIED_PEAK
