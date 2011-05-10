///\file
///\brief Tests the xxx::from_text_line functions

#include <tap++/tap++.h>
#include "../unknown_peak.hpp"
#include "../parameterized_peak_group.hpp"
#include "../param_stats.hpp"
#include "../sample_params.hpp"
#include "../detected_peak_group.hpp"
#include "../unverified_peak.hpp"
#include "../sample.hpp"
#include "../human_verified_peak.hpp"

namespace HoughPeakMatch{
  namespace Test{
    ///\brief Exercise all the *::from_text_line functions
    ///
    ///Note: only checks that they construct what is expected from
    ///valid input.  The invalid input is checked using the black-box
    ///tests from valid_db.  In theory it could be tested here too,
    ///but that would be a lot of extra work -- and probably
    ///duplication of effort.
    void from_text_line(){
      using std::string; using std::vector; using namespace TAP;
      typedef vector<string> vstr;
      bool failed;
      {
	string in1[5]={"detected_peak_group","33","4.45","35","-0.59"};
	DetectedPeakGroup p1 = DetectedPeakGroup::from_text_line
	  (vstr(in1,in1+5), failed);
	is(failed, false, "Detected peak group 1 constructs with no errors");
	is(p1.id(), 33,"Detected peak group 1 has expected peak_group_id");
	is(p1.ppm(), 4.45,"Detected peak group 1 has expected ppm");
	double params1[2]={35,-0.59};
	collection_is(p1.params().begin(), p1.params().end(),
		      params1,params1+2,
		      "Detected peak group 1 has expected params vector");

	string in2[4]={"detected_peak_group","55","11.9","389"};
	DetectedPeakGroup p2 = DetectedPeakGroup::from_text_line
	  (vstr(in2,in2+4), failed);
	is(failed, false, "Detected peak group 2 constructs with no errors");
	is(p2.id(), 55,"Detected peak group 2 has expected peak_group_id");
	is(p2.ppm(), 11.9,"Detected peak group 2 has expected ppm");
	double params2[2]={389};
	collection_is(p2.params().begin(), p2.params().end(),
		      params2,params2+1,
		      "Detected peak group 2 has expected params vector");

	//With bad input name
	{
	  string in[4]={"sample","55","11.9","389"};
	  DetectedPeakGroup pg=DetectedPeakGroup::from_text_line
	    (vstr(in,in+4), failed);
	  is(failed, true, 
	     "Detected peak group fails for wrong input line-type.");
	}

	//With NAN ppm
	{
	  string in[4]={"sample","55","nan","389"};
	  DetectedPeakGroup pg=DetectedPeakGroup::from_text_line
	    (vstr(in,in+4), failed);
	  is(failed, true, 
	     "Detected peak group fails nan ppm.");
	}

	//With INF ppm
	{
	  string in[4]={"sample","55","inf","389"};
	  DetectedPeakGroup pg=DetectedPeakGroup::from_text_line
	    (vstr(in,in+4), failed);
	  is(failed, true, 
	     "Detected peak group fails inf ppm.");
	}
	
	//With NAN param
	{
	  string in[4]={"sample","55","2.1","nan"};
	  DetectedPeakGroup pg=DetectedPeakGroup::from_text_line
	    (vstr(in,in+4), failed);
	  is(failed, true, 
	     "Detected peak group fails nan param.");
	}

	//With INF param
	{
	  string in[4]={"sample","55","2.1","inf"};
	  DetectedPeakGroup pg=DetectedPeakGroup::from_text_line
	    (vstr(in,in+4), failed);
	  is(failed, true, 
	     "Detected peak group fails inf param.");
	}

      }
      {
	string in1[5]={"parameterized_peak_group","33","4.45","35","-0.59"};
	ParameterizedPeakGroup p1 = ParameterizedPeakGroup::from_text_line
	  (vstr(in1,in1+5), failed);
	is(failed, false, "Parameterized peak group 1 constructs with no errors");
	is(p1.id(), 33,"Parameterized peak group 1 has expected peak_group_id");
	is(p1.ppm(), 4.45,"Parameterized peak group 1 has expected ppm");
	double params1[2]={35,-0.59};
	collection_is(p1.params().begin(), p1.params().end(),
		      params1,params1+2,
		      "Parameterized peak group 1 has expected params vector");

	string in2[4]={"parameterized_peak_group","55","11.9","389"};
	ParameterizedPeakGroup p2 = ParameterizedPeakGroup::from_text_line
	  (vstr(in2,in2+4), failed);
	is(failed, false, "Parameterized peak group 2 constructs with no errors");
	is(p2.id(), 55,"Parameterized peak group 2 has expected peak_group_id");
	is(p2.ppm(), 11.9,"Parameterized peak group 2 has expected ppm");
	double params2[2]={389};
	collection_is(p2.params().begin(), p2.params().end(),
		      params2,params2+1,
		      "Parameterized peak group 2 has expected params vector");
      }
      {
	string in1[3]={"sample","22","class_name"};
	Sample p1 = Sample::from_text_line(vstr(in1,in1+3), failed);
	is(failed, false, "Sample 1 constructs with no errors");
	is(p1.id(), 22,"Sample 1 has expected id");
	is(p1.sample_class(), "class_name","Sample 1 has expected class");
      }
      {
	string in1[3]={"param_stats","0.95","0.05"};
	ParamStats p1 = ParamStats::from_text_line(vstr(in1,in1+3), failed);
	is(failed, false, "Param stats 1 constructs with no errors");
	double stats1[2]={0.95,0.05};
	collection_is(p1.frac_variances().begin(), p1.frac_variances().end(),
		      stats1,stats1+2,
		      "Param stats 1 has expected stats vector");

	string in2[2]={"param_stats",".02"};
	ParamStats p2 = ParamStats::from_text_line(vstr(in2,in2+2), failed);
	is(failed, false, "Param stats 2 constructs with no errors");
	double stats2[1]={0.02};
	collection_is(p2.frac_variances().begin(), p2.frac_variances().end(),
		      stats2,stats2+1,
		      "Param stats 2 has expected stats vector");
      }
      {
	string in1[4]={"sample_params","22","25","-0.52"};
	SampleParams p1 = SampleParams::from_text_line(vstr(in1,in1+4), failed);
	is(failed, false, "Sample params 1 constructs with no errors");
	is(p1.sample_id(), 22,"Sample params 1 has expected sample_id");
	double params1[2]={25,-0.52};
	collection_is(p1.params().begin(), p1.params().end(),
		      params1,params1+2,
		      "Sample params 1 has expected params vector");

	string in2[3]={"sample_params","1","11"};
	SampleParams p2 = SampleParams::from_text_line(vstr(in2,in2+3), failed);
	is(failed, false, "Sample params 2 constructs with no errors");
	is(p2.sample_id(), 1,"Sample params 2 has expected sample_id");
	double params2[1]={11};
	collection_is(p2.params().begin(), p2.params().end(),
		      params2,params2+1,
		      "Sample params 2 has expected params vector");
      }
      {
	string in1[4]={"unknown_peak","22","25","0.52"};
	UnknownPeak p1 = UnknownPeak::from_text_line(vstr(in1,in1+4), failed);
	is(failed, false, "Unknown peak 1 constructs with no errors");
	is(p1.sample_id(), 22,"Unknown peak 1 has expected sample_id");
	is(p1.peak_id(), 25,"Unknown peak 1 has expected peak_id");
	is(p1.ppm(), 0.52,"Unknown peak 1 has expected ppm");
      }
      {
	string in1[5]={"unverified_peak","2","5","0.12","11"};
	UnverifiedPeak p1 = 
	  UnverifiedPeak::from_text_line(vstr(in1,in1+5), failed);
	is(failed, false, "Unverified peak 1 constructs with no errors");
	is(p1.sample_id(), 2,"Unverified peak 1 has expected sample_id");
	is(p1.peak_id(), 5,"Unverified peak 1 has expected peak_id");
	is(p1.ppm(), 0.12,"Unverified peak 1 has expected ppm");
	is(p1.peak_group_id(), 11,
	   "Unverified peak 1 has expected peak_group_id");
      }
      {
	string in1[5]={"human_verified_peak","2","5","0.12","11"};
	HumanVerifiedPeak p1 = 
	  HumanVerifiedPeak::from_text_line(vstr(in1,in1+5), failed);
	is(failed, false, "Human verified peak 1 constructs with no errors");
	is(p1.sample_id(), 2,"Human verified peak 1 has expected sample_id");
	is(p1.peak_id(), 5,"Human verified peak 1 has expected peak_id");
	is(p1.ppm(), 0.12,"Human verified peak 1 has expected ppm");
	is(p1.peak_group_id(), 11,
	   "Human verified peak 1 has expected peak_group_id");
      }
    }
  }
}

int main(){
  TAP::plan(48);
  HoughPeakMatch::Test::from_text_line();
  return TAP::exit_status();
}
