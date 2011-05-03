///\file
///\brief Declares the UnverifiedPeak class

#ifndef HOUGH_PEAK_MATCH_UNVERIFIED_PEAK
#define HOUGH_PEAK_MATCH_UNVERIFIED_PEAK

#include "known_peak.hpp"

namespace HoughPeakMatch{

///A peak with unverified peak_group membership

///A peak that has been assigned a peak_group membership but that
///membership has not verified by other means
class UnverifiedPeak:public KnownPeak{
public:
  virtual ~UnverifiedPeak(){};
};

}
#endif //HOUGH_PEAK_MATCH_UNVERIFIED_PEAK
