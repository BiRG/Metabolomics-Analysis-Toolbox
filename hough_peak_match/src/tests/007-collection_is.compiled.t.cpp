#include "../collection_is.hpp"

int main(){
  using namespace TAP;
  plan(15);
  //First, test the collection_is function
  int col1[3] = {1,2,3};
  int col2[3] = {1,2,3};
  int col3[3] = {1,2,4};

  collection_is(col1,col1,col2,col2,"Two empty collections are identical");

  collection_is(col1,col1+1,col2,col2+1,"Two equal 1 element collections");

  collection_is(col1,col1+3,col2,col2+3,"Two equal 3 element collections");

  TODO="Failing test to test the test harness";
  bool lastResult = collection_is(col1,col1,col2,col2+1,"Should be todo");
  TODO="";
  not_ok(lastResult,"Got zero length, expected length 1");

  TODO="Failing test to test the test harness";
  lastResult = collection_is(col1,col1+1,col2,col2,"Should be todo");
  TODO="";
  not_ok(lastResult,"Got length 1, expected length 0");

  TODO="Failing test to test the test harness";
  lastResult = collection_is(col1,col1+1,col2,col2+3,"Should be todo");
  TODO="";
  not_ok(lastResult,"Got length 1, expected length 3");

  TODO="Failing test to test the test harness";
  lastResult = collection_is(col1,col1+3,col2,col2+1,"Should be todo");
  TODO="";
  not_ok(lastResult,"Got length 3, expected length 1");

  TODO="Failing test to test the test harness";
  lastResult = collection_is(col1,col1+2,col2+1,col2+3,"Should be todo");
  TODO="";
  not_ok(lastResult,"Expected 1 got 2 at index 0");

  TODO="Failing test to test the test harness";
  lastResult = collection_is(col1,col1+3,col3,col3+3,"Should be todo");
  TODO="";
  not_ok(lastResult,"Expected 4 got 3 at index 2");

  return exit_status();
}
