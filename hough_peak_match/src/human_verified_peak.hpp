///\file
///\brief Declares the HumanVerifiedPeak class

#ifndef HOUGH_PEAK_MATCH_HUMAN_VERIFIED_PEAK
#define HOUGH_PEAK_MATCH_HUMAN_VERIFIED_PEAK

#include "known_peak.hpp"

namespace HoughPeakMatch{

///A peak whose peak-group membership has been verified by a human being
class HumanVerifiedPeak:public KnownPeak{
public:
  virtual ~HumanVerifiedPeak(){}

  ///\brief Creates a HumanVerifiedPeak from a line in a database file
  ///
  ///Takes vector of words and creates a HumanVerifiedPeak from
  ///them.  If the words do not define a human_verified_peak,
  ///returns nonsense and sets failed to true.  Otherwise, failed is
  ///set to false.
  ///
  ///\remark Assumes that the words follow the format for a
  ///\ref human_verified_peak "human_verified_peak line" in 
  ///\ref file_format_docs "the file format documentation."  
  ///That is, the first word is human_verified_peak, the second,
  ///the sample id, etc.
  ///
  ///\param words a vector of words as strings describing the desired
  ///HumanVerifiedPeak
  ///
  ///\param failed will be set to true if the words could not be
  ///parsed as a HumanVerifiedPeak, it will be false otherwise
  ///
  ///\returns the peak group described by the input line.  On failure,
  ///failed will be set to true and the returned peak group will be
  ///nonsense.
  static HumanVerifiedPeak fromTextLine
  (const std::vector<std::string>& words, bool& failed);

};

}
#endif //HOUGH_PEAK_MATCH_HUMAN_VERIFIED_PEAK
