#ifndef HOUGH_PEAK_MATCH_UNIQUE_PARAMETER_ORDERING
#define HOUGH_PEAK_MATCH_UNIQUE_PARAMETER_ORDERING

#include <stdexcept>
#include <vector>
namespace HoughPeakMatch{
  class PeakMatchingDatabase;

  ///\brief Represents a unique parameter ordering for a particular
  ///PeakMatchingDatabase
  ///
  ///This parameter ordering depends only on the contents of the
  ///database not on the external keys.  It can be applied to
  ///parameter vectors to reorder them in this unique/canonical
  ///ordering
  class UniqueParameterOrdering{
    ///\brief occupant[i] gives the original index of the value to
    ///occupy position i in the reordered array
    std::vector<std::size_t> occupant;
  public:
    ///\brief Extract the parameter ordering for \a pmd
    ///
    ///\param pmd The database whose canonical ordering is to be
    ///extracted
    UniqueParameterOrdering(const PeakMatchingDatabase& pmd);

    ///\brief Return the given vector reordered into this ordering
    ///
    ///\param v The vector whose elements will be reordered for the
    ///return value.  Must have the same number of elements as the
    ///number of parameters in the PeakMatchingDatabase used to
    ///initialize this UniqueParameterOrdering
    ///
    ///\return the given vector reordered into this ordering
    ///
    ///\throw invalid_argument if v has the wrong number of elements
    template<class T>
    std::vector<T> return_reordered(const std::vector<T>& v) const{
      using std::size_t;
      if(v.size() != occupant.size()){
	throw std::invalid_argument("ERROR: Vector with the wrong number "
				    "of elements passed to "
				    "UniqueParameterOrdering::return_reordered");
      }
      typename std::vector<T> ret(v.size());
      typename std::vector<T>::iterator out = ret.begin();
      typename std::vector<size_t>::const_iterator in_idx = occupant.begin();
      while(out != ret.end()){
	*out = v.at(*in_idx);
	++out; ++in_idx;
      }
      return ret;
    }
  };

}

#endif //HOUGH_PEAK_MATCH_UNIQUE_PARAMETER_ORDERING
