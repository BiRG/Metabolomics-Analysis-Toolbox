#ifndef STD_MOCK_ISTRINGSTREAM_DECLARATION_HPP
#define STD_MOCK_ISTRINGSTREAM_DECLARATION_HPP

#include <sstream>

namespace std{
  class mock_istringstream: public std::istringstream{
  public:
    mock_istringstream(const std::string& s):std::istringstream(s){}
  };

  mock_istringstream& operator>>(mock_istringstream& in, double& d);
}

#endif //STD_MOCK_ISTRINGSTREAM_DECLARATION_HPP
