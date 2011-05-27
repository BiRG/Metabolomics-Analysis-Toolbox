#include "key_relation.hpp"

namespace HoughPeakMatch{

  namespace{
    typedef std::set<KeySptr> KeySet;
  }

  KeySet KeyRelation::project_first(){
    KeySet ret=std::set<KeySptr>();
    typename KeySet::iterator last = ret.begin();
    for(iterator cur = begin(); cur != end(); ++cur){
      last = ret.insert(last, cur->first);
    }
    return ret;
  }

  KeySet KeyRelation::project_second(){
    KeySet ret=std::set<KeySptr>();
    typename KeySet::iterator last = ret.begin();
    for(iterator cur = begin(); cur != end(); ++cur){
      last = ret.insert(last, cur->second);
    }
    return ret;
  }

}
