#include "peak_matching_database.hpp"
#include "peak_key.hpp"
#include "utils.hpp"

namespace HoughPeakMatch{
  std::auto_ptr<PMObject> PeakKey::obj_copy() const{
    using std::auto_ptr;
    auto_ptr<Peak> p = db_.peak_copy_from_id(sample_id_, peak_id_);
    return auto_ptr_dynamic_cast<PMObject>(p);
  }


  bool PeakKey::operator<(const Key& k) const{
    bool this_lt_k = Key::operator<(k);
    if(this_lt_k){
      return true;
    }else{
      bool k_lt_this = k.Key::operator<(*this);
      bool k_eq_this = !this_lt_k && !k_lt_this;
      if(k_eq_this){ 
	const PeakKey *s = dynamic_cast<const PeakKey*>(&k);
	if(s == NULL){
	  throw std::logic_error("ERROR: some other class has the same "
				 "type_string() as PeakKey");
	}else{
	  return peak_id_ < s->peak_id_ ||
	    (peak_id_ == s->peak_id_ && sample_id_ < s->sample_id_);
	}
      }else{
	return false;
      }
    }
  }

}
