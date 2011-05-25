///\file
///\brief Declares the UnparameterizedSample class

#ifndef HOUGH_PEAK_MATCH_UNPARAMETERIZED_SAMPLE
#define HOUGH_PEAK_MATCH_UNPARAMETERIZED_SAMPLE

#include "sample.hpp"
#include <vector>
#include <string>

namespace HoughPeakMatch{

///\brief An NMR measurement of a sample with no parameters 
///
///An NMR measurement of a sample from a particular experimental class
///or treatment that has not had sample parameters assigned
  class UnparameterizedSample:public Sample{
public:
  ///\brief Construct an unparameterized sample object
  ///
  ///\param sample_id the id of this sample
  ///
  ///\param sample_class a string giving the experimental class of this sample
  ///
  ///\throws invalid_argument if class is the empty string or contains
  ///white-space
  ///
  ///\todo test
  UnparameterizedSample(unsigned sample_id, std::string sample_class)
    :Sample(sample_id, sample_class){}

  ///\brief Write this UnparameterizedSample to a new-line terminated string
  ///
  ///Returns the string representation of this UnparameterizedSample
  ///from \ref sample "the file format documentation"
  ///terminated with a newline
  ///
  ///\returns the string representation of this UnparameterizedSample from
  ///\ref sample "the file format documentation" terminated
  ///with a newline
  ///
  ///\todo test
  virtual std::string to_text_line() const;

  virtual ObjectType type() const{
    return ObjectType("unparameterized_sample");
  }

  virtual bool has_same_non_key_parameters(const PMObject* o) const{
    ///\todo test
    if(o == NULL){ 
      return false; }
    if(o->type() != type()){ 
      return false; }
    const UnparameterizedSample* s = 
      dynamic_cast<const UnparameterizedSample*>(o);
    return s->sample_class() == sample_class();
  }

};

}
#endif //HOUGH_PEAK_MATCH_UNPARAMETERIZED_SAMPLE
