#include "peak_matching_database.hpp"
#include "sample_key.hpp"
#include "utils.hpp"

namespace HoughPeakMatch{
  std::auto_ptr<PMObject> SampleKey::obj_copy() const{
    using std::auto_ptr;
    auto_ptr<Sample> p = db_.sample_copy_from_id(sample_id_);
    return auto_ptr_dynamic_cast<PMObject>(p);
  }
}
