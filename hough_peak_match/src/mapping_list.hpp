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

    friend class MappingListConstIterator;
  public:
    ///\brief Create a MappingList containing all the mappings implied
    ///by the candidate pairs in \a r
    ///
    ///\param r The relation to be represented as a list of mappings
    MappingList(const KeyRelation& r):map(){
      KeyRelation::const_iterator it;
      for(it = r.begin(); it != r.end(); ++it){
	map[it->first].insert(it->second);
      }
    }

    ///\brief Return a const-iterator-like object to the beginning of
    ///this MappingList
    ///
    ///\return a const-iterator-like object to the beginning of this
    ///MappingList
    MappingListConstIterator begin() const;

    ///\brief Return a const-iterator-like object to one-past-the-end
    ///of this MappingList
    ///
    ///\return a const-iterator-like object to one-past-the-end of
    ///this MappingList
    MappingListConstIterator end() const;
  };

  ///\brief Data class to hold the beginning, current position and end
  ///of a set of Keys
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

    ///\brief Create an uninitialized KeySetConstIteratorTriple
    KeySetConstIteratorTriple():begin(),cur(),end(){}

    ///\brief Return true if this has identical members to \a rhs
    ///
    ///\param rhs the KeySetConstIteratorTriple whose members will be
    ///compared for equality
    ///
    ///\return true if this has identical members to \a rhs
    bool operator==(const KeySetConstIteratorTriple&rhs) const{
      return begin == rhs.begin && cur == rhs.cur && end == rhs.end;
    }

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
    ///
    ///Unless at_end is set, the cur element of the triple always
    ///points to a valid KeySptr
    std::map<KeySptr, KeySetConstIteratorTriple> map;
    ///\brief If true then the map member wrapped around and now we
    ///are a one-past-the-end iterator
    bool at_end;
  public:
    ///\brief Create an iterator for \a ml either at the beginning or
    ///one-past-the-end
    ///
    ///\param ml The mapping list the iterator will cover
    ///
    ///\param from_beginning if true, the iterator starts at the first
    ///element of ml, if false, then a one-past-the-end iterator is
    ///created.
    MappingListConstIterator(const MappingList&ml,bool from_beginning);

    ///\brief Increment this iterator and return it
    ///
    ///\return this iterator after incrementation
    MappingListConstIterator& operator++();

    ///\brief Return the KeySptr that \a key maps to
    ///
    ///\param key the key whose associated value will be returned
    ///
    ///\return Return the KeySptr that \a key maps to, if \a key
    ///doesn't exist or the iterator is past the end, returns a
    ///KeySptr to NULL
    KeySptr operator()(KeySptr key) const;
    
    ///\brief Return true iff the two iterators point to different
    ///parts of the list or to different lists
    ///
    ///\param other the iterator to which this one is being compared
    ///
    ///\return true iff the two iterators point to different parts of
    ///the list or to different lists
    bool operator !=(const MappingListConstIterator& other);

    ///\brief Return the keys of the mapping
    ///
    ///\return the keys of the mapping
    std::set<KeySptr> keys();

    ///\brief Return the values of the mapping
    ///
    ///\return the values of the mapping
    std::set<KeySptr> values();
  };
}

#endif //HOUGH_PEAK_MATCH_MAPPING_LIST_HPP
