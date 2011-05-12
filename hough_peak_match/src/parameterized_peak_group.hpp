///\file
///\brief Declares the ParameterizedPeakGroup class

#ifndef HOUGH_PEAK_MATCH_PARAMETERIZED_PEAK_GROUP
#define HOUGH_PEAK_MATCH_PARAMETERIZED_PEAK_GROUP

#include "no_params_exception.hpp"
#include "peak_group.hpp"
#include <vector>
#include <string>
#include <cstdlib>//For exit
#include <iostream>

namespace HoughPeakMatch{

///A peak group for which the parameters have been discovered
class ParameterizedPeakGroup:public PeakGroup{
protected:
  ///\brief The base location of the peak group
  double ppm_;

  ///\brief The parameter vector governing the shifts in this peak-group
  std::vector<double> params_;

  ///\brief Create an uninitialized ParameterizedPeakGroup
  ParameterizedPeakGroup():ppm_(),params_(){};
public:
  friend class PeakMatchingDatabase;

  ///\brief Construct a ParameterizedPeakGroup with the given members
  ///
  ///\param ppm The base location of the peak group
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
  ParameterizedPeakGroup(unsigned id, double ppm, 
			 InputIter param_begin, InputIter param_end):
    PeakGroup(id),ppm_(ppm),params_(param_begin, param_end){
    if(params().size() == 0){
      std::cerr << "ERROR: attempt to create a peak group with 0 parameters\n";
      std::exit(-1);
    }
  }

  virtual ~ParameterizedPeakGroup(){}

  ///\brief Creates a ParameterizedPeakGroup from a line in a database file
  ///
  ///Takes vector of words and creates a ParameterizedPeakGroup from
  ///them.  If the words do not define a parameterized_peak_group,
  ///returns nonsense and sets failed to true.  Otherwise, failed is
  ///set to false.
  ///
  ///\remark Assumes that the words follow the format for a
  ///\ref parameterized_peak_group "parameterized_peak_group line" in 
  ///\ref file_format_docs "the file format documentation."  
  ///That is, the first word is parameterized_peak_group, the second,
  ///the peak group id, etc.
  ///
  ///\param words a vector of words as strings describing the desired
  ///ParameterizedPeakGroup
  ///
  ///\param failed will be set to true if the words could not be
  ///parsed as a ParameterizedPeakGroup, it will be false otherwise
  ///
  ///\returns the peak group described by the input line.  On failure,
  ///failed will be set to true and the returned peak group will be
  ///nonsense.
  ///
  ///\todo refactor this to combine it with the detected_peak_group
  ///reading - they're almost identical
  static ParameterizedPeakGroup from_text_line
  (const std::vector<std::string>& words, bool& failed);

  

  ///\brief Write this ParameterizedPeakGroup to a new-line terminated string
  ///
  ///Returns the string representation of this ParameterizedPeakGroup
  ///from \ref file_format_docs "the file format documentation"
  ///terminated with a newline
  ///
  ///\returns the string representation of this ParameterizedPeakGroup
  ///from \ref file_format_docs "the file format documentation"
  std::string to_text_line();

  
  ///\brief Return the parameters for this ParameterizedPeakGroup
  ///
  ///\return the parameters for this ParameterizedPeakGroup
  const std::vector<double>& params() const{ return params_; }

  ///\brief Return the ppm location for this ParameterizedPeakGroup
  ///
  ///\return the ppm location for this ParameterizedPeakGroup
  double ppm() const{ return ppm_; }

};



}
#endif //HOUGH_PEAK_MATCH_PARAMETERIZED_PEAK_GROUP
