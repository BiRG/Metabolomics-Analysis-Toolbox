///\file
///\brief Declares the ParameterizedPeakGroup class

#ifndef HOUGH_PEAK_MATCH_PARAMETERIZED_PEAK_GROUP
#define HOUGH_PEAK_MATCH_PARAMETERIZED_PEAK_GROUP

#include "peak_group.hpp"

namespace HoughPeakMatch{

///A peak group for which the parameters have been discovered
class ParameterizedPeakGroup:public PeakGroup{
public:
  virtual ~ParameterizedPeakGroup(){}
};

}
#endif //HOUGH_PEAK_MATCH_PARAMETERIZED_PEAK_GROUP
