///\file
///\brief Declares UnknownPeak class

#ifndef HOUGH_PEAK_MATCH_UNKNOWN_PEAK
#define HOUGH_PEAK_MATCH_UNKNOWN_PEAK

#include "peak.hpp"

namespace HoughPeakMatch{

///A peak that has not been assigned a peak_group membership
class UnknownPeak:public Peak{
public:
  virtual ~UnknownPeak(){}
};

}
#endif //HOUGH_PEAK_MATCH_UNKNOWN_PEAK
