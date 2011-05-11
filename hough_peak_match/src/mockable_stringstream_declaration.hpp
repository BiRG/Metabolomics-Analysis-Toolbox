///\file
///\brief Declares std::mock_istringstream without making it replace
///\brief std::istringstream

#ifndef STD_MOCK_ISTRINGSTREAM_DECLARATION_HPP
#define STD_MOCK_ISTRINGSTREAM_DECLARATION_HPP

#include <sstream>

namespace std{
  ///\brief A class to replace std::istringstream for testing
  ///
  ///Adds an operator>>(mock_istringstream, double) that is guaranteed
  ///to extract infinite and nan values
  class mock_istringstream: public std::istringstream{
  public:
    ///\brief Construct a stringstream that reads from \a s
    ///\param s The string to read from
    mock_istringstream(const std::string& s):std::istringstream(s){}
  };

  ///\brief Read the next double from \a in and put it in \a d
  ///
  ///Treats "inf" as the double infinity value and "nan" as the quiet
  ///double not-a-number value
  ///
  ///\param in The stringstream to read from
  ///
  ///\param d The double where the result will be put
  ///
  ///\return \a in after the read has completed
  mock_istringstream& operator>>(mock_istringstream& in, double& d);
}

#endif //STD_MOCK_ISTRINGSTREAM_DECLARATION_HPP
