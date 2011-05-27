#include "peak_matching_database.hpp"
#include "sample_key.hpp"
#include "utils.hpp"
#include <stdexcept>

namespace HoughPeakMatch{
  std::auto_ptr<PMObject> SampleKey::obj_copy() const{
    using std::auto_ptr;
    auto_ptr<Sample> p = db_.sample_copy_from_id(sample_id_);
    return auto_ptr_dynamic_cast<PMObject>(p);
  }

  bool SampleKey::operator<(const Key& k) const{
    bool this_lt_k = Key::operator<(k);
    if(this_lt_k){
      return true;
    }else{
      bool k_lt_this = k.Key::operator<(*this);
      bool k_eq_this = !this_lt_k && !k_lt_this;
      if(k_eq_this){ 
	const SampleKey *s = dynamic_cast<const SampleKey*>(&k);
	if(s == NULL){
	  throw std::logic_error("ERROR: some other class has the same "
				 "type_string() as SampleKey");
	}else{
	  return sample_id_ < s->sample_id_;
	}
      }else{
	return false;
      }
    }
  }
}
