#ifndef HOUGH_PEAK_MATCH_MAPPING_LIST_HPP
#define HOUGH_PEAK_MATCH_MAPPING_LIST_HPP

#include "key_relation.hpp"
#include <map>

namespace HoughPeakMatch{
  class MappingListConstIterator;

  ///\brief A list of mappings between keys
  ///
  ///The list is not stored explicitly.  Instead the "iterator"
  ///constructs elements of the list on the fly.
  ///
  ///\todo test
  class MappingList{
    ///\brief Maps keys to sets of candidate keys in the other database
    std::map<KeySptr, std::set<KeySptr> > map;
  public:
    ///\brief Create a MappingList containing all the mappings implied
    ///\brief by the candidate pairs in \a r
    ///
    ///\param r The relation to be represented as a list of mappings
    MappingList(const KeyRelation& r){
      KeyRelation::const_iterator it;
      for(it = r.begin(); it != r.end(); ++it){
	map[(*it)->first]=(*it)->second;
      }
    }

    ///\brief Return a const-iterator-like object to the beginning of
    ///\brief this MappingList
    ///
    ///\return a const-iterator-like object to the beginning of this
    ///MappingList
    MappingListConstIterator begin() const;

    ///\brief Return a const-iterator-like object to one-past-the-end
    ///\brief of this MappingList
    ///
    ///\return a const-iterator-like object to one-past-the-end of
    ///this MappingList
    MappingListConstIterator end() const;
  };

  ///\brief Data class to hold the beginning, current position and end
  ///\brief of a set of Keys
  struct KeySetConstIteratorTriple{
    ///\brief Begin iterator for the set
    std::set<KeySptr>::const_iterator begin;
    ///\brief Iterator for the current position in the set
    std::set<KeySptr>::const_iterator cur;
    ///\brief One-past-the-end iterator for the set
    std::set<KeySptr>::const_iterator end;

    ///\brief Create a KeySetConstIteratorTriple
    ///
    ///\param begin Begin iterator for the set
    ///
    ///\param cur Iterator for the current position in the set
    ///
    ///\param end One-past-the-end iterator for the set    
    KeySetConstIteratorTriple
    (std::set<KeySptr>::const_iterator begin,
     std::set<KeySptr>::const_iterator cur,
     std::set<KeySptr>::const_iterator end):begin(begin),cur(cur),end(end){}
  };

  ///\brief A const_iterator-like object for iterating through a
  ///MappingList.  There is no dereference object because it was more
  ///convenient to not have an actual internal map from KeySptr to
  ///KeySptr that would get exposed to the world or to write a proxy
  ///object.  The operator() serves the same purpose more compactly.
  ///(I don't use operator[] because one might get confused with the
  ///auto-vivify semantics of the normal map)
  ///
  ///\todo finish
  ///
  ///\todo test
  class MappingListConstIterator{
    ///\brief Maps from each key to its current candidate
    std::map<KeySptr, KeySetConstIteratorTriple> map;
    ///\brief If true then the map member wrapped around and now we
    ///\brief are a one-past-the-end iterator
    bool at_end;
  public:
    ///\brief Create an iterator for \a ml either at the beginning or
    ///\brief one-past-the-end
    ///
    ///\param ml The mapping list the iterator will cover
    ///
    ///\param from_beginning if true, the iterator starts at the first
    ///element of ml, if false, then a one-past-the-end iterator is
    ///created.
    MappingListConstIterator(const MappingList&ml,bool from_beginning);
  };
}

#endif //HOUGH_PEAK_MATCH_MAPPING_LIST_HPP
