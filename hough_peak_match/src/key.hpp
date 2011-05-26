#ifndef HOUGH_PEAK_MATCH_KEY_HPP
#define HOUGH_PEAK_MATCH_KEY_HPP

#include "pmobject.hpp"
#include <memory> //For auto_ptr

namespace HoughPeakMatch{

class PeakMatchingDatabase;

///\brief Key uniquely specifying an object in a PeakMatchingDatabase
///
///Key objects can retrieve a copy of the object they specify from the
///database and be compared to other key objects
///\todo Test
class Key{
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
};

}

#endif //HOUGH_PEAK_MATCH_KEY_HPP
