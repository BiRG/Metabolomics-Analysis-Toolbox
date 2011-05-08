///\file
///\brief Declares the ParamStats class

#ifndef HOUGH_PEAK_MATCH_PARAM_STATS
#define HOUGH_PEAK_MATCH_PARAM_STATS

#include <string>
#include <vector>

namespace HoughPeakMatch{

///Statistics describing the global sample parameters 

///Statistics describing each of the global parameters affecting
///shifts within a sample.  Includes the fraction of the global
///variance accounted for by each parameter.
///
///There should be at most one of these in the database
class ParamStats{
  ///\brief Vector where element i holds the fraction of the variance
  ///\brief accounted for by parameter pair i in the database
  std::vector<double> frac_variances_;

  ///\brief Construct an uninitialized ParamStats object
  ParamStats():frac_variances_(){}
public:
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
  static ParamStats fromTextLine
  (const std::vector<std::string>& words, bool& failed);

};

}
#endif //HOUGH_PEAK_MATCH_PARAM_STATS
