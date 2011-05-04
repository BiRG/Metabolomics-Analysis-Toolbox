///\file
///\brief Global utility classes used throughout peak matching
#ifndef HOUGH_PEAK_MATCH_UTILS_HPP
#define HOUGH_PEAK_MATCH_UTILS_HPP

#include <string>
#include <vector>

namespace HoughPeakMatch{

///Split a string on white-space into a vector of strings

///Ignoring starting and ending white-space, extracts all contiguous
///white-space separated substrings in order and puts them in a
///vector.
///
///\code
///split("  The rain  in spain\nFalls mainly on the plain      ");
///\endcode
///
///returns a vector containing the c++ strings, 
///("The", "rain", "in", "spain", "Falls", "mainly", "on", "the", "plain")
///
///\param s The string that will be split
///\returns an array of strings generated by splitting the input string
///\todo write test code
std::vector<std::string> split(const std::string& s);


}

#endif
