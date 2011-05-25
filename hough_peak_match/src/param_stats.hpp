///\file
///\brief Declares the ParamStats class

#ifndef HOUGH_PEAK_MATCH_PARAM_STATS
#define HOUGH_PEAK_MATCH_PARAM_STATS

#include "pmobject.hpp"
#include "no_params_exception.hpp"
#include "object_type.hpp"
#include <string>
#include <vector>
#include <numeric>

namespace HoughPeakMatch{

///Statistics describing the global sample parameters 

///Statistics describing each of the global parameters affecting
///shifts within a sample.  Includes the fraction of the global
///variance accounted for by each parameter.
///
///There should be at most one of these in the database
class ParamStats:public PMObject{
  ///\brief Vector where element i holds the fraction of the variance
  ///\brief accounted for by parameter pair i in the database
  std::vector<double> frac_variances_;

  ///\brief Construct an uninitialized ParamStats object
  ParamStats():frac_variances_(){}
public:
  ///\brief Construct a ParamStats with the given members
  ///
  ///\param param_begin an iterator to the first in the sequence of
  ///shift-governing parameters
  ///
  ///\param param_end an iterator to one-past-the-end of the sequence of
  ///shift-governing parameters
  ///
  ///\throws HoughPeakMatch::no_params_exception if the passed
  ///sequence of parameters is empty
  template<class InputIter>
  ParamStats(InputIter param_begin, InputIter param_end):
    frac_variances_(param_begin, param_end){
    if(frac_variances().size() == 0){
      throw no_params_exception("HoughPeakMatch::ParamStats");
    }else if(std::accumulate
	     (frac_variances_.begin(), frac_variances_.end(), 0.0) > 1){
      throw std::invalid_argument
	("HoughPeakMatch::ParamStats received fractions of total variance "
	 "totalling to more than 1.");
    }
  }

  virtual ~ParamStats(){}

  ///\brief Returns a vector giving the fraction of the total variance
  ///\brief covered by each parameter in the database
  ////
  ///\returns a vector giving the fraction of the total variance 
  ///covered by each parameter in the database
  const std::vector<double>& frac_variances() const { 
    return frac_variances_; }

  ///\brief Creates a ParamStats object from a line in a database
  ///\brief file
  ///
  ///Takes vector of words and creates a ParamStats object from
  ///them.  If the words do not define a ParamStats object, returns
  ///nonsense and sets \a failed to true.  Otherwise, \a failed is set to
  ///false.
  ///
  ///\remark Assumes that the words follow the format for a
  ///\ref param_stats "param_stats line" in 
  ///\ref file_format_docs "the file format documentation."  
  ///That is, the first word is param_stats, the rest are frac_var
  ///measurements.
  ///
  ///\param words a vector of words as strings describing the desired
  ///ParamStats
  ///
  ///\param failed will be set to true if the words could not be
  ///parsed as a ParamStats object, it will be false otherwise
  ///
  ///\returns the ParamStats object described by the input line.  On failure,
  ///\a failed will be set to true and the returned object will be
  ///nonsense.
  static ParamStats from_text_line
  (const std::vector<std::string>& words, bool& failed);


  ///\brief Write this ParamStats to a new-line terminated string
  ///
  ///Returns the string representation of this ParamStats
  ///from \ref param_stats "the file format documentation"
  ///terminated with a newline
  ///
  ///\returns the string representation of this ParamStats
  ///from \ref param_stats "the file format documentation"
  std::string to_text() const;

  virtual ObjectType type() const{
    return ObjectType("param_stats");
  }

  virtual bool has_same_non_key_parameters(const PMObject* o) const{
    if(o == NULL){ 
      return false; }
    if(o->type() != type()){ 
      return false; }
    const ParamStats* ps = dynamic_cast<const ParamStats*>(o);
    return frac_variances_ == ps->frac_variances_;
  }

};

}
#endif //HOUGH_PEAK_MATCH_PARAM_STATS
