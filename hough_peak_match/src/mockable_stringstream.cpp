#include "mockable_stringstream_declaration.hpp"
#include <limits>

std::mock_istringstream& std::operator>>
(std::mock_istringstream& in, double& d){
  typedef std::numeric_limits<double> lims;
  std::string tmp; 
  if(!(in>>tmp)){
    return in;
  }else{
    std::stringstream double_in(tmp);
    if(double_in.operator>>(d)){ 
      return in;
    }else{
      if(tmp == "inf"){
	d = lims::infinity(); return in;
      }else if(tmp == "nan" && lims::has_quiet_NaN){
	d = lims::quiet_NaN(); return in;	    
      }else{
	in.setstate(double_in.rdstate());
	return in;
      }
    }
  }
}
