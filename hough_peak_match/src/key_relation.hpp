#ifndef HOUGH_PEAK_MATCH_KEY_RELATION_HPP
#define HOUGH_PEAK_MATCH_KEY_RELATION_HPP

#include "key_pair.hpp"
#include "dereference_less.hpp"
#include "key.hpp"
#include <boost/shared_ptr.hpp>
#include <utility> //For pair
#include <set>

namespace HoughPeakMatch{

//I ignore EffectiveC++ warnings here to get rid of warning about
//non-virtual destructor in the base class -- and I put a warning in
//the code comment for the class to warn users of the capability I
//give up by using such a base-class
#pragma GCC diagnostic ignored "-Weffc++"

  ///\brief A relation (set of ordered pairs) between keys
  ///
  ///\warning std::set<KeyPair> has no virtual destructor, thus, do
  ///not delete this class through a base-class pointer
  ///
  ///\todo test
  class KeyRelation:public std::set<KeyPair>{
  public:
    ///\brief Create an empty KeyRelation
    KeyRelation():std::set<KeyPair>(){}

    ///\brief Return the keys that are the first element of some
    ///\brief ordered pair in the relation
    ///
    ///\return the keys that are the first element of some ordered
    ///pair in the relation
    std::set<boost::shared_ptr<Key>, DereferenceLess> project_first();

    ///\brief Return the keys that are the second element of some
    ///\brief ordered pair in the relation
    ///
    ///\return the keys that are the second element of some ordered
    ///pair in the relation
    std::set<boost::shared_ptr<Key>, DereferenceLess> project_second();

  };

#pragma GCC diagnostic warning "-Weffc++"
  
}

#endif //HOUGH_PEAK_MATCH_KEY_RELATION_HPP
