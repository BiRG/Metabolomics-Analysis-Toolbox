///\file
///\brief Declares the HumanVerifiedPeak class

#ifndef HOUGH_PEAK_MATCH_HUMAN_VERIFIED_PEAK
#define HOUGH_PEAK_MATCH_HUMAN_VERIFIED_PEAK

#include "known_peak.hpp"

namespace HoughPeakMatch{

///A peak whose peak-group membership has been verified by a human being
class HumanVerifiedPeak:public KnownPeak{
protected:
  ///\brief Construct an uninitialized human-verified peak object
  HumanVerifiedPeak():KnownPeak(){}
public:
  ///\brief Construct a human-verified peak object
  ///
  ///\param sample_id the id of the sample that contains this peak
  ///
  ///\param peak_id a unique identifier for this peak within its sample
  ///
  ///\param ppm the location of this peak (in ppm)
  ///
  ///\param peak_group_id the identifier of the peak_group to which
  ///this peak belongs
  ///
  ///\throws invalid_argument if ppm is infinity or nan
  HumanVerifiedPeak(unsigned sample_id, unsigned peak_id, double ppm,
		    unsigned peak_group_id)
    :KnownPeak(sample_id,peak_id,ppm,peak_group_id,
	       "HoughPeakMatch::HumanVerifiedPeak"){}

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
  ///\returns the peak described by the input line.  On failure,
  ///failed will be set to true and the returned peak will be
  ///nonsense.
  static HumanVerifiedPeak from_text_line
  (const std::vector<std::string>& words, bool& failed);


  ///\brief Write this HumanVerifiedPeak to a new-line terminated string
  ///
  ///Returns the string representation of this HumanVerifiedPeak
  ///from \ref file_format_docs "the file format documentation"
  ///terminated with a newline
  ///
  ///\returns the string representation of this HumanVerifiedPeak from
  ///\ref file_format_docs "the file format documentation" terminated
  ///with a newline
  std::string to_text_line();
};

}
#endif //HOUGH_PEAK_MATCH_HUMAN_VERIFIED_PEAK
