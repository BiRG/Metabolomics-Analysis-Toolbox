#include "../mockable_stringstream.hpp"
#include <tap++/tap++.h>

int main(){
  using namespace TAP;
  plan(1);

  double d;
  {
    std::istringstream s("");
    is(!(s>>d),true, "mockable_stringstream returns failure on empty string.");
  }

  return exit_status();
}
