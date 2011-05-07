///\file
///\brief Declares the SampleParams class

#include <string>
#include <vector>

#ifndef HOUGH_PEAK_MATCH_SAMPLE_PARAMS
#define HOUGH_PEAK_MATCH_SAMPLE_PARAMS

namespace HoughPeakMatch{

///Global parameters for a given sample.

///Parameters that describe the latent global factors in a given
///sample to which individual nulei respond by shifting in various
///ways.
class SampleParams{
  ///\brief non-negative integer uniquely identifying the sample
  ///\brief described by these parameters
  unsigned sample_id_;

  ///\brief The parameter vector governing the shifts in this sample
  std::vector<double> params_;

  ///\brief Make an uninitialized SampleParams object
  SampleParams():sample_id_(),params_(){}
public:
  virtual ~SampleParams(){}

  ///\brief Creates a SampleParams object from a line in a database
  ///\brief file
  ///
  ///Takes vector of words and creates a SampleParams object from
  ///them.  If the words do not define a SampleParams object, returns
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
  ///SampleParams
  ///
  ///\param failed will be set to true if the words could not be
  ///parsed as a SampleParams object, it will be false otherwise
  ///
  ///\returns the SampleParams object described by the input line.  On failure,
  ///\a failed will be set to true and the returned peak group will be
  ///nonsense.
  static SampleParams fromTextLine
  (const std::vector<std::string>& words, bool& failed);


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
