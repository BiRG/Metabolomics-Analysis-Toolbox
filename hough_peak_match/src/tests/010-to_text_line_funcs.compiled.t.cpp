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
#include <limits>

namespace HoughPeakMatch{
  namespace Test{

    ///\brief Exercise all the various to_text_line functions and the
    ///\brief constructors
    void to_text_line(){
      using std::string; using std::vector; using namespace TAP;
      using std::endl; using std::make_pair; using std::ostringstream;
      using std::invalid_argument; using std::numeric_limits;
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
	  ostringstream expected;
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
	  ostringstream expected;
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
      
      
      //HumanVerifiedPeak
      
      
      {
	HumanVerifiedPeak p(65537, 1024*1024*1024, 1.11, 13);
	is(p.id(), make_pair(65537u,1024*1024*1024u),
	   "Human verified peak constructor gives correct id");
	is(p.sample_id(), 65537,
	   "Human verified peak constructor gives correct sample_id");
	is(p.peak_id(), 1024*1024*1024,
	   "Human verified peak constructor gives correct peak_id");
	is(p.ppm(),1.11,
	   "Human verified peak constructor gives correct ppm");
	is(p.peak_group_id(),13,
	   "Human verified peak constructor gives correct peak_group_id");
	ostringstream expected;
	expected << "human_verified_peak 65537 1073741824 1.11 13" << endl;
	is(p.to_text_line(), expected.str(),
	   "Human verified peak to_text_line gives expected output");
      }
      {
	if(numeric_limits<double>::has_infinity){
	  bool threw = false;
	  std::string msg = "no message because the constructor did not throw";
	  double inf = numeric_limits<double>::infinity();
	  try{
	    HumanVerifiedPeak p(65537, 1024*1024*1024, inf, 13);
	  }catch (invalid_argument& e){
	    threw = true;
	    msg = e.what();
	  }
	  is(threw,true,"HumanVerifiedPeak throws exception "
	     "with infinite ppm");
	  ostringstream expected_msg;
	  expected_msg 
	    << "HoughPeakMatch::HumanVerifiedPeak was passed "
	    << "an invalid ppm value: " << inf;
	  is(msg, expected_msg.str(),
	     "Human verified peak infinite ppm exception error "
	     "message is correct");
	}else{
	  skip(2,"No infinite double");
	}
      }
      
      {
	if(numeric_limits<double>::has_quiet_NaN){
	  bool threw = false;
	  std::string msg = "no message because the constructor did not throw";
	  double nan = numeric_limits<double>::quiet_NaN();
	  try{
	    HumanVerifiedPeak p(65537, 1024*1024*1024, nan, 13);
	  }catch (invalid_argument& e){
	    threw = true;
	    msg = e.what();
	  }
	  is(threw,true,"HumanVerifiedPeak throws exception "
	     "with not-a-number ppm");
	  ostringstream expected_msg;
	  expected_msg 
	    << "HoughPeakMatch::HumanVerifiedPeak was passed "
	    << "an invalid ppm value: " << nan;
	  is(msg, expected_msg.str(),
	     "Human verified peak not-a-number ppm exception error "
	     "message is correct");
	}else{
	  skip(2,"No quiet-NaN value for double");
	}
      }
    }
  }
}


///\brief test harness wrapper around HoughPeakMatch::Test::to_text_line();
///
///\return the appropriate exit status for TAP (the test-anything-protocol)
int main(){
  TAP::plan(22);
  HoughPeakMatch::Test::to_text_line();
  return TAP::exit_status();
}
