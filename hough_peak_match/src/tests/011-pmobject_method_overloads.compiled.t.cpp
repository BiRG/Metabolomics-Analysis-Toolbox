#include "../param_stats.hpp"

#include <tap++/tap++.h>
#include <string>

int main(){
  using namespace TAP; using namespace HoughPeakMatch;
  plan(1);

  {
    double params[4] = {0.5,0.1,0.01,0.001};
    ParamStats t(params,params+4);
    not_ok(t.has_same_non_key_parameters(NULL),
	   "ParamStats has different non-key parameters than NULL pointer.");
  }
  
}
