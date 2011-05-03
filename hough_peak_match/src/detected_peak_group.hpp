///\file
///\brief Declares the DetectedPeakGroup class

#ifndef HOUGH_PEAK_MATCH_DETECTED_PEAK_GROUP
#define HOUGH_PEAK_MATCH_DETECTED_PEAK_GROUP

#include "peak_group.hpp"

namespace HoughPeakMatch{

///A non-integrated peak group from a group detection algorithm

///A peak group output by a detection algorithm but not yet completely
///integrated with the rest of the database
class DetectedPeakGroup: public PeakGroup{
public:
  virtual ~DetectedPeakGroup(){}
};

}
#endif //HOUGH_PEAK_MATCH_DETECTED_PEAK_GROUP
