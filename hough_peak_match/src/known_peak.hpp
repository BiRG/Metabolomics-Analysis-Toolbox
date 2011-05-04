///\file
///\brief Declares the KnownPeak class

#ifndef HOUGH_PEAK_MATCH_KNOWN_PEAK
#define HOUGH_PEAK_MATCH_KNOWN_PEAK

#include "peak.hpp"

namespace HoughPeakMatch{

///A peak that has been assigned a peak_group membership
class KnownPeak:public Peak{
public:
  virtual ~KnownPeak(){}
};

}
#endif //HOUGH_PEAK_MATCH_KNOWN_PEAK
