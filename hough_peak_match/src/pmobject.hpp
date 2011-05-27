///\file
///\brief Declares and defines the PMObject class
#ifndef HOUGH_PEAK_MATCH_PMOBJECT_HPP
#define HOUGH_PEAK_MATCH_PMOBJECT_HPP

#include "object_type.hpp"
#include <vector>

namespace HoughPeakMatch{

class KeySptr;
class PeakMatchingDatabase;

///\brief The base class of all objects in the PeakMatchingDatabase
class PMObject{
public:
  ///\brief Return the type of this object
  ///
  ///\return the type of this object
  virtual ObjectType type() const = 0;

  ///\brief Return true if this object's attributes that are not
  ///foreign keys are the same as those of \a o
  ///
  ///Two objects of different type (even a base and derived type) will
  ///always compare different.  This object will also always compare
  ///different than NULL.
  ///
  ///\param o The object whose non-foreign-key attributes are being
  ///compared
  ///
  ///\return true if this object's attributes that are not foreign
  ///keys are the same as those of \a o
  virtual bool has_same_non_key_parameters(const PMObject* o) const = 0;

  ///\brief Return a list of the foreign keys used by this object
  ///
  ///This list is guaranteed to be in the same order for all objects
  ///the same type
  ///
  ///\param db the database to resolve the keys against -- must have a
  ///longer life-span than the returned key objects
  ///
  ///\return a list of the foreign keys used by this object
  virtual std::vector<KeySptr> foreign_keys(const PeakMatchingDatabase& db) const = 0;

  virtual ~PMObject(){}
};

}

#endif //HOUGH_PEAK_MATCH_PMOBJECT_HPP
