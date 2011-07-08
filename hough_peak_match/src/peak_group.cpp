#include "peak_group.hpp"
#include "key.hpp"

namespace HoughPeakMatch{
  std::vector<KeySptr> PeakGroup::foreign_keys(const PeakMatchingDatabase&) const{
    return std::vector<KeySptr>();
  }
}
