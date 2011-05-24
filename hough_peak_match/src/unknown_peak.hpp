///\file
///\brief Declares UnknownPeak class

#ifndef HOUGH_PEAK_MATCH_UNKNOWN_PEAK
#define HOUGH_PEAK_MATCH_UNKNOWN_PEAK

#include "peak.hpp"

namespace HoughPeakMatch{

///A peak that has not been assigned a peak_group membership
class UnknownPeak:public Peak{  
protected:
  ///\brief Construct an uninitialized UnknownPeak
  UnknownPeak():Peak(){}
public:
  ///\brief Construct an unknown peak object
  ///
  ///\param sample_id the id of the sample that contains this peak
  ///
  ///\param peak_id a unique identifier for this peak within its sample
  ///
  ///\param ppm the location of this peak (in ppm)
  ///
  ///\throws invalid_argument if ppm is infinity or nan
  UnknownPeak(unsigned sample_id, unsigned peak_id, double ppm)
    :Peak(sample_id,peak_id,ppm,"HoughPeakMatch::UnknownPeak"){}

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
  static UnknownPeak from_text_line
  (const std::vector<std::string>& words, bool& failed);

  ///\brief Write this UnknownPeak to a new-line terminated string
  ///
  ///Returns the string representation of this UnknownPeak
  ///from \ref unknown_peak "the file format documentation"
  ///terminated with a newline
  ///
  ///\returns the string representation of this HumanVerifiedPeak from
  ///\ref unknown_peak "the file format documentation" terminated
  ///with a newline
  std::string to_text_line() const;

  virtual ObjectType type() const{
    return ObjectType("unknown_peak");
  }
};

}
#endif //HOUGH_PEAK_MATCH_UNKNOWN_PEAK
