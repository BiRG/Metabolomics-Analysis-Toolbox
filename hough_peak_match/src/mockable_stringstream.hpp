#include <sstream>

#ifdef USE_MOCK_ISTRINGSTREAM
namespace std{
  class mock_istringstream: public std::istringstream{
  public:
    mock_istringstream(const std::string& s):std::istringstream(s){}
    mock_istringstream& operator>>(double& d){
      typedef std::numeric_limits<double> lims;
      std::string tmp; 
      if(!((*this)>>tmp)){
	return *this;
      }else{
	std::stringstream in(tmp);
	if(in >> d){ 
	  return *this; 
	}else{
	  if(tmp == "inf"){
	    d = lims::infinity(); return *this;
	  }else if(tmp == "nan" && lims::has_quiet_NaN){
	    d = lims::quiet_NaN(); return *this;	    
	  }else{
	    std::ios_base::iostate st = in.rdstate();
	    setstate(st);
	    return *this;
	  }
	}
      }
    }
  };
  
}

#define istringstream mock_istringstream
#endif //USE_MOCK_ISTRINGSTREAM
