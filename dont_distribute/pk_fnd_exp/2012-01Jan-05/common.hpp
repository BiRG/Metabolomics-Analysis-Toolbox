#include <exception>

#ifndef BAYES_COMMON_HPP
#define BAYES_COMMON_HPP

///Thrown when there is an expected speedy exit
class expected_exception: public std::exception{
public:
  ///The exit status of the application.
  int exit_status;

  ///Create an expected exception that should cause the given
  ///exit_status to be returned from the application
  expected_exception(int exit_status):exit_status(exit_status){}
};


#endif //BAYES_COMMON_HPP
