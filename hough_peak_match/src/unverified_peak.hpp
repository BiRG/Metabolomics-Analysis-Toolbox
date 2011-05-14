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
protected:
  ///\brief Construct an uninitialized UnverifiedPeak
  UnverifiedPeak():KnownPeak(){}
public:
  ///\brief Construct an unverified peak object
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
  UnverifiedPeak(unsigned sample_id, unsigned peak_id, double ppm,
		unsigned peak_group_id)
    :KnownPeak(sample_id,peak_id,ppm,peak_group_id,
	       "HoughPeakMatch::UnverifiedPeak"){}

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
  static UnverifiedPeak from_text_line
  (const std::vector<std::string>& words, bool& failed);

  ///\brief Write this UnverifiedPeak to a new-line terminated string
  ///
  ///Returns the string representation of this UnverifiedPeak
  ///from \ref unverified_peak "the file format documentation"
  ///terminated with a newline
  ///
  ///\returns the string representation of this UnverifiedPeak from
  ///\ref unverified_peak "the file format documentation" terminated
  ///with a newline
  std::string to_text_line();
};

}
#endif //HOUGH_PEAK_MATCH_UNVERIFIED_PEAK
