#include <iostream>
#include <limits>

#ifndef USE_MOCK_ISTRINGSTREAM
#define USE_MOCK_ISTRINGSTREAM
#endif
#include "mockable_stringstream.hpp"

int main(){
  using namespace std;
  string s;
  double d;
  while(cin >> s){
    std::istringstream in(s);
    if(in >> d){
      cout << "You entered: " << d << endl;
    }else{
      cout << "Invalid double" << endl;
    }
  }
  return 0;
}
