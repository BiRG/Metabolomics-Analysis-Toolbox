#include "peak_matching_database.hpp"
#include "peak_key.hpp"
#include "utils.hpp"

namespace HoughPeakMatch{
  std::auto_ptr<PMObject> PeakKey::obj_copy() const{
    using std::auto_ptr;
    auto_ptr<Peak> p = db_.peak_copy_from_id(sample_id_, peak_id_);
    return auto_ptr_dynamic_cast<PMObject>(p);
  }
}
