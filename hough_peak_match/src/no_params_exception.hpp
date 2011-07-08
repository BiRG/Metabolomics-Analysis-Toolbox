///\file
///\brief Declares and defines the no_params_exception

#ifndef HOUGH_PEAK_MATCH_NO_PARAMS_EXCEPTION
#define HOUGH_PEAK_MATCH_NO_PARAMS_EXCEPTION

#include <stdexcept>
#include <string>
namespace HoughPeakMatch{
  ///\brief Thrown when a constructor expecting parameters receives none
  ///
  ///A constructor that takes a non-empty collection of parameters was
  ///passed an empty collection instead.
  class no_params_exception:public std::invalid_argument{
  public:
    ///\brief Creates a no_params_exception reporting that
    ///\a class_name received an empty collection in its constructor
    ///
    ///\param class_name The name of the class whose constructor
    ///received the empty collection
    no_params_exception(std::string class_name):
      std::invalid_argument
      (class_name+" received an empty parameter vector in its constructor.")
    {}
  };
}

#endif //HOUGH_PEAK_MATCH_NO_PARAMS_EXCEPTION
