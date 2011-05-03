///\file
///\brief Declares the SampleParams class

#ifndef HOUGH_PEAK_MATCH_SAMPLE_PARAMS
#define HOUGH_PEAK_MATCH_SAMPLE_PARAMS

namespace HoughPeakMatch{

///Global parameters for a given sample.

///Parameters that describe the latent global factors in a given
///sample to which individual nulei respond by shifting in various
///ways.
class SampleParams{
public:
  virtual ~SampleParams(){}
};

}
#endif //HOUGH_PEAK_MATCH_SAMPLE_PARAMS
