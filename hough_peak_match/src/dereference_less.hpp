///\file
///\brief Declares and defines the DereferenceLess class
#ifndef HOUGH_PEAK_MATCH_DEREFERENCE_LESS_HPP
#define HOUGH_PEAK_MATCH_DEREFERENCE_LESS_HPP

namespace HoughPeakMatch{
  ///\brief Operator< that compares two pointer-like types with <
  ///\brief after first applying *, the dereference operator, to them.
  ///\todo Test
  struct DereferenceLess{
    ///\brief Return true iff *a < *b
    ///
    ///\param a the pointer on the left of the comparison
    ///
    ///\param b the pointer on the right of the comparison
    ///
    ///\return true iff *a < *b
    ///
    ///\tparam T A pointer type that can be dereferenced with * and
    ///for which *T has an operator<
    template<class T>
    bool operator()(T a, T b){
      return *a < *b;
    }
  };
}

#endif //HOUGH_PEAK_MATCH_DEREFERENCE_LESS_HPP
