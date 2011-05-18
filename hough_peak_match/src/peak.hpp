///\file
///\brief Declares the Peak class

#ifndef HOUGH_PEAK_MATCH_PEAK
#define HOUGH_PEAK_MATCH_PEAK

#include <utility> //For pair, make_pair
#include <vector>
#include <string>
#include <iostream> //For debugging

namespace HoughPeakMatch{

///\brief A peak detected in a sample with a maximum at a certain location
class Peak{
protected:
  ///\brief non-negative integer uniquely identifying the sample to
  ///\brief which this peak belongs
  unsigned sample_id_;

  ///\brief non-negative integer uniquely identifying this peak within
  ///\brief all peaks belonging to its sample
  unsigned peak_id_;

  ///\brief the measured location of this peak within the sample in ppm
  double ppm_;

  ///\brief Construct an uninitialized Peak
  Peak():sample_id_(),peak_id_(),ppm_(){}


  ///\brief Sets the variables in this peak from a database line
  ///
  ///Takes vector of words and initializes the variables in this peak
  ///from them.  The first word must be identical to the contents of
  ///expected_name.  The subsequent words must hold textual
  ///representations of sample_id, peak_id, and ppm
  ///
  ///If the words do not fit the specified format, the state variables
  ///are left as nonsense and failed is set to true.  Otherwise,
  ///failed is set to false.
  ///
  ///\param words a vector of words as strings in the appropriate
  ///format
  ///
  ///\param expected_name the expected line_type value from the file
  ///format.  It should correspond to the Peak subclass being
  ///instantiated.
  ///
  ///\param failed will be set to true if the words could not be
  ///parsed as a Peak, it will be false otherwise
  virtual void initFrom(const std::vector<std::string>& words, 
			const std::string& expected_name, 
			bool& failed);
public:
  ///\brief Construct a Peak object
  ///
  ///\param sample_id the id of the sample that contains this peak
  ///
  ///\param peak_id a unique identifier for this peak within its sample
  ///
  ///\param ppm the location of this peak (in ppm)
  ///
  ///\param report_errors_as the name of the class to report any
  ///errors as -- useful when being called from subclasses
  ///
  ///\throws invalid_argument if ppm is infinity or nan
  Peak(unsigned sample_id, unsigned peak_id, double ppm, 
       std::string report_errors_as);


  virtual ~Peak(){}

  ///\brief Return the id of the sample to which this peak belongs.
  ///
  ///\return the id of the sample to which this peak belongs.
  virtual unsigned sample_id() const{ 
    //    std::cerr << "Peak::sample_id() called\n";
    return sample_id_; }

  ///\brief Return the id of this peak within its sample
  ///
  ///\return the id of this peak within its sample
  virtual unsigned peak_id() const{ return peak_id_; }

  ///\brief Return the location of this peak in ppm
  ///
  ///\return the location of this peak in ppm
  virtual double ppm() const{ return ppm_; }

  ///\brief Return a pair containing the sample_id and peak_id
  ///
  ///The pair sample_id,peak_id represents the primary key for any
  ///peak.
  ///
  ///\return  a pair containing the sample_id and peak_id
  virtual std::pair<unsigned, unsigned> id() const{ 
    return std::make_pair(sample_id(),peak_id());
  }
};

}
#endif //HOUGH_PEAK_MATCH_PEAK
