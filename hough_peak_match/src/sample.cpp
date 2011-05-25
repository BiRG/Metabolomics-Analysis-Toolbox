#include "sample.hpp"
#include "mockable_stringstream.hpp"
#include "utils.hpp"
#include <stdexcept>

namespace HoughPeakMatch{
  
  Sample::Sample(unsigned sample_id, std::string sample_class)
    :sample_id_(sample_id),sample_class_(sample_class){
    if(this->sample_class().size() == 0){
      throw std::invalid_argument("HoughPeakMatch::Sample received an "
				  "empty string for a sample class");
    }
    if(contains_white_space(this->sample_class())){
      throw std::invalid_argument("HoughPeakMatch::Sample received a "
			     "string containing white-space for "
			     "a sample class");
    }
  }
}
