#include "peak_group_key.hpp"
#include "known_peak.hpp"
#include "mockable_stringstream.hpp"


namespace HoughPeakMatch{
  void KnownPeak::initFrom(const std::vector<std::string>& words, 
			   const std::string& expected_name, 
			   bool& failed){
    if(words.size() < 5){ 
      failed = true;  return; } 

    Peak::initFrom(words, expected_name, failed);
    if(failed){ 
      return; }

    int id_temp;
    std::istringstream in(words.at(4));
    if(! (in >> id_temp)){
      failed = true; return; }	
    if(id_temp < 0){ 
      failed = true; return; }
    peak_group_id_ = id_temp;

    failed = false; return;
  }

  std::vector<KeySptr> KnownPeak::foreign_keys(const PeakMatchingDatabase& db) const{
    std::vector<KeySptr> ret(2, KeySptr(NULL));
    ret[0]=KeySptr(new SampleKey(db, sample_id()));
    ret[1]=KeySptr(new PeakGroupKey(db, peak_group_id()));
    return ret;
  }

}
