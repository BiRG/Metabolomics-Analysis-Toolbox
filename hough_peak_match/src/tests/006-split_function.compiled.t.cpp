#include <tap++/tap++.h>
#include "../utils.hpp"
 
int main(){
  using namespace TAP;
  using HoughPeakMatch::split;
  using std::vector;
  using std::string;
  plan(4);

  string rainExpected[9]={"The", "rain", "in", "spain", 
			 "Falls", "mainly", "on", "the", "plain"};
  vector<string> rainGot
    =split("  The rain  in spain\nFalls mainly on the plain      ");
  collection_is(rainGot.begin(), rainGot.end(),
		rainExpected, rainExpected+9,
		"The rain in spain splits correctly in the main.");

  string emptyExpected[1]={""};
  vector<string> emptyGot=split("");
  collection_is(emptyGot.begin(), emptyGot.end(),
		emptyExpected, emptyExpected,
		"Empty string: good splitting zing");

  vector<string> whitespaceGot=split("\t \n   \t\n\n");
  collection_is(whitespaceGot.begin(), whitespaceGot.end(),
		emptyExpected, emptyExpected,
		"Lightning splits whitespace into nothing");
  

  string peakGroupExpected[4]={"parameterized_peak_group",
			      "2","3.58942133448949","-1.17405428075406"};
  vector<string> peakGroupGot
    =split("parameterized_peak_group 2 3.58942133448949 -1.17405428075406\n");
  collection_is(peakGroupGot.begin(), peakGroupGot.end(),
		peakGroupExpected, peakGroupExpected+4,
		"Peak group line is split correctly (not poetically).");
  
  return exit_status();
}
