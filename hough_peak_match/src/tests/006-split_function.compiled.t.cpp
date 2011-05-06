#include <tap++/tap++.h>
#include "../utils.hpp"
 
int main(){
  using namespace TAP;
  plan(1);
  ok(1==1,"Yep, its ok");

  return exit_status();
}
