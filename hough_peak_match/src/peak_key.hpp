#ifndef HOUGH_PEAK_MATCH_PEAK_KEY_HPP
#define HOUGH_PEAK_MATCH_PEAK_KEY_HPP

#include "key.hpp"
#include <memory> //For auto_ptr
#include <utility> //For pair

namespace HoughPeakMatch{

///\brief Key uniquely specifying a Peak object in a PeakMatchingDatabase
///\todo Test
class PeakKey:public Key{
protected:
  ///The sample_id for the peak in the source database
  unsigned sample_id_;

  ///The peak_id for the peak in the source database
  unsigned peak_id_;
public:
  ///\brief Create a PeakKey referencing \a database
  ///
  ///\warning The key object keeps a reference to \a database, thus it
  ///is crucial that the database have a longer life-span than the key
  ///object
  ///
  ///\param database the database in which the object referenced by
  ///this key is stored - should have longer life-span than the key
  ///
  ///\param id a pair in which the first is the sample_id and the
  ///second, the peak_id
  PeakKey(const PeakMatchingDatabase& database, 
	  std::pair<unsigned, unsigned> id)
    :Key(database),sample_id_(id.first),peak_id_(id.second){}

  virtual std::string type_string() const{ 
    return "peak_key";
  }

  virtual std::auto_ptr<PMObject> obj_copy() const;

  virtual bool operator<(const Key& k) const;

  virtual std::string to_string() const;
};

}

#endif //HOUGH_PEAK_MATCH_PEAK_KEY_HPP
