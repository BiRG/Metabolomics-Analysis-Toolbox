///\file
///\brief Tests the xxx::to_text functions and constructors for
///\brief peak database objects

#include "../unknown_peak.hpp"
#include "../parameterized_peak_group.hpp"
#include "../param_stats.hpp"
#include "../file_format_sample_params.hpp"
#include "../detected_peak_group.hpp"
#include "../unverified_peak.hpp"
#include "../file_format_sample.hpp"
#include "../human_verified_peak.hpp"
#include <tap++/tap++.h>
#include <sstream>
#include <limits>

namespace HoughPeakMatch{
  namespace Test{

    ///\brief Exercise all the various to_text functions and the
    ///\brief constructors
    void to_text(){
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
	  is(p.to_text(), expected.str(),
	     "Parameterized peak group to_text gives expected output");
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
	  is(p.to_text(), expected.str(),
	     "Detected peak group to_text gives expected output");
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
	expected << "human_verified_peak 65537 1073741824 1.1100000000000001 13" << endl;
	is(p.to_text(), expected.str(),
	   "Human verified peak to_text gives expected output");
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
	  skip(2,"There is no infinite double on this platform.");
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
	  skip(2,"There is no quiet-NaN value for double on this platform.");
	}
      }
    
      
      //UnverifiedPeak
      
      
      {
	UnverifiedPeak p(65537, 2147483648, 1.11, 21);
	is(p.id(), make_pair(65537u,2147483648u),
	   "Unverified peak constructor gives correct id");
	is(p.sample_id(), 65537,
	   "Unverified peak constructor gives correct sample_id");
	is(p.peak_id(), 2147483648,
	   "Unverified peak constructor gives correct peak_id");
	is(p.ppm(),1.11,
	   "Unverified peak constructor gives correct ppm");
	is(p.peak_group_id(),21,
	   "Unverified peak constructor gives correct peak_group_id");
	ostringstream expected;
	expected << "unverified_peak 65537 2147483648 1.1100000000000001 21" << endl;
	is(p.to_text(), expected.str(),
	   "Unverified peak to_text gives expected output");
      }

      {
	if(numeric_limits<double>::has_infinity){
	  bool threw = false;
	  std::string msg = "no message because the constructor did not throw";
	  double inf = numeric_limits<double>::infinity();
	  try{
	    UnverifiedPeak p(65537, 2147483648, inf, 21);
	  }catch (invalid_argument& e){
	    threw = true;
	    msg = e.what();
	  }
	  is(threw,true,"UnverifiedPeak throws exception "
	     "with infinite ppm");
	  ostringstream expected_msg;
	  expected_msg 
	    << "HoughPeakMatch::UnverifiedPeak was passed "
	    << "an invalid ppm value: " << inf;
	  is(msg, expected_msg.str(),
	     "Unverified peak infinite ppm exception error "
	     "message is correct");
	}else{
	  skip(2,"There is no infinite double on this platform.");
	}
      }
      
      {
	if(numeric_limits<double>::has_quiet_NaN){
	  bool threw = false;
	  std::string msg = "no message because the constructor did not throw";
	  double nan = numeric_limits<double>::quiet_NaN();
	  try{
	    UnverifiedPeak p(65537, 2147483648, nan, 21);
	  }catch (invalid_argument& e){
	    threw = true;
	    msg = e.what();
	  }
	  is(threw,true,"UnverifiedPeak throws exception "
	     "with not-a-number ppm");
	  ostringstream expected_msg;
	  expected_msg 
	    << "HoughPeakMatch::UnverifiedPeak was passed "
	    << "an invalid ppm value: " << nan;
	  is(msg, expected_msg.str(),
	     "Unverified peak not-a-number ppm exception error "
	     "message is correct");
	}else{
	  skip(2,"There is no quiet-NaN value for double on this platform.");
	}
      }

      //UnknownPeak
      
      
      {
	UnknownPeak p(2147483648, 65537, 0.00052);
	is(p.id(), make_pair(2147483648u, 65537u),
	   "Unknown peak constructor gives correct id");
	is(p.sample_id(), 2147483648u,
	   "Unknown peak constructor gives correct sample_id");
	is(p.peak_id(), 65537u,
	   "Unknown peak constructor gives correct peak_id");
	is(p.ppm(), 0.00052,
	   "Unknown peak constructor gives correct ppm");
	ostringstream expected;
	expected << "unknown_peak 2147483648 65537 0.00051999999999999995" << endl;
	is(p.to_text(), expected.str(),
	   "Unknown peak to_text gives expected output");
      }

      {
	if(numeric_limits<double>::has_infinity){
	  bool threw = false;
	  std::string msg = "no message because the constructor did not throw";
	  double inf = numeric_limits<double>::infinity();
	  try{
	    UnknownPeak p(65537, 2147483648, inf);
	  }catch (invalid_argument& e){
	    threw = true;
	    msg = e.what();
	  }
	  is(threw,true,"UnknownPeak throws exception "
	     "with infinite ppm");
	  ostringstream expected_msg;
	  expected_msg 
	    << "HoughPeakMatch::UnknownPeak was passed "
	    << "an invalid ppm value: " << inf;
	  is(msg, expected_msg.str(),
	     "Unknown peak infinite ppm exception error "
	     "message is correct");
	}else{
	  skip(2,"There is no infinite double on this platform.");
	}
      }

      {
	if(numeric_limits<double>::has_quiet_NaN){
	  bool threw = false;
	  std::string msg = "no message because the constructor did not throw";
	  double nan = numeric_limits<double>::quiet_NaN();
	  try{
	    UnknownPeak p(65537, 2147483648, nan);
	  }catch (invalid_argument& e){
	    threw = true;
	    msg = e.what();
	  }
	  is(threw,true,"UnknownPeak throws exception "
	     "with not-a-number ppm");
	  ostringstream expected_msg;
	  expected_msg 
	    << "HoughPeakMatch::UnknownPeak was passed "
	    << "an invalid ppm value: " << nan;
	  is(msg, expected_msg.str(),
	     "Unknown peak not-a-number ppm exception error "
	     "message is correct");
	}else{
	  skip(2,"There is no quiet-NaN value for double on this platform.");
	}
      }


      //FileFormatSample
   

      {
	FileFormatSample s(1022, "My_fair_lady");
	is(s.id(), 1022, "FileFormatSample constructor sets id correctly.");
	is(s.sample_class(), "My_fair_lady","FileFormatSample constructor sets "
	   "sample_class correctly");
	ostringstream expected;
	expected << "sample 1022 My_fair_lady" << endl;
	is(s.to_text(), expected.str(), 
	   "FileFormatSample to_text gives expected output.");
      }
      {
	  bool threw = false;
	  std::string msg = "no message because the constructor did not throw";
	  try{
	    FileFormatSample s(155, "");
	  }catch (invalid_argument& e){
	    threw = true;
	    msg = e.what();
	  }
	  is(threw,true,"UnknownPeak throws exception "
	     "with empty-string sample class");
	  ostringstream expected_msg;
	  expected_msg 
	    << "HoughPeakMatch::FileFormatSample received an empty string for "
	    << "a sample class";

	  is(msg, expected_msg.str(),
	     "FileFormatSample exception message is correct with \"\" sample class");
      }

      {
	const unsigned num_chars = 6;
	char white_char[num_chars]={' ','\t','\n','\v','\r','\f'};
	string white_char_name[num_chars]=
	  {"space","tab","newline","vertical tab",
	   "carriage return","form feed"};
	string expected_msg = "HoughPeakMatch::FileFormatSample received a string "
	  "containing white-space for a sample class";
  
	for(unsigned i = 0; i < num_chars; ++i){
	  string char_in_mid = string("begin")+white_char[i]+"end";
	  string char_at_end = string("begin")+white_char[i];
	  {
	    bool threw = false;
	    string msg = "no message because the constructor did not throw";
	    try{
	      FileFormatSample s(155, char_in_mid);
	    }catch (invalid_argument& e){
	      threw = true;
	      msg = e.what();
	    }
	    is(threw,true,"FileFormatSample throws exception "
	       "with "+white_char_name[i]+" in middle of sample class");
	    is(msg, expected_msg,
	       "FileFormatSample has correct exception message "
	       "with "+white_char_name[i]+" in middle of sample class");
	  }

	  {
	    bool threw = false;
	    string msg = "no message because the constructor did not throw";
	    try{
	      FileFormatSample s(155, char_at_end);
	    }catch (invalid_argument& e){
	      threw = true;
	      msg = e.what();
	    }
	    is(threw,true,"FileFormatSample throws exception "
	       "with "+white_char_name[i]+" at the end of the sample class");
	    is(msg, expected_msg,
	       "FileFormatSample has correct exception message "
	       "with "+white_char_name[i]+" at the end of sample class");
	  }
	}


	//FileFormatSampleParams
            
	{
	  double params[3]={3.8,1,5};
	  FileFormatSampleParams p(150, params, params+3);
	  is(p.sample_id(),150,
	     "File format sample params constructor gives correct sample_id");
	  vector<double> p_params=p.params();
	  collection_is(p_params.begin(), p_params.end(), 
			params,params+3,
			"File format sample params constructor gives correct params");
	  ostringstream expected;
	  expected << "sample_params 150 3.7999999999999998 1 5" << endl;
	  is(p.to_text(), expected.str(),
	     "File format sample params to_text gives expected output");
	}
	{
	  bool threw = false;
	  std::string msg = "no message because the constructor did not throw";
	  try{
	    double params[1]={1};
	    FileFormatSampleParams p(150, params, params+0);
	  }catch (no_params_exception& e){
	    threw = true;
	    msg = e.what();
	  }
	  is(threw,true,"FileFormatSampleParams throws exception with empty "
	     "params vector");
	  is(msg,
	     string("HoughPeakMatch::FileFormatSampleParams "
		    "received an empty parameter vector in its "
		    "constructor."),
	     "File format sample params no params exception error message is correct");
	}
            
      

	//ParamStats
        ///\todo test ParamStats constructor for rejecting sum > 1
	{
	  double params[3]={0.15,0.1,0};
	  ParamStats p(params, params+3);
	  vector<double> p_params=p.frac_variances();
	  collection_is(p_params.begin(), p_params.end(), 
			params,params+3,
			"Param stats constructor gives correct params");
	  ostringstream expected;
	  expected << "param_stats 0.14999999999999999 0.10000000000000001 0" << endl;
	  is(p.to_text(), expected.str(),
	     "Param stats to_text gives expected output");
	}
	{
	  bool threw = false;
	  std::string msg = "no message because the constructor did not throw";
	  try{
	    double params[1]={1};
	    ParamStats p(params, params+0);
	  }catch (no_params_exception& e){
	    threw = true;
	    msg = e.what();
	  }
	  is(threw,true,"ParamStats throws exception with empty "
	     "params vector");
	  is(msg,
	     string("HoughPeakMatch::ParamStats "
		    "received an empty parameter vector in its "
		    "constructor."),
	     "Param stats no params exception error message is correct");
	}
      
	{
	  bool threw = false;
	  std::string msg = "no message because the constructor did not throw";
	  try{
	    double params[2]={0.55,0.5};
	    ParamStats p(params, params+2);
	  }catch (invalid_argument& e){
	    threw = true;
	    msg = e.what();
	  }
	  is(threw,true,"ParamStats throws exception when frac_variances "
	     "sums to greater than 1.");
	  is(msg,
	     string("HoughPeakMatch::ParamStats "
		    "received fractions of total variance totalling "
		    "to more than 1."),
	     "Param stats too big frac_variances error message is correct");
	}

	{
	  bool threw = false;
	  try{
	    double params[2]={0.5,0.5};
	    ParamStats p(params, params+2);
	  }catch (invalid_argument& e){
	    threw = true;
	  }
	  is(threw,false,"ParamStats throws no exception when frac_variances "
	     "sums to exactly 1.");
	}
      }      
    }
  }
}


///\brief test harness wrapper around HoughPeakMatch::Test::to_text();
///
///\return the appropriate exit status for TAP (the test-anything-protocol)
int main(){
  TAP::plan(82);
  HoughPeakMatch::Test::to_text();
  return TAP::exit_status();
}
