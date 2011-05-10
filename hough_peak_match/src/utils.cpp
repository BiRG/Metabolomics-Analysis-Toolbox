#include "utils.hpp"
#include "mockable_stringstream.hpp"

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

}
