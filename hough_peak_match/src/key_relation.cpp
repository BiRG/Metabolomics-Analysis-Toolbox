#include "key_relation.hpp"

namespace HoughPeakMatch{

  namespace{
    typedef boost::shared_ptr<Key> pKey;
    typedef std::set<pKey, DereferenceLess> KeySet;
  }

  KeySet KeyRelation::project_first(){
    KeySet ret=std::set<pKey, DereferenceLess>(DereferenceLess());
    typename KeySet::iterator last = ret.begin();
    for(iterator cur = begin(); cur != end(); ++cur){
      last = ret.insert(last, cur->first);
    }
    return ret;
  }

  KeySet KeyRelation::project_second(){
    KeySet ret=std::set<pKey, DereferenceLess>(DereferenceLess());
    typename KeySet::iterator last = ret.begin();
    for(iterator cur = begin(); cur != end(); ++cur){
      last = ret.insert(last, cur->second);
    }
    return ret;
  }

}
