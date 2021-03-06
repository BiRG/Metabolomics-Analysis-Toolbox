#include "utils.hpp"
#include "parameterized_sample.hpp"
#include <sstream>

namespace HoughPeakMatch{
  std::string ParameterizedSample::to_text() const{
    std::ostringstream out;
    out.precision(17);//All the precision needed to reconstruct a double
    out << "sample " << id() << " " << sample_class() << std::endl;
    out << "sample_params " << id() << " "; space_separate(out, params())
	<< std::endl;
    return out.str();
  }
}
