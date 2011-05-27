#include "mapping_list.hpp"


namespace HoughPeakMatch{
  MappingListConstIterator MappingList::begin() const{
    return MappingListConstIterator(*this, true);
  }

  MappingListConstIterator MappingList::end() const{
    return MappingListConstIterator(*this, false);
  }


  MappingListConstIterator::MappingListConstIterator
  (const MappingList&ml,bool from_beginning):map(),at_end(!from_beginning){
    if(from_beginning){
      std::map<KeySptr, std::set<KeySptr> >::const_iterator cur;
      for(cur = ml.map.begin(); cur != ml.map.end(); ++cur){
	KeySetConstIteratorTriple t(cur->second.begin(),
				    cur->second.begin(),
				    cur->second.end());
	if(t.begin == t.end){
	  at_end = true; return;
	}else{
	  map[cur->first]=t;
	}
      }
    }
  }
  
  MappingListConstIterator& MappingListConstIterator::operator++(){
    if(at_end){ 
      return *this;
    }

    bool last_key_wrapped_around = true;
    std::map<KeySptr, KeySetConstIteratorTriple>::iterator pair;
    for(pair = map.begin(); pair != map.end(); ++pair){
      KeySetConstIteratorTriple& triple = pair->second;
      ++(triple.cur);
      if(triple.cur != triple.end){
	last_key_wrapped_around = false;
	break;
      }else{
	triple.cur = triple.begin;
      }
    }
    if(last_key_wrapped_around){
      at_end = true;
    }
    return *this;
  }
  
  KeySptr MappingListConstIterator::operator()(KeySptr key) const{
    if(at_end){ 
      return KeySptr(NULL); 
    }else{
      std::map<KeySptr, KeySetConstIteratorTriple>::const_iterator loc;
      loc = map.find(key);
      if(loc == map.end()){
	return KeySptr(NULL); 
      }else{
	assert(loc->second.cur != loc->second.end);
	return *(loc->second.cur);
      }
    }
  }
  
  bool MappingListConstIterator::operator!=
  (const MappingListConstIterator& other){
    if(at_end != other.at_end){
      return true;
    }else{
      return map != other.map;
    }
  }
  
  
  std::set<KeySptr> MappingListConstIterator::keys(){
    std::set<KeySptr> ret;
    std::set<KeySptr>::iterator last = ret.begin();
    std::map<KeySptr, KeySetConstIteratorTriple>::iterator pair;
    for(pair = map.begin(); pair != map.end(); ++pair){
      last = ret.insert(last, pair->first);
    }    
    return ret;
  }
 
  std::set<KeySptr> MappingListConstIterator::values(){
    std::set<KeySptr> ret;
    std::set<KeySptr>::iterator last = ret.begin();
    std::map<KeySptr, KeySetConstIteratorTriple>::iterator pair;
    for(pair = map.begin(); pair != map.end(); ++pair){
      last = ret.insert(last, *(pair->second.cur));
    }    
    return ret;
  }

}
