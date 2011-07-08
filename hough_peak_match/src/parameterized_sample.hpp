///\file
///\brief Declares the ParameterizedSample class

#ifndef HOUGH_PEAK_MATCH_PARAMETERIZED_SAMPLE
#define HOUGH_PEAK_MATCH_PARAMETERIZED_SAMPLE

#include "no_params_exception.hpp"
#include "unparameterized_sample.hpp"
#include "sample.hpp"
#include <vector>
#include <string>

namespace HoughPeakMatch{

///\brief An NMR measurement of a sample with parameters 
///
///An NMR measurement of a sample from a particular experimental class
///or treatment that has had sample shift parameters assigned
class ParameterizedSample:public Sample{
protected:
  ///\brief The parameter vector governing the shifts in this sample
  std::vector<double> params_;
public:
  ///\brief Construct a parameterized sample object
  ///
  ///\param sample_id the id of this sample
  ///
  ///\param sample_class a string giving the experimental class of this sample
  ///
  ///\param param_begin an iterator to the first in the sequence of
  ///shift-governing parameters
  ///
  ///\param param_end an iterator to one-past-the-end of the sequence of
  ///shift-governing parameters
  ///
  ///\throws invalid_argument if class is the empty string or contains
  ///white-space
  ///
  ///\throws HoughPeakMatch::no_params_exception if the passed
  ///sequence of parameters is empty
  ///
  ///\todo test
  template<class InputIter>
  ParameterizedSample(unsigned sample_id, std::string sample_class,
		      InputIter param_begin, InputIter param_end)
    :Sample(sample_id, sample_class),params_(param_begin, param_end){
    if(params().size() == 0){
      throw no_params_exception("HoughPeakMatch::ParameterizedSample");
    }
  }

  ///\brief Return the parameters for this ParameterizedSample
  ///
  ///\return the parameters for this ParameterizedSample
  const std::vector<double>& params() const{ return params_; }

  ///\brief Set the parameters for this ParameterizedSample
  ///
  ///\param params the new parameter values
  void set_params(const std::vector<double>& params){ params_=params; }



  ///\brief Return a copy of this Sample object without the parameters
  ///
  ///\warning The returned copy will have the same id, so if it is
  ///inserted into the same database then the original should be
  ///removed -- otherwise the id will no longer uniquely identify the
  ///sample.
  //
  ///\return A copy of this Sample object without the parameters
  UnparameterizedSample without_params() const{
    return UnparameterizedSample(id(), sample_class());
  }

  ///\brief A total ordering on ParameterizedSamples; returns true iff
  ///*this < \a rhs
  ///
  ///\param rhs The right-hand-side of the less-than operator
  ///
  ///\return true iff *this < \a rhs
  bool operator<(const ParameterizedSample& rhs) const{
    return 
      (id() < rhs.id()) ||
      (id() == rhs.id() && sample_class() < rhs.sample_class()) ||
      (id() == rhs.id() && sample_class() == rhs.sample_class() &&
       params() < rhs.params());
  }
  

  ///\brief Write this ParameterizedSample to a new-line terminated string
  ///
  ///Returns the string representation of this ParameterizedSample
  ///from \ref sample "the file format documentation" terminated with
  ///a newline.  Note that this will contain TWO lines: one for the
  ///sample object and one for the sample_params object
  ///
  ///\returns the string representation of this ParameterizedSample
  ///from \ref sample "the file format documentation" terminated with
  ///a newline
  ///
  ///\todo test
  virtual std::string to_text() const;

  virtual ObjectType type() const{
    return ObjectType("parameterized_sample");
  }

  virtual bool has_same_non_key_parameters(const PMObject* o) const{
    ///\todo test
    if(o == NULL){ 
      return false; }
    if(o->type() != type()){ 
      return false; }
    const ParameterizedSample* s = 
      dynamic_cast<const ParameterizedSample*>(o);
    return 
      s->sample_class() == sample_class() && 
      s->params() == params();
  }

};

}
#endif //HOUGH_PEAK_MATCH_PARAMETERIZED_SAMPLE
