#include <tap++/tap++.h>

///\brief Test assertion that two collections are equal - TAP producer
///
///Test routine in the style of libtap++.  Given iterators bounding
///two sequences/collections returns true and does not fail if their
///elements all compare equal by operator == and they are the same
///size.  Fails otherwise.  Produces output for the Test Anything
///Protocol.
///
///\param got_begin iterator pointing to the first element of the
///actual collection generated
///
///\param got_end iterator pointing one past the end of the actual
///collection generated
///
///\param expected_begin iterator pointing to the first element of the
///expected collection
///
///\param expected_end iterator pointing one past the end of the
///expected collection
///
///\param message a human-readable message identifying the assertion
///being tested
///
///\return true if the two collections are identical, false otherwise
template<class ForwardIterA, class ForwardIterB>
bool collection_is(ForwardIterA got_begin, ForwardIterA got_end, 
		   ForwardIterB expected_begin, ForwardIterB expected_end, 
		   const std::string& message = "") {
  using namespace TAP;
  std::size_t index = 0;
  ForwardIterA got_cur = got_begin;
  ForwardIterB expected_cur = expected_begin;
  try {
    while(got_cur != got_end && expected_cur != expected_end){
      bool same = *got_cur == *expected_cur;
      if(!same){
	fail(message);
	diag(details::failed_test_msg()," '", message, "'");
	diag(" Collections differ at index: ", index);
	diag(" Got: ", *got_cur);
	diag(" Expected: ", *expected_cur);
	return false;
      }
      ++index;
      ++got_cur;
      ++expected_cur;
    }
    if(got_cur == got_end && expected_cur != expected_end){
      fail(message);
      diag(details::failed_test_msg()," '", message, "'");
      diag(" Got: a collection of length ", index);
      diag(" Expected: a longer collection");
      return false;
    }else if(got_cur != got_end && expected_cur == expected_end){
      fail(message);
      diag(details::failed_test_msg()," '", message, "'");
      diag(" Got: a collection that had more than ", index, " elements");
      diag(" Expected: a collection with ", index," elements");
      return false;
    }else{
      pass(message);
      return true;
    }
  }
  catch(const std::exception& e) {
    fail(message);
    diag(details::failed_test_msg()," '", message, "'");
    diag("Caught exception '", e.what(), "'");
    diag(" At index: ", index);
    return false;
  }
  catch(...) {
    fail(message);
    diag(details::failed_test_msg()," '", message, "'");
    diag("Cought unknown exception");
    diag(" At index: ", index);
    return false;
  }   
}

