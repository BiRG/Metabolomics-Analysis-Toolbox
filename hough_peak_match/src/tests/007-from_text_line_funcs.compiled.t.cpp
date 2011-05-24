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

    ///\brief proxy object used for accessing protected methods of KnownPeak
    class KnownPeakProxy:public KnownPeak{
    public:
      ///\brief construct uninitialized KnownPeakProxy
      KnownPeakProxy():KnownPeak(){}

      ///\brief public Access to KnownPeak::initFrom
      ///
      ///\param words \see KnownPeak::initFrom
      ///
      ///\param expected_name \see KnownPeak::initFrom
      ///
      ///\param failed \see KnownPeak::initFrom
      virtual void initFrom(const std::vector<std::string>& words, 
			    const std::string& expected_name, 
			    bool& failed){
	KnownPeak::initFrom(words,expected_name,failed);
      }

      ///\brief Stub method to enable implementation of the proxy -
      ///\brief returns false results
      virtual ObjectType type() const{
	return ObjectType("human_verified_peak");
      }

    };

    ///\brief proxy object used for accessing protected methods of Peak
    class PeakProxy:public Peak{
    public:
      ///\brief construct uninitialized PeakProxy
      PeakProxy():Peak(){}

      ///\brief public Access to Peak::initFrom
      ///
      ///\param words \see Peak::initFrom
      ///
      ///\param expected_name \see Peak::initFrom
      ///
      ///\param failed \see Peak::initFrom
      virtual void initFrom(const std::vector<std::string>& words, 
			    const std::string& expected_name, 
			    bool& failed){
	Peak::initFrom(words,expected_name,failed);
      }

      ///\brief Stub method to enable implementation of the proxy -
      ///\brief returns false results
      virtual ObjectType type() const{
	return ObjectType("human_verified_peak");
      }

    };

    ///\brief Exercise all the various from_text_line functions
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
	  string in[4]={"detected_peak_group","55","nan","389"};
	  DetectedPeakGroup pg=DetectedPeakGroup::from_text_line
	    (vstr(in,in+4), failed);
	  is(failed, true, 
	     "Detected peak group fails nan ppm.");
	}

	//With INF ppm
	{
	  string in[4]={"detected_peak_group","55","inf","389"};
	  DetectedPeakGroup pg=DetectedPeakGroup::from_text_line
	    (vstr(in,in+4), failed);
	  is(failed, true, 
	     "Detected peak group fails inf ppm.");
	}
	
	//With NAN param
	{
	  string in[4]={"detected_peak_group","55","2.1","nan"};
	  DetectedPeakGroup pg=DetectedPeakGroup::from_text_line
	    (vstr(in,in+4), failed);
	  is(failed, true, 
	     "Detected peak group fails nan param.");
	}

	//With INF param
	{
	  string in[4]={"detected_peak_group","55","2.1","inf"};
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


	//With bad input name
	{
	  string in[4]={"sample","55","11.9","389"};
	  ParameterizedPeakGroup pg=ParameterizedPeakGroup::from_text_line
	    (vstr(in,in+4), failed);
	  is(failed, true, 
	     "Parameterized peak group fails for wrong input line-type.");
	}

	//With NAN ppm
	{
	  string in[4]={"parameterized_peak_group","55","nan","389"};
	  ParameterizedPeakGroup pg=ParameterizedPeakGroup::from_text_line
	    (vstr(in,in+4), failed);
	  is(failed, true, 
	     "Parameterized peak group fails nan ppm.");
	}

	//With INF ppm
	{
	  string in[4]={"parameterized_peak_group","55","inf","389"};
	  ParameterizedPeakGroup pg=ParameterizedPeakGroup::from_text_line
	    (vstr(in,in+4), failed);
	  is(failed, true, 
	     "Parameterized peak group fails inf ppm.");
	}
	
	//With NAN param
	{
	  string in[4]={"parameterized_peak_group","55","2.1","nan"};
	  ParameterizedPeakGroup pg=ParameterizedPeakGroup::from_text_line
	    (vstr(in,in+4), failed);
	  is(failed, true, 
	     "Parameterized peak group fails nan param.");
	}

	//With INF param
	{
	  string in[4]={"parameterized_peak_group","55","2.1","inf"};
	  ParameterizedPeakGroup pg=ParameterizedPeakGroup::from_text_line
	    (vstr(in,in+4), failed);
	  is(failed, true, 
	     "Parameterized peak group fails inf param.");
	}


      }
      {
	string in1[3]={"sample","22","class_name"};
	Sample p1 = Sample::from_text_line(vstr(in1,in1+3), failed);
	is(failed, false, "Sample 1 constructs with no errors");
	is(p1.id(), 22,"Sample 1 has expected id");
	is(p1.sample_class(), "class_name","Sample 1 has expected class");

	//With bad input name
	{
	  string in[3]={"vafafkasdfhjk","22","class_name"};
	  Sample p = Sample::from_text_line(vstr(in,in+3), failed);
	  is(failed, true, "Sample fails when given bad input name");
	}

	//With blank class name
	{
	  string in[3]={"sample","1",""};
	  Sample p = Sample::from_text_line(vstr(in,in+3), failed);
	  is(failed, true, "Sample fails when given blank class name");
	}

	//With white space in class name
	{
	  string in[3]={"sample","1",""};
	  const unsigned num_chars = 6;
	  char white_char[num_chars]={' ','\t','\n','\v','\r','\f'};
	  string white_char_name[num_chars]=
	    {"space","tab","newline","vertical tab",
	     "carriage return","form feed"};
  
	  for(unsigned i = 0; i < num_chars; ++i){
	    bool failed = false;

	    in[2] = string("begin")+white_char[i]+"end";
	    Sample::from_text_line(vstr(in,in+3), failed);
	    is(failed, true, "Sample fails when a "+white_char_name[i]
	       +" is in the middle of the class name.");
	    
	    in[2] = string("begin")+white_char[i];
	    Sample::from_text_line(vstr(in,in+3), failed);
	    is(failed, true, "Sample fails when a "+white_char_name[i]
	       +" is at the end of the class name.");
	  }
	}

	//With too few arguments
	{
	  string in[3]={"sample","22","class_name"};
	  Sample p = Sample::from_text_line(vstr(in,in+2), failed);
	  is(failed, true, "Sample fails when too few arguments");
	}

	//With too many arguments
	{
	  string in[4]={"sample","22","class_name","12"};
	  Sample p = Sample::from_text_line(vstr(in,in+4), failed);
	  is(failed, true, "Sample fails when too many arguments");
	}
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

	//Bad line type
	{
	  string in[3]={"param__stats","0.95","0.05"};
	  ParamStats p = ParamStats::from_text_line(vstr(in,in+3), failed);
	  is(failed, true, "Param stats fails when given bad line_type");
	}

	//Bad too few input prameters
	{
	  string in[1]={"param__stats"};
	  ParamStats p = ParamStats::from_text_line(vstr(in,in+1), failed);
	  is(failed, true, "Param stats fails when given bad line_type");
	}
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

	//sample_params with bad name
	{
	  string in[4]={"sampleparams","22","25","-0.52"};
	  SampleParams p = SampleParams::from_text_line(vstr(in,in+4), failed);
	  is(failed, true, "Sample params fails with bad name");
	}
      }
      {
	string in1[4]={"unknown_peak","22","25","0.52"};
	UnknownPeak p1 = UnknownPeak::from_text_line(vstr(in1,in1+4), failed);
	is(failed, false, "Unknown peak 1 constructs with no errors");
	is(p1.sample_id(), 22,"Unknown peak 1 has expected sample_id");
	is(p1.peak_id(), 25,"Unknown peak 1 has expected peak_id");
	is(p1.ppm(), 0.52,"Unknown peak 1 has expected ppm");

	//unknown_peak with bad name
	{
	  string in[4]={"unknownpeak","22","25","0.52"};
	  UnknownPeak p = UnknownPeak::from_text_line(vstr(in,in+4), failed);
	  is(failed, true, "Unknown peak fails with bad name");
	}
	//unknown_peak with too many arguments
	{
	  string in[5]={"unknownpeak","22","25","0.52",".01"};
	  UnknownPeak p = UnknownPeak::from_text_line(vstr(in,in+5), failed);
	  is(failed, true, "Unknown peak fails with too many arguments");
	}
	//unknown_peak with too few arguments
	{
	  string in[3]={"unknownpeak","22","25"};
	  UnknownPeak p = UnknownPeak::from_text_line(vstr(in,in+3), failed);
	  is(failed, true, "Unknown peak fails with too few arguments");
	}
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

	//Wrong name
	{
	  string in[5]={"unknown_peak","2","5","0.12","11"};
	  UnverifiedPeak p = 
	    UnverifiedPeak::from_text_line(vstr(in,in+5), failed);
	  is(failed, true, "Unverified peak from_text_line fails when given wrong name");
	}
      }

      {
	//Known peak: wrong name
	{
	  KnownPeakProxy kp;
	  string in[5]={"kno_peak","2","5","0.1","81"};
	  kp.initFrom(vstr(in,in+5), "known_peak", failed);
	  is(failed, true, "Known peak init fails when given wrong name");
	}
	//Known peak: too short
	{
	  KnownPeakProxy kp;
	  string in[4]={"known_peak","2","5","0.1"};
	  kp.initFrom(vstr(in,in+4), "known_peak", failed);
	  is(failed, true, "Known peak init fails when too few arguments");
	}
      }

      {
	//Peak: wrong name
	{
	  PeakProxy p;
	  string in[4]={"peek","2","5","0.1"};
	  p.initFrom(vstr(in,in+4), "peak", failed);
	  is(failed, true, "Peak init fails when given wrong name");
	}
	//Peak: too long
	{
	  PeakProxy p;
	  string in[5]={"peak","2","5","0.1","righteous"};
	  p.initFrom(vstr(in,in+5), "peak", failed);
	  is(failed, false, "Peak init succeeds when given too many arguments");
	  is(p.ppm(), 0.1,"Peak has correct ppm with too many arguments");
	  is(p.peak_id(), 5, 
	     "Peak has correct peak_id with too many arguments");
	  is(p.sample_id(), 2, 
	     "Peak has correct sample_id with too many arguments");
	  is(p.id(),std::make_pair(2u,5u),
	     "Peak has correct id with too many arguments");
	}
	//Peak: too short
	{
	  PeakProxy p;
	  string in[3]={"peak","2","5"};
	  p.initFrom(vstr(in,in+3), "peak", failed);
	  is(failed, true, "Peak init fails when too few arguments");
	}
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

///\brief test harness wrapper around HoughPeakMatch::Test::from_text_line();
///
///\return the appropriate exit status for TAP (the test-anything-protocol)
int main(){
  TAP::plan(85);
  HoughPeakMatch::Test::from_text_line();
  return TAP::exit_status();
}
