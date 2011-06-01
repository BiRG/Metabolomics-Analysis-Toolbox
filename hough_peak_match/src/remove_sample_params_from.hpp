#ifndef HOUGH_PEAK_MATCH_REMOVE_SAMPLE_PARAMS_FROM_HPP
#define HOUGH_PEAK_MATCH_REMOVE_SAMPLE_PARAMS_FROM_HPP
namespace HoughPeakMatch{
  class PeakMatchingDatabase;

  ///\brief Changes all ParameterizedSample objects into
  ///UnparameterizedSample objects
  ///
  ///\param db The database to change
  void remove_sample_params_from(PeakMatchingDatabase& db);
}

#endif //HOUGH_PEAK_MATCH_REMOVE_SAMPLE_PARAMS_FROM_HPP
