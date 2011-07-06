#include "unparameterized_sample.hpp"
#include <sstream>

namespace HoughPeakMatch{
  std::string UnparameterizedSample::to_text() const{
    std::ostringstream out;
    out << "sample " << id() << " " << sample_class() << std::endl;
    return out.str();
  }
}
