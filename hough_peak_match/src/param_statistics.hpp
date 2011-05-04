///\file
///\brief Declares the ParamStatistics class

#ifndef HOUGH_PEAK_MATCH_PARAM_STATISTICS
#define HOUGH_PEAK_MATCH_PARAM_STATISTICS

namespace HoughPeakMatch{

///Statistics describing the global sample parameters 

///Statistics describing each of the global parameters affecting
///shifts within a sample.  Includes the fraction of the global
///variance accounted for by each parameter.
class ParamStatistics{
public:
  virtual ~ParamStatistics(){}
};

}
#endif //HOUGH_PEAK_MATCH_PARAM_STATISTICS
