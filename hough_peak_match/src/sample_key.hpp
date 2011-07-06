#ifndef HOUGH_PEAK_MATCH_SAMPLE_KEY_HPP
#define HOUGH_PEAK_MATCH_SAMPLE_KEY_HPP

#include "key.hpp"
#include <memory> //For auto_ptr

namespace HoughPeakMatch{

///\brief Key uniquely specifying a Sample object in a PeakMatchingDatabase
///\todo Test
class SampleKey:public Key{
  ///The sample_id for the sample in the source database
  unsigned sample_id_;
public:
  ///\brief Create a SampleKey referencing \a database
  ///
  ///\warning The key object keeps a reference to \a database, thus it
  ///is crucial that the database have a longer life-span than the key
  ///object
  ///
  ///\param database the database in which the object referenced by
  ///this key is stored - should have longer life-span than the key
  ///
  ///\param sample_id the sample_id for the sample in \a database
  SampleKey(const PeakMatchingDatabase& database, unsigned sample_id)
    :Key(database),sample_id_(sample_id){}

  virtual std::string type_string() const{ 
    return "sample_key";
  }

  virtual std::auto_ptr<PMObject> obj_copy() const;

  virtual bool operator<(const Key& k) const;

  virtual std::string to_string() const;
};

}

#endif //HOUGH_PEAK_MATCH_SAMPLE_KEY_HPP
