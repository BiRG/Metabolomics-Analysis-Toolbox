#ifndef HOUGH_PEAK_MATCH_KEY_HPP
#define HOUGH_PEAK_MATCH_KEY_HPP

#include "pmobject.hpp"
#include <boost/operators.hpp>
#include <memory> //For auto_ptr

namespace HoughPeakMatch{

class PeakMatchingDatabase;

///\brief Key uniquely specifying an object in a PeakMatchingDatabase
///
///Key objects can retrieve a copy of the object they specify from the
///database and be compared to other key objects
///\todo Test
#pragma GCC diagnostic ignored "-Weffc++"
class Key:private boost::less_than_comparable<Key>, 
	  private boost::equivalent<Key>{
protected:
  ///\brief The database in which the object referenced by this key is
  ///\brief stored
  const PeakMatchingDatabase& db_;
public:
  ///\brief Create a key referencing \a database
  ///
  ///\warning The key object keeps a reference to \a database, thus it
  ///is crucial that the database have a longer life-span than the key
  ///object
  ///
  ///\param database the database in which the object referenced by
  ///this key is stored - should have longer life-span than the key
  Key(const PeakMatchingDatabase& database):db_(database){}

  ///\brief Return a copy of the object referenced by this key
  ///
  ///\return a copy of the object referenced by this key
  virtual std::auto_ptr<PMObject> obj_copy() const = 0;

  virtual ~Key(){}

  ///\brief Return a string describing the type of this key
  ///
  ///Every (non-abstract) subclass of Key should have its own unique
  ///string.  If two keys are from the same database, they sort by
  ///this string.
  ///
  ///\return a string describing the type of this key
  virtual std::string type_string() const = 0;

  ///\brief Return true iff this should sort before \a k
  ///
  ///There is an ordering between database object instances and
  ///between types of keys.  Subclasses are expected to call this
  ///function and if it returns true, return true as well.  If neither
  ///a<b and b<a by Key::operator< , then a and b come from the same
  ///database and have the same type-string
  ///
  ///\note Key objects are totally ordered by < so: 
  ///if !(a < b && b<a) then a==b.  Be sure that only identical keys 
  ///from the same database compare equal.
  ///
  ///\param k the key being compared
  ///
  ///\return true iff this should sort before \a k
  virtual bool operator<(const Key& k) const{
    return &db_ < &(k.db_) ||
      (&db_ < &(k.db_) && type_string() < k.type_string());
  }
};
#pragma GCC diagnostic warning "-Weffc++"

}

#endif //HOUGH_PEAK_MATCH_KEY_HPP
