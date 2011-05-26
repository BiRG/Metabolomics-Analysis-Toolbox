#include "param_stats_key.hpp"
#include "peak_matching_database.hpp"
#include <stdexcept>

std::auto_ptr<HoughPeakMatch::PMObject> 
HoughPeakMatch::ParamStatsKey::obj_copy() const{
  if(db_.param_stats().size() != 1){
    throw std::logic_error("A ParamStatsKey object exists for a database "
			   "that does not have exactly one ParamStats object.");
  }else{
    ParamStats* p = new ParamStats(db_.param_stats().front());
    return std::auto_ptr<PMObject>(p);
  }
}
