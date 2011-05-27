///\file
///\brief Declares the KnownPeak class

#ifndef HOUGH_PEAK_MATCH_KNOWN_PEAK
#define HOUGH_PEAK_MATCH_KNOWN_PEAK

#include "peak.hpp"
#include <vector>
#include <string>

namespace HoughPeakMatch{

///A peak that has been assigned a peak_group membership
class KnownPeak:public Peak{
protected:
  ///\brief A non-negative identifier uniquely identifying the peak
  ///\brief group to which this peak belongs
  unsigned peak_group_id_;
  
  ///\brief Construct an uninitialized KnownPeak
  KnownPeak():peak_group_id_(){}

  ///\brief Sets the variables in this known peak from a database line
  ///
  ///Takes vector of words and initializes the variables in this known
  ///peak from them.  The first word must be identical to the contents
  ///of expected_name.  The subsequent words must hold textual
  ///representations of sample_id, peak_id, ppm, and peak_group_id
  ///
  ///If the words do not fit the specified format, the state variables
  ///are left as nonsense and failed is set to true.  Otherwise,
  ///failed is set to false.
  ///
  ///\param words a vector of words as strings in the appropriate
  ///format
  ///
  ///\param expected_name the expected line_type value from the file
  ///format.  It should correspond to the KnownPeak subclass being
  ///instantiated.
  ///
  ///\param failed will be set to true if the words could not be
  ///parsed as a KnownPeak, it will be false otherwise
  virtual void initFrom(const std::vector<std::string>& words, 
			const std::string& expected_name, 
			bool& failed);
public:
  ///\brief Construct a known peak object
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
  ///\param report_errors_as the name of the class to report any
  ///errors as -- useful when being called from subclasses
  ///
  ///\throws invalid_argument if ppm is infinity or nan
  KnownPeak(unsigned sample_id, unsigned peak_id, double ppm,
	    unsigned peak_group_id, std::string report_errors_as)
    :Peak(sample_id, peak_id, ppm, report_errors_as), 
     peak_group_id_(peak_group_id){}


  virtual ~KnownPeak(){}

  ///\brief Return the id of the peak group to which this peak belongs
  ///
  ///\return the id of the peak group to which this peak belongs
  virtual unsigned peak_group_id() const { return peak_group_id_; }

  virtual std::vector<KeySptr> foreign_keys(const PeakMatchingDatabase& db);

};

}
#endif //HOUGH_PEAK_MATCH_KNOWN_PEAK
