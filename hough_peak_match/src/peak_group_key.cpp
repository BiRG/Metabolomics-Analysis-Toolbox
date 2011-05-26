#include "peak_matching_database.hpp"
#include "peak_group_key.hpp"
#include "utils.hpp"
#include <stdexcept>

namespace HoughPeakMatch{
  std::auto_ptr<PMObject> PeakGroupKey::obj_copy() const{
    using std::auto_ptr;
    auto_ptr<PeakGroup> p = db_.peak_group_copy_from_id(peak_group_id_);
    return auto_ptr_dynamic_cast<PMObject>(p);
  }

  bool PeakGroupKey::operator<(const Key& k) const{
    bool this_lt_k = Key::operator<(k);
    if(this_lt_k){
      return true;
    }else{
      bool k_lt_this = k.Key::operator<(*this);
      bool k_eq_this = !this_lt_k && !k_lt_this;
      if(k_eq_this){ 
	const PeakGroupKey *pg = dynamic_cast<const PeakGroupKey*>(&k);
	if(pg == NULL){
	  throw std::logic_error("ERROR: some other class has the same "
				 "type_string() as PeakGroupKey");
	}else{
	  return peak_group_id_ < pg->peak_group_id_;
	}
      }else{
	return false;
      }
    }
  }
  

}
