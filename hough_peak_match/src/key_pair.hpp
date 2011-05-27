#ifndef HOUGH_PEAK_MATCH_KEY_PAIR_HPP
#define HOUGH_PEAK_MATCH_KEY_PAIR_HPP

#include "key.hpp"
#include <boost/shared_ptr.hpp>

namespace HoughPeakMatch{

  ///\brief A pair of keys
  ///
  ///Behaves somewhat like std::pair but it has a different <
  ///operator.  boost::shared_ptr is used because Key objects are
  ///abstract
  struct KeyPair{
    ///\brief the first key in the pair
    boost::shared_ptr<Key> first;
    ///\brief the second key in the pair
    boost::shared_ptr<Key> second;

    ///\brief Create a KeyPair
    ///
    ///\param first the first key in the pair
    ///
    ///\param second the second key in the pair
    KeyPair(boost::shared_ptr<Key> first, boost::shared_ptr<Key> second)
      :first(first),second(second){}

    ///\brief Return true if this and \a rhs are ordered correctly
    ///\brief using a lexical ordering using the keys
    ///
    ///\param rhs the key pair on the right hand side of the <
    ///
    ///\return true if this and \a rhs are ordered correctly using a
    ///lexical ordering using the keys
    bool operator<(KeyPair rhs) const{ 
      return 
	*first < *(rhs.first) ||
	(*first < *(rhs.first) && *second < *(rhs.second) );
    }	

  };

}

#endif //HOUGH_PEAK_MATCH_KEY_PAIR_HPP
