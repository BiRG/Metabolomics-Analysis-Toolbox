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
protected:
  ///\brief non-negative integer uniquely identifying this sample in
  ///\brief the database
  unsigned sample_id_;

  ///\brief A string (without white-space) indicating which treatment class
  ///\brief this sample came from. 
  ////
  ///If two samples have different strings, then they came from
  ///different classes, same string, same classes
  ///
  ///\warning This should not contain white-space, nor should it be
  ///the empty string --- any functions that set it should be careful
  ///to check
  std::string sample_class_;

  ///\brief Construct an uninitialized Sample
  ///
  ///\warning Uninitialized is by definition an inconsistent state
  Sample():sample_id_(),sample_class_(){}
public:
  ///\brief Construct a sample object
  ///
  ///\param sample_id the id of this sample
  ///
  ///\param sample_class a string giving the experimental class of this sample
  ///
  ///\throws invalid_argument if class is the empty string or contains
  ///white-space
  Sample(unsigned sample_id, std::string sample_class);

  ~Sample(){}

  ///\brief Return the sample_id for this sample
  ///
  ///\return the sample_id for this sample
  unsigned id() const { return sample_id_; }

  ///\brief Return the sample_class for this sample 
  ///
  ///\return the sample_class for this sample 
  std::string sample_class() const { return sample_class_; }

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


  ///\brief Write this Sample to a new-line terminated string
  ///
  ///Returns the string representation of this Sample
  ///from \ref sample "the file format documentation"
  ///terminated with a newline
  ///
  ///\returns the string representation of this Sample from
  ///\ref sample "the file format documentation" terminated
  ///with a newline
  std::string to_text_line() const;

};

}
#endif //HOUGH_PEAK_MATCH_SAMPLE
