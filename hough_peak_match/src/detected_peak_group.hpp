///\file
///\brief Declares the DetectedPeakGroup class

#ifndef HOUGH_PEAK_MATCH_DETECTED_PEAK_GROUP
#define HOUGH_PEAK_MATCH_DETECTED_PEAK_GROUP

#include "peak_group.hpp"

namespace HoughPeakMatch{

///\brief A non-integrated peak group from a group detection algorithm
///
///A peak group output by a detection algorithm but not yet completely
///integrated with the rest of the database
class DetectedPeakGroup: public PeakGroup{
  ///\brief The base location of the peak group
  double ppm_;

  ///\brief The parameter vector governing the shifts in this peak-group
  std::vector<double> params_;

  ///\brief Create an uninitialized DetectedPeakGroup
  DetectedPeakGroup():ppm_(),params_(){};
public:
  virtual ~DetectedPeakGroup(){}

  ///\brief Creates a DetectedPeakGroup from a line in a database file
  ///
  ///Takes vector of words and creates a DetectedPeakGroup from
  ///them.  If the words do not define a detected_peak_group,
  ///returns nonsense and sets failed to true.  Otherwise, failed is
  ///set to false.
  ///
  ///\remark Assumes that the words follow the format for a
  ///\ref detected_peak_group "detected_peak_group line" in 
  ///\ref file_format_docs "the file format documentation."  
  ///That is, the first word is detected_peak_group, the second,
  ///the peak group id, etc.
  ///
  ///\param words a vector of words as strings describing the desired
  ///DetectedPeakGroup
  ///
  ///\param failed will be set to true if the words could not be
  ///parsed as a DetectedPeakGroup, it will be false otherwise
  ///
  ///\returns the peak group described by the input line.  On failure,
  ///failed will be set to true and the returned peak group will be
  ///nonsense.
  ///
  ///\todo refactor this to combine it with the detected_peak_group
  ///reading - they're almost identical
  static DetectedPeakGroup fromTextLine
  (const std::vector<std::string>& words, bool& failed);

  
  ///\brief Return the parameters for this DetectedPeakGroup
  ///
  ///\return the parameters for this DetectedPeakGroup
  const std::vector<double>& params() const{ return params_; }

  ///\brief Return the ppm location for this DetectedPeakGroup
  ///
  ///\return the ppm location for this DetectedPeakGroup
  double ppm() const{ return ppm_; }
};

}
#endif //HOUGH_PEAK_MATCH_DETECTED_PEAK_GROUP
