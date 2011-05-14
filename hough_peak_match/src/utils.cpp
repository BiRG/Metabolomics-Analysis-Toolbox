#include "utils.hpp"
#include <sstream>
#include <cctype>
#include <algorithm>

namespace HoughPeakMatch{
std::vector<std::string> split(const std::string& s){
  std::stringstream in(s);
  std::string cur;
  std::vector<std::string> out;
  while(in >> cur){
    out.push_back(cur);
  }
  return out;
}

bool is_special_double(double d){ 
  return is_nan(d) 
    || d==std::numeric_limits<double>::infinity()
    || -d==std::numeric_limits<double>::infinity();
}

bool contains_white_space(const std::string s){
  return std::find_if(s.begin(), s.end(), isspace) != s.end();
}

}
