///\file
///\brief Declares the Sample class

#ifndef HOUGH_PEAK_MATCH_SAMPLE
#define HOUGH_PEAK_MATCH_SAMPLE

#include <vector>
#include <string>

namespace HoughPeakMatch{

///\brief An NMR measurement of a sample 
///
///An NMR measurement of a sample from a particular experimental class
///or treatment
class Sample{
  ///\brief non-negative integer uniquely identifying this sample in
  ///\brief the database
  unsigned sample_id_;

  ///\brief A string (without spaces) indicating which treatment class
  ///\brief this sample came from. 
  ////
  ///If two samples have different strings, then they came from
  ///different classes, same string, same classes
  std::string sample_class_;

  ///\brief Construct an uninitialized Sample
  Sample():sample_id_(),sample_class_(){}
public:
  virtual ~Sample(){}

  ///\brief Return the sample_id for this sample
  ///
  ///\return the sample_id for this sample
  virtual unsigned id() const { return sample_id_; }

  ///\brief Return the sample_class for this sample 
  ///
  ///\return the sample_class for this sample 
  virtual std::string sample_class() const { return sample_class_; }

  ///\brief Creates a Sample from a line in a database file
  ///
  ///Takes vector of words and creates a Sample from them.  If the
  ///words do not define a sample, returns nonsense and sets \a failed
  ///to true.  Otherwise, \a failed is set to false.
  ///
  ///\remark Assumes that the words follow the format for a
  ///\ref sample "sample line" in 
  ///\ref file_format_docs "the file format documentation."  
  ///That is, the first word is sample, the second,
  ///the sample id, etc.
  ///
  ///\param words a vector of words as strings describing the desired
  ///Sample
  ///
  ///\param failed will be set to true if the words could not be
  ///parsed as a Sample, it will be false otherwise
  ///
  ///\returns the Sample described by the input line.  On failure,
  ///\a failed will be set to true and the returned sample will be
  ///nonsense.
  static Sample from_text_line
  (const std::vector<std::string>& words, bool& failed);

};

}
#endif //HOUGH_PEAK_MATCH_SAMPLE
