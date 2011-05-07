///\file
///\brief Declares the UnverifiedPeak class

#ifndef HOUGH_PEAK_MATCH_UNVERIFIED_PEAK
#define HOUGH_PEAK_MATCH_UNVERIFIED_PEAK

#include "known_peak.hpp"

namespace HoughPeakMatch{

///\brief A peak with unverified peak_group membership
///
///A peak that has been assigned a peak_group membership but that
///membership has not verified by other means
class UnverifiedPeak:public KnownPeak{
public:
  virtual ~UnverifiedPeak(){};

  ///\brief Creates a UnverifiedPeak from a line in a database file
  ///
  ///Takes vector of words and creates a UnverifiedPeak from
  ///them.  If the words do not define a unverified_peak,
  ///returns nonsense and sets failed to true.  Otherwise, failed is
  ///set to false.
  ///
  ///\remark Assumes that the words follow the format for a
  ///\ref unverified_peak "unverified_peak line" in 
  ///\ref file_format_docs "the file format documentation."  
  ///That is, the first word is unverified_peak, the second,
  ///the sample id, etc.
  ///
  ///\param words a vector of words as strings describing the desired
  ///UnverifiedPeak
  ///
  ///\param failed will be set to true if the words could not be
  ///parsed as a UnverifiedPeak, it will be false otherwise
  ///
  ///\returns the peak described by the input line.  On failure,
  ///failed will be set to true and the returned peak will be
  ///nonsense.
  static UnverifiedPeak fromTextLine
  (const std::vector<std::string>& words, bool& failed);

};

}
#endif //HOUGH_PEAK_MATCH_UNVERIFIED_PEAK
