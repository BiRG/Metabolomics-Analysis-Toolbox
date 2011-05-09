///\file
///\brief Declares the ParameterizedPeakGroup class

#ifndef HOUGH_PEAK_MATCH_PARAMETERIZED_PEAK_GROUP
#define HOUGH_PEAK_MATCH_PARAMETERIZED_PEAK_GROUP

#include "peak_group.hpp"
#include <vector>
#include <string>

namespace HoughPeakMatch{

///A peak group for which the parameters have been discovered
class ParameterizedPeakGroup:public PeakGroup{
protected:
  ///\brief The base location of the peak group
  double ppm_;

  ///\brief The parameter vector governing the shifts in this peak-group
  std::vector<double> params_;

  ///\brief Create an uninitialized ParameterizedPeakGroup
  ParameterizedPeakGroup():ppm_(),params_(){};
public:
  friend class PeakMatchingDatabase;

  virtual ~ParameterizedPeakGroup(){}

  ///\brief Creates a ParameterizedPeakGroup from a line in a database file
  ///
  ///Takes vector of words and creates a ParameterizedPeakGroup from
  ///them.  If the words do not define a parameterized_peak_group,
  ///returns nonsense and sets failed to true.  Otherwise, failed is
  ///set to false.
  ///
  ///\remark Assumes that the words follow the format for a
  ///\ref parameterized_peak_group "parameterized_peak_group line" in 
  ///\ref file_format_docs "the file format documentation."  
  ///That is, the first word is parameterized_peak_group, the second,
  ///the peak group id, etc.
  ///
  ///\param words a vector of words as strings describing the desired
  ///ParameterizedPeakGroup
  ///
  ///\param failed will be set to true if the words could not be
  ///parsed as a ParameterizedPeakGroup, it will be false otherwise
  ///
  ///\returns the peak group described by the input line.  On failure,
  ///failed will be set to true and the returned peak group will be
  ///nonsense.
  ///
  ///\todo refactor this to combine it with the detected_peak_group
  ///reading - they're almost identical
  static ParameterizedPeakGroup from_text_line
  (const std::vector<std::string>& words, bool& failed);

  
  ///\brief Return the parameters for this ParameterizedPeakGroup
  ///
  ///\return the parameters for this ParameterizedPeakGroup
  const std::vector<double>& params() const{ return params_; }

  ///\brief Return the ppm location for this ParameterizedPeakGroup
  ///
  ///\return the ppm location for this ParameterizedPeakGroup
  double ppm() const{ return ppm_; }

};



}
#endif //HOUGH_PEAK_MATCH_PARAMETERIZED_PEAK_GROUP
