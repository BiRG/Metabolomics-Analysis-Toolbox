#ifndef HOUGH_PEAK_MATCH_PARAM_STATS_KEY_HPP
#define HOUGH_PEAK_MATCH_PARAM_STATS_KEY_HPP

#include "key.hpp"
#include <memory> //For auto_ptr

namespace HoughPeakMatch{

///\brief Key uniquely specifying a Param_Stats object in a PeakMatchingDatabase
///\todo Test
class ParamStatsKey:public Key{
public:
  ///\brief Create a ParamStatsKey referencing \a database
  ///
  ///\warning The key object keeps a reference to \a database, thus it
  ///is crucial that the database have a longer life-span than the key
  ///object
  ///
  ///\param database the database in which the object referenced by
  ///this key is stored - should have longer life-span than the key
  ///
  ///\pre \a database has exactly one ParamStats object
  ParamStatsKey(const PeakMatchingDatabase& database)
    :Key(database){}

  virtual std::string type_string() const{ 
    return "param_stats_key";
  }

  virtual std::auto_ptr<PMObject> obj_copy() const;
};

}

#endif //HOUGH_PEAK_MATCH_PARAM_STATS_KEY_HPP
