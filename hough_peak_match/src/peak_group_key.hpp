#ifndef HOUGH_PEAK_MATCH_PEAK_GROUP_KEY_HPP
#define HOUGH_PEAK_MATCH_PEAK_GROUP_KEY_HPP

#include "key.hpp"
#include <memory> //For auto_ptr

namespace HoughPeakMatch{

///\brief Key uniquely specifying a PeakGroup object in a PeakMatchingDatabase
///\todo Test
class PeakGroupKey:public Key{
  ///The peak_group_id for the peak_group in the source database
  unsigned peak_group_id_;
public:
  ///\brief Create a PeakGroupKey referencing \a database
  ///
  ///\warning The key object keeps a reference to \a database, thus it
  ///is crucial that the database have a longer life-span than the key
  ///object
  ///
  ///\param database the database in which the object referenced by
  ///this key is stored - should have longer life-span than the key
  ///
  ///\param peak_group_id the peak_group_id for the peak_group in \a database
  PeakGroupKey(const PeakMatchingDatabase& database, unsigned peak_group_id)
    :Key(database),peak_group_id_(peak_group_id){}

  virtual std::string type_string() const{
    return "peak_group_key";
  }

  virtual std::auto_ptr<PMObject> obj_copy() const;

  virtual bool operator<(const Key& k) const;
};

}

#endif //HOUGH_PEAK_MATCH_PEAK_GROUP_KEY_HPP
