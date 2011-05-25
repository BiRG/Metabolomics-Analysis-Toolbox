#include "../param_stats.hpp"
#include "../unknown_peak.hpp"
#include "../human_verified_peak.hpp"
#include "../unverified_peak.hpp"
#include "../peak_group.hpp"
#include "../parameterized_peak_group.hpp"
#include "../detected_peak_group.hpp"

#include <tap++/tap++.h>
#include <string>
#include <memory> //for auto_ptr

int main(){
  using namespace TAP; using namespace HoughPeakMatch;
  using std::auto_ptr;
  plan(53);

  //ParamStats

  {
    double params[4] = {0.5,0.1,0.01,0.001};
    ParamStats t(params,params+4);
    not_ok(t.has_same_non_key_parameters(NULL),
	   "ParamStats has different non-key parameters than NULL pointer.");
  }
  {
    double params[4] = {0.5,0.1,0.01,0.001};
    ParamStats t(params,params+4);
    UnknownPeak p(1,2,0.01);
    not_ok(t.has_same_non_key_parameters(&p),
	   "ParamStats has different non-key parameters than object of "
	   "different type .");
  }
  {
    double paramst[4] = {0.5,0.1,0.01,0.001};
    double paramstt[4] = {0.5,0.1,0.01,0.001};
    ParamStats t(paramst,paramst+4);
    ParamStats tt(paramstt,paramstt+4);
    ok(t.has_same_non_key_parameters(&tt),
       "ParamStats has same parameters as identical ParamStats");
  }
  {
    double paramst[4] = {0.5,0.1,0.01,0.001};
    ParamStats t(paramst,paramst+4);
    ok(t.has_same_non_key_parameters(&t),
       "ParamStats has same parameters as itself");
  }
  {
    double paramst[4] = {0.5,0.1,0.01,0.001};
    double paramstt[3] = {0.5,0.1,0.01};
    ParamStats t(paramst,paramst+4);
    ParamStats tt(paramstt,paramstt+3);
    not_ok(t.has_same_non_key_parameters(&tt),
	   "ParamStats has different parameters than shorter object.");
  }
  {
    double paramst[3] = {0.5,0.1,0.01};
    double paramstt[4] = {0.5,0.1,0.01,0.001};
    ParamStats t(paramst,paramst+3);
    ParamStats tt(paramstt,paramstt+4);
    not_ok(t.has_same_non_key_parameters(&tt),
	   "ParamStats has different parameters than longer object.");
  }
  {
    double paramst[4] = {0.5,0.1,0.01,0.2};
    double paramstt[4] = {0.5,0.1,0.01,0.001};
    ParamStats t(paramst,paramst+4);
    ParamStats tt(paramstt,paramstt+4);
    not_ok(t.has_same_non_key_parameters(&tt),
	   "ParamStats has different parameters with same length "
	   "but different last value.");
  }


  //HumanVerifiedPeak
  {
    HumanVerifiedPeak t(1,2,0.5,3);
    not_ok(t.has_same_non_key_parameters(NULL),
	   "HumanVerifiedPeak has different non-key than NULL");
  }
  {
    HumanVerifiedPeak t(1,2,0.5,3);
    UnverifiedPeak tt(1,2,0.5,3);
    not_ok(t.has_same_non_key_parameters(&tt),
	   "HumanVerifiedPeak has different non-key than UnverifiedPeak");
  }
  {
    HumanVerifiedPeak t(1,2,0.5,3);
    HumanVerifiedPeak tt(1,2,0.2,3);
    not_ok(t.has_same_non_key_parameters(&tt),
	   "HumanVerifiedPeak has different non-key than hvp with diff ppm");
  }
  {
    HumanVerifiedPeak t(1,2,0.5,3);
    HumanVerifiedPeak tt(1,2,0.5,3);
    ok(t.has_same_non_key_parameters(&tt),
       "HumanVerifiedPeak has same non-key as identical object");
  }
  {
    HumanVerifiedPeak t(1,2,0.5,3);
    ok(t.has_same_non_key_parameters(&t),
       "HumanVerifiedPeak has same non-key as itself");
  }
  {
    HumanVerifiedPeak t(1,2,0.5,3);
    HumanVerifiedPeak tt(5,2,0.5,3);
    ok(t.has_same_non_key_parameters(&tt),
       "HumanVerifiedPeak has same non-key as obj with diff sample_id");
  }
  {
    HumanVerifiedPeak t(1,2,0.5,3);
    HumanVerifiedPeak tt(1,8,0.5,3);
    ok(t.has_same_non_key_parameters(&tt),
       "HumanVerifiedPeak has same non-key as obj with diff peak_id");
  }
  {
    HumanVerifiedPeak t(1,2,0.5,3);
    HumanVerifiedPeak tt(1,2,0.5,5);
    ok(t.has_same_non_key_parameters(&tt),
       "HumanVerifiedPeak has same non-key as obj with diff peak_group_id");
  }


  //UnverifiedPeak
  {
    UnverifiedPeak t(1,2,0.5,3);
    not_ok(t.has_same_non_key_parameters(NULL),
	   "UnverifiedPeak has different non-key than NULL");
  }
  {
    UnverifiedPeak t(1,2,0.5,3);
    HumanVerifiedPeak tt(1,2,0.5,3);
    not_ok(t.has_same_non_key_parameters(&tt),
	   "UnverifiedPeak has different non-key than HumanVerifiedPeak");
  }
  {
    UnverifiedPeak t(1,2,0.5,3);
    UnverifiedPeak tt(1,2,0.2,3);
    not_ok(t.has_same_non_key_parameters(&tt),
	   "UnverifiedPeak has different non-key than hvp with diff ppm");
  }
  {
    UnverifiedPeak t(1,2,0.5,3);
    UnverifiedPeak tt(1,2,0.5,3);
    ok(t.has_same_non_key_parameters(&tt),
       "UnverifiedPeak has same non-key as identical object");
  }
  {
    UnverifiedPeak t(1,2,0.5,3);
    ok(t.has_same_non_key_parameters(&t),
       "UnverifiedPeak has same non-key as itself");
  }
  {
    UnverifiedPeak t(1,2,0.5,3);
    UnverifiedPeak tt(5,2,0.5,3);
    ok(t.has_same_non_key_parameters(&tt),
       "UnverifiedPeak has same non-key as obj with diff sample_id");
  }
  {
    UnverifiedPeak t(1,2,0.5,3);
    UnverifiedPeak tt(1,8,0.5,3);
    ok(t.has_same_non_key_parameters(&tt),
       "UnverifiedPeak has same non-key as obj with diff peak_id");
  }
  {
    UnverifiedPeak t(1,2,0.5,3);
    UnverifiedPeak tt(1,2,0.5,5);
    ok(t.has_same_non_key_parameters(&tt),
       "UnverifiedPeak has same non-key as obj with diff peak_group_id");
  }

  //UnknownPeak
  {
    UnknownPeak t(1,2,0.5);
    not_ok(t.has_same_non_key_parameters(NULL),
	   "UnknownPeak has different non-key than NULL");
  }
  {
    UnknownPeak t(1,2,0.5);
    HumanVerifiedPeak tt(1,2,0.5,3);
    not_ok(t.has_same_non_key_parameters(&tt),
	   "UnknownPeak has different non-key than HumanVerifiedPeak");
  }
  {
    UnknownPeak t(1,2,0.5);
    UnknownPeak tt(1,2,0.2);
    not_ok(t.has_same_non_key_parameters(&tt),
	   "UnknownPeak has different non-key than hvp with diff ppm");
  }
  {
    UnknownPeak t(1,2,0.5);
    UnknownPeak tt(1,2,0.5);
    ok(t.has_same_non_key_parameters(&tt),
       "UnknownPeak has same non-key as identical object");
  }
  {
    UnknownPeak t(1,2,0.5);
    ok(t.has_same_non_key_parameters(&t),
       "UnknownPeak has same non-key as itself");
  }
  {
    UnknownPeak t(1,2,0.5);
    UnknownPeak tt(5,2,0.5);
    ok(t.has_same_non_key_parameters(&tt),
       "UnknownPeak has same non-key as obj with diff sample_id");
  }
  {
    UnknownPeak t(1,2,0.5);
    UnknownPeak tt(1,8,0.5);
    ok(t.has_same_non_key_parameters(&tt),
       "UnknownPeak has same non-key as obj with diff peak_id");
  }

  //PeakGroup
  {
    PeakGroup t(12);
    not_ok(t.has_same_non_key_parameters(NULL),
	   "PeakGroup has diff non-key than NULL");
  }
  {
    double d[1]={1};
    PeakGroup t(12);
    ParamStats tt(d,d+1);
    not_ok(t.has_same_non_key_parameters(&tt),
	   "PeakGroup has diff non-key than object of a different type");
  }
  {
    PeakGroup t(12);
    ok(t.has_same_non_key_parameters(&t),
       "PeakGroup has same non-key as itself");
  }
  {
    PeakGroup t(12);
    PeakGroup tt(12);
    ok(t.has_same_non_key_parameters(&tt),
       "PeakGroup has same non-key as identical object");
  }
  {
    PeakGroup t(12);
    PeakGroup tt(1);
    ok(t.has_same_non_key_parameters(&tt),
       "PeakGroup has same non-key as object with different id");
  }

  //ParameterizedPeakGroup

  {
    double params[4] = {7,2.1,0,0.001};
    ParameterizedPeakGroup t(5,201.1,params,params+4);
    not_ok(t.has_same_non_key_parameters(NULL),
	   "ParameterizedPeakGroup has different non-key parameters "
	   "than NULL pointer.");
  }
  {
    double params[4] = {7,2.1,0,0.001};
    ParameterizedPeakGroup t(5,201.1,params,params+4);
    UnknownPeak p(1,2,0.01);
    not_ok(t.has_same_non_key_parameters(&p),
	   "ParameterizedPeakGroup has different non-key parameters "
	   "than object of "
	   "different type .");
  }
  {
    double paramst[4] = {7,2.1,0,0.001};
    double paramstt[4] = {7,2.1,0,0.001};
    ParameterizedPeakGroup t(5,201.1,paramst,paramst+4);
    ParameterizedPeakGroup tt(5,201.1,paramstt,paramstt+4);
    ok(t.has_same_non_key_parameters(&tt),
       "ParameterizedPeakGroup has same parameters as "
       "identical ParameterizedPeakGroup");
  }
  {
    double paramst[4] = {7,2.1,0,0.001};
    ParameterizedPeakGroup t(5,201.1,paramst,paramst+4);
    ok(t.has_same_non_key_parameters(&t),
       "ParameterizedPeakGroup has same parameters as itself");
  }
  {
    double paramst[4] = {7,2.1,0,0.001};
    double paramstt[3] = {7,2.1,0};
    ParameterizedPeakGroup t(5,201.1,paramst,paramst+4);
    ParameterizedPeakGroup tt(5,201.1,paramstt,paramstt+3);
    not_ok(t.has_same_non_key_parameters(&tt),
	   "ParameterizedPeakGroup has different parameters than "
	   "shorter object.");
  }
  {
    double paramst[3] = {7,2.1,0};
    double paramstt[4] = {7,2.1,0,0.001};
    ParameterizedPeakGroup t(5,201.1,paramst,paramst+3);
    ParameterizedPeakGroup tt(5,201.1,paramstt,paramstt+4);
    not_ok(t.has_same_non_key_parameters(&tt),
	   "ParameterizedPeakGroup has different parameters than "
	   "longer object.");
  }
  {
    double paramst[4] = {7,2.1,0,0.2};
    double paramstt[4] = {7,2.1,0,0.001};
    ParameterizedPeakGroup t(5,201.1,paramst,paramst+4);
    ParameterizedPeakGroup tt(5,201.1,paramstt,paramstt+4);
    not_ok(t.has_same_non_key_parameters(&tt),
	   "ParameterizedPeakGroup has different parameters with same length "
	   "but different last value.");
  }
  {
    double paramst[4] = {7,2.1,0,0.2};
    double paramstt[4] = {7,2.1,0,0.2};
    ParameterizedPeakGroup t(5,201.1,paramst,paramst+4);
    ParameterizedPeakGroup tt(5,200,paramstt,paramstt+4);
    not_ok(t.has_same_non_key_parameters(&tt),
	   "ParameterizedPeakGroup has different parameters with identical "
	   "vectors but different ppm.");
  }
  {
    double paramst[4] = {7,2.1,0,0.2};
    double paramstt[4] = {7,2.1,0,0.2};
    ParameterizedPeakGroup t(5,201.1,paramst,paramst+4);
    ParameterizedPeakGroup tt(100,201.1,paramstt,paramstt+4);
    ok(t.has_same_non_key_parameters(&tt),
       "ParameterizedPeakGroup has same parameters when differ only in "
       "id.");
  }

  //DetectedPeakGroup

  {
    double params[2] = {5,0.001};
    DetectedPeakGroup t(20,51.1,params,params+2);
    not_ok(t.has_same_non_key_parameters(NULL),
	   "DetectedPeakGroup has different non-key parameters "
	   "than NULL pointer.");
  }
  {
    double params[2] = {5,0.001};
    DetectedPeakGroup t(20,51.1,params,params+2);
    ParameterizedPeakGroup p(20,51.1,params,params+2);
    not_ok(t.has_same_non_key_parameters(&p),
	   "DetectedPeakGroup has different non-key parameters "
	   "than object of different type .");
  }
  {
    double paramst[2] = {5,0.001};
    double paramstt[2] = {5,0.001};
    DetectedPeakGroup t(20,51.1,paramst,paramst+2);
    DetectedPeakGroup tt(20,51.1,paramstt,paramstt+2);
    ok(t.has_same_non_key_parameters(&tt),
       "DetectedPeakGroup has same parameters as "
       "identical DetectedPeakGroup");
  }
  {
    double paramst[2] = {5,0.001};
    DetectedPeakGroup t(20,51.1,paramst,paramst+2);
    ok(t.has_same_non_key_parameters(&t),
       "DetectedPeakGroup has same parameters as itself");
  }
  {
    double paramst[2] = {5,0.001};
    double paramstt[1] = {5};
    DetectedPeakGroup t(20,51.1,paramst,paramst+2);
    DetectedPeakGroup tt(20,51.1,paramstt,paramstt+1);
    not_ok(t.has_same_non_key_parameters(&tt),
	   "DetectedPeakGroup has different parameters than "
	   "shorter object.");
  }
  {
    double paramst[1] = {5};
    double paramstt[2] = {5,0.001};
    DetectedPeakGroup t(20,51.1,paramst,paramst+1);
    DetectedPeakGroup tt(20,51.1,paramstt,paramstt+2);
    not_ok(t.has_same_non_key_parameters(&tt),
	   "DetectedPeakGroup has different parameters than "
	   "longer object.");
  }
  {
    double paramst[2] = {5,0.2};
    double paramstt[2] = {5,0.001};
    DetectedPeakGroup t(20,51.1,paramst,paramst+2);
    DetectedPeakGroup tt(20,51.1,paramstt,paramstt+2);
    not_ok(t.has_same_non_key_parameters(&tt),
	   "DetectedPeakGroup has different parameters with same length "
	   "but different last value.");
  }
  {
    double paramst[2] = {5,0.2};
    double paramstt[2] = {5,0.2};
    DetectedPeakGroup t(20,51.1,paramst,paramst+2);
    DetectedPeakGroup tt(20,50,paramstt,paramstt+2);
    not_ok(t.has_same_non_key_parameters(&tt),
	   "DetectedPeakGroup has different parameters with identical "
	   "vectors but different ppm.");
  }
  {
    double paramst[2] = {5,0.2};
    double paramstt[2] = {5,0.2};
    DetectedPeakGroup t(20,51.1,paramst,paramst+2);
    DetectedPeakGroup tt(10,51.1,paramstt,paramstt+2);
    ok(t.has_same_non_key_parameters(&tt),
       "DetectedPeakGroup has same parameters when differ only in "
       "id.");
  }

}
