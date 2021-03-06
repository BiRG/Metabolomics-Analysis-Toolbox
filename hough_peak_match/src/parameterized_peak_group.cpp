#include "utils.hpp"
#include "parameterized_peak_group.hpp"
#include <cassert>
#include "mockable_stringstream.hpp"
#include <iterator>

namespace HoughPeakMatch{
  ParameterizedPeakGroup ParameterizedPeakGroup::from_text_line
  (const std::vector<std::string>& words, bool& failed){
    failed = true;
    ParameterizedPeakGroup ret;
    if(words.size() < 4){ 
      failed = true;  return ret; } 
    
    if(words.at(0) != "parameterized_peak_group"){ 
      failed = true; return ret; }

    
    std::istringstream id_in(words.at(1));
    int id_temp;
    if(!(id_in >> id_temp)){
      failed = true; return ret; }
    if(id_temp < 0){ 
      failed = true; return ret; }
    ret.peak_group_id = id_temp;
    
    std::istringstream ppm_in(words.at(2));
    if(!(ppm_in >> ret.ppm_)) { 
      failed = true; return ret; }
    if(is_special_double(ret.ppm())) { 
      failed = true; return ret; }
    
    
    for(size_t i = 3; i < words.size(); ++i){
      double param_temp;
      std::istringstream param_in(words.at(i));
      if(!(param_in >> param_temp)) { 
	failed = true; return ret; }
      if(is_special_double(param_temp)) { 
	failed = true; return ret; }
      ret.params_.push_back(param_temp);
    }
    assert(ret.params().size() != 0);
    
    failed=false; return ret;
  }

  std::string ParameterizedPeakGroup::to_text() const{
    using namespace std;
    ostringstream out;
    out.precision(17);//All the precision needed to reconstruct a double
    out << "parameterized_peak_group" << " " << id() << " " << ppm() << " ";
    const vector<double> v = params();
    assert(v.size() != 0);//Shouldn't have a space and shouldn't
			  //subtract 1 from end in this case
    copy(v.begin(), v.end()-1, ostream_iterator<double>(out, " "));
    out << v.back() << endl;
    return out.str();
  }

}
