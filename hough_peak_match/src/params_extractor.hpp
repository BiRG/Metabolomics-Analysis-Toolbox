#ifndef HOUGH_PEAK_MATCH_PARAMS_EXTRACTOR_HPP
#define HOUGH_PEAK_MATCH_PARAMS_EXTRACTOR_HPP
#include "param_stats.hpp"

namespace HoughPeakMatch{
  namespace Private{
    ///\brief Functional that extracts the parameters in an object
    struct ParamsExtractor{
      ///\brief Returns the parameters for an object of type T
      ///
      ///\param t The object whose parameters are being extracted
      ///
      ///\return the parameters for an instance of type T
      template<class T>
      inline std::vector<double> operator()(const T& t) const{ 
	return t.params(); }
    };
    
    /// @cond SUPPRESS

    ///\brief Specialization returning the parameters in a
    ///ParamStats object
    ///
    ///\param ps The ParamStats object whose parameters are being extracted
    ///
    ///\return the parameters for the ParamStats object
    template<>
      inline std::vector<double> ParamsExtractor::operator()(const ParamStats& ps) const{ 
      return ps.frac_variances(); }

    /// @endcond 
  }
}

#endif //HOUGH_PEAK_MATCH_PARAMS_EXTRACTOR_HPP
