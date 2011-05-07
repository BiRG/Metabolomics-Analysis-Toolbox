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

  ///\brief Creates an UnknownPeak from a line in a database file
  ///
  ///Takes vector of words and creates an UnknownPeak from
  ///them.  If the words do not define an unknown_peak,
  ///returns nonsense and sets failed to true.  Otherwise, failed is
  ///set to false.
  ///
  ///\remark Assumes that the words follow the format for a
  ///\ref unknown_peak "unknown_peak line" in 
  ///\ref file_format_docs "the file format documentation."  
  ///That is, the first word is unknown_peak, the second,
  ///the sample id, etc.
  ///
  ///\param words a vector of words as strings describing the desired
  ///UnknownPeak
  ///
  ///\param failed will be set to true if the words could not be
  ///parsed as an UnknownPeak, it will be false otherwise
  ///
  ///\returns the peak described by the input line.  On failure,
  ///failed will be set to true and the returned peak will be
  ///nonsense.
  static UnknownPeak fromTextLine
  (const std::vector<std::string>& words, bool& failed);
};

}
#endif //HOUGH_PEAK_MATCH_UNKNOWN_PEAK
