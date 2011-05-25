///\file
///\brief Declares the FileFormatSampleParams class

#include "no_params_exception.hpp"
#include <string>
#include <vector>

#ifndef HOUGH_PEAK_MATCH_SAMPLE_PARAMS
#define HOUGH_PEAK_MATCH_SAMPLE_PARAMS

namespace HoughPeakMatch{

///Global parameters for a given sample.

///Parameters that describe the latent global factors in a given
///sample to which individual nulei respond by shifting in various
///ways.
class FileFormatSampleParams{
  ///\brief non-negative integer uniquely identifying the sample
  ///\brief described by these parameters
  unsigned sample_id_;

  ///\brief The parameter vector governing the shifts in this sample
  std::vector<double> params_;

  ///\brief Make an uninitialized FileFormatSampleParams object
  FileFormatSampleParams():sample_id_(),params_(){}
public:
  ///\brief Construct a FileFormatSampleParams with the given members
  ///
  ///\param sample_id The sample_id described by this sample_params object
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
  FileFormatSampleParams(unsigned sample_id, InputIter param_begin, InputIter param_end):
    sample_id_(sample_id),params_(param_begin, param_end){
    if(params().size() == 0){
      throw no_params_exception("HoughPeakMatch::FileFormatSampleParams");
    }
  }

  virtual ~FileFormatSampleParams(){}

  ///\brief Creates a FileFormatSampleParams object from a line in a database
  ///\brief file
  ///
  ///Takes vector of words and creates a FileFormatSampleParams object from
  ///them.  If the words do not define a FileFormatSampleParams object, returns
  ///nonsense and sets \a failed to true.  Otherwise, \a failed is set to
  ///false.
  ///
  ///\remark Assumes that the words follow the format for a
  ///\ref sample_params "sample_params line" in 
  ///\ref file_format_docs "the file format documentation."  
  ///That is, the first word is sample_params, the second,
  ///the sample id, etc.
  ///
  ///\param words a vector of words as strings describing the desired
  ///FileFormatSampleParams
  ///
  ///\param failed will be set to true if the words could not be
  ///parsed as a FileFormatSampleParams object, it will be false otherwise
  ///
  ///\returns the FileFormatSampleParams object described by the input line.  On failure,
  ///\a failed will be set to true and the returned peak group will be
  ///nonsense.
  static FileFormatSampleParams from_text_line
  (const std::vector<std::string>& words, bool& failed);



  ///\brief Write this FileFormatSampleParams to a new-line terminated string
  ///
  ///Returns the string representation of this FileFormatSampleParams
  ///from \ref sample_params "the file format documentation"
  ///terminated with a newline
  ///
  ///\returns the string representation of this FileFormatSampleParams
  ///from \ref sample_params "the file format documentation"
  std::string to_text() const;  



  ///\brief Return the sample_id for the sample these parameters describe
  ///
  ///\return Return the sample_id for the sample these parameters describe
  virtual unsigned sample_id() const { return sample_id_; }

  ///\brief Return the sample_id for the sample these parameters describe
  ///
  ///\return Return the sample_id for the sample these parameters describe
  virtual unsigned id() const { return sample_id_; }

  ///\brief Return the parameters determining the shifts in the
  ///\brief described sample
  ///
  ///\return Return the parameters determining the shifts in the
  ///described sample
  virtual const std::vector<double>& params() const{ return params_; }

};

}
#endif //HOUGH_PEAK_MATCH_SAMPLE_PARAMS
