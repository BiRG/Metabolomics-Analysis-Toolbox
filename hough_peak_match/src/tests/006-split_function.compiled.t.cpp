#include <tap++/tap++.h>

int main(){
  using namespace TAP;
  plan(1);
  ok(1==1,"Yep, its ok");
  return exit_status();
}
