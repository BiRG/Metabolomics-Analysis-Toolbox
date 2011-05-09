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
    ///\todo change all the from_text_line functions to from_text_line
    ///functions
    void from_text_line(){
      using std::string; using std::vector; using namespace TAP;
      typedef vector<string> vstr;
      bool failed;
      {
	string in1[4]={"unknown_peak","22","25","0.52"};
	UnknownPeak p1 = UnknownPeak::from_text_line(vstr(in1,in1+4), failed);
	is(failed, false, "Unknown peak 1 constructs with no errors");

	
      }
    }
  }
}

int main(){
  TAP::plan(1);
  HoughPeakMatch::Test::from_text_line();
  return TAP::exit_status();
}
