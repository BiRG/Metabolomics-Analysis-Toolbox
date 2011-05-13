///\file
///\brief Tests the xxx::to_text_line functions and constructors for
///\brief peak database objects

#include "../unknown_peak.hpp"
#include "../parameterized_peak_group.hpp"
#include "../param_stats.hpp"
#include "../sample_params.hpp"
#include "../detected_peak_group.hpp"
#include "../unverified_peak.hpp"
#include "../sample.hpp"
#include "../human_verified_peak.hpp"
#include <tap++/tap++.h>
#include <sstream>

namespace HoughPeakMatch{
  namespace Test{

    ///\brief Exercise all the various to_text_line functions and the
    ///\brief constructors
    void to_text_line(){
      using std::string; using std::vector; using namespace TAP;
      using std::endl;
      {
	//ParameterizedPeakGroup

	{
	  double params[3]={2,1,5};
	  ParameterizedPeakGroup p(150, 3.5, params, params+3);
	  is(p.id(),150,
	     "Parameterized Peak group constructor gives correct id");
	  is(p.ppm(),3.5,
	     "Parameterized Peak group constructor gives correct ppm");
	  vector<double> p_params=p.params();
	  collection_is(p_params.begin(), p_params.end(), 
			params,params+3,
			"Parameterized peak group constructor "
			"gives correct params");
	  std::ostringstream expected;
	  expected << "parameterized_peak_group 150 3.5 2 1 5" << endl;
	  is(p.to_text_line(), expected.str(),
	     "Parameterized peak group to_text_line gives expected output");
	}
	{
	  bool threw = false;
	  std::string msg = "no message because the constructor did not throw";
	  try{
	    double params[1]={2};
	    ParameterizedPeakGroup p(150, 3.5, params, params+0);
	  }catch (no_params_exception& e){
	    threw = true;
	    msg = e.what();
	  }
	  is(threw,true,"ParameterizedPeakGroup throws exception "
	     "with empty params vector");
	  is(msg,
	     string("HoughPeakMatch::ParameterizedPeakGroup "
		    "received an empty parameter vector in its "
		    "constructor."),
	     "Parameterized peak group no params exception error "
	     "message is correct");
	}

	//DetectedPeakGroup


	{
	  double params[3]={2,1,5};
	  DetectedPeakGroup p(150, 3.5, params, params+3);
	  is(p.id(),150,
	     "Detected Peak group constructor gives correct id");
	  is(p.ppm(),3.5,
	     "Detected Peak group constructor gives correct ppm");
	  vector<double> p_params=p.params();
	  collection_is(p_params.begin(), p_params.end(), 
			params,params+3,
			"Detected peak group constructor "
			"gives correct params");
	  std::ostringstream expected;
	  expected << "detected_peak_group 150 3.5 2 1 5" << endl;
	  is(p.to_text_line(), expected.str(),
	     "Detected peak group to_text_line gives expected output");
	}
	{
	  bool threw = false;
	  std::string msg = "no message because the constructor did not throw";
	  try{
	    double params[1]={2};
	    DetectedPeakGroup p(150, 3.5, params, params+0);
	  }catch (no_params_exception& e){
	    threw = true;
	    msg = e.what();
	  }
	  is(threw,true,"DetectedPeakGroup throws exception "
	     "with empty params vector");
	  is(msg,
	     string("HoughPeakMatch::DetectedPeakGroup "
		    "received an empty parameter vector in its "
		    "constructor."),
	     "Detected peak group no params exception error "
	     "message is correct");
	}
      }
    }
  }
}

///\brief test harness wrapper around HoughPeakMatch::Test::to_text_line();
///
///\return the appropriate exit status for TAP (the test-anything-protocol)
int main(){
  TAP::plan(12);
  HoughPeakMatch::Test::to_text_line();
  return TAP::exit_status();
}
