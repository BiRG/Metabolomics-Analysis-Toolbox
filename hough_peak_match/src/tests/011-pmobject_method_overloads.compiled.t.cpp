#include "../param_stats.hpp"
#include "../unknown_peak.hpp"
#include "../human_verified_peak.hpp"
#include "../unverified_peak.hpp"

#include <tap++/tap++.h>
#include <string>
#include <memory> //for auto_ptr

int main(){
  using namespace TAP; using namespace HoughPeakMatch;
  using std::auto_ptr;
  plan(30);

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
}
