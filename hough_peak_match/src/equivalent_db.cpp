///\file
///\brief Main routine and supporting code for the equivalent_db executable

#include "mapping_list.hpp"
#include "object_type.hpp"
#include "unique_parameter_ordering.hpp"
#include "key_relation.hpp"
#include "peak_matching_database.hpp"
#include <iostream>
#include <cstdlib> //For exit

///\brief Print error message and usage information before exiting with an error
///
///Prints the usage message for equivalent_db and then prints errMsg
///(followed by a newline) before finally exiting with a -1 error
///code.  Does not return.
///
///\param errMsg the error message to print after the usage message
void print_usage_and_exit(std::string errMsg){
  std::cerr 
    << "Synopsis: equivalent_db database_1 database_2\n"
    << "\n"
    << "Reads the two given peak database files and reports whether \n"
    << "they describe equivalent databases, that is, databases that \n"
    << "describe the same real-world information but with file-level \n"
    << "differences like changes in line ordering or in object id numbers.\n"
    << "\n"
    << "Writes to standard output, prints:\n"
    << "    \"Databases ARE equivalent\" if the databases are equivalent,\n"
    << "    \"Databases ARE NOT equivalent\" if the databases are not \n"
    << "                                     equivalent\n"
    << "\n"
    << errMsg << "\n";
  std::exit(-1);
}

namespace HoughPeakMatch{

std::ostream& operator<<(std::ostream& out, const std::set<KeySptr>& set){
  out << "{KeySet: ";
  std::set<KeySptr>::const_iterator it;
  for(it = set.begin(); it != set.end(); ++it){
    const Key* k = it->get();
    if(k != NULL){
      out << k->to_string();
    }else{
      out << "(NULL Key pointer)";
    }
  }
  return out << "}";
}

std::ostream& operator<<(std::ostream& out, const std::vector<KeySptr>& vec){
  out << "{KeyVector: ";
  std::vector<KeySptr>::const_iterator it;
  for(it = vec.begin(); it != vec.end(); ++it){
    const Key* k = it->get();
    if(k != NULL){
      out << k->to_string();
    }else{
      out << "(NULL Key pointer)";
    }
  }
  return out << "}";
}

bool have_same_non_key_parameters(KeySptr k1, KeySptr k2){
  std::auto_ptr<PMObject> o1 = k1->obj_copy();
  std::auto_ptr<PMObject> o2 = k2->obj_copy();
  
  return o1->has_same_non_key_parameters(o2.get());
}

bool are_equivalent(PeakMatchingDatabase db1, PeakMatchingDatabase db2){
  using std::set;
  UniqueParameterOrdering o1(db1);
  db1.reorder_with(o1);
  UniqueParameterOrdering o2(db2);
  db2.reorder_with(o2);

  set<KeySptr> k1,k2;

  KeyRelation r;

  const unsigned num_otypes = 8;
  ObjectType otypes[num_otypes] = 
    {ObjectType("param_stats"), ObjectType("human_verified_peak"), 
     ObjectType("unverified_peak"), ObjectType("unknown_peak"), 
     ObjectType("parameterized_sample"), ObjectType("unparameterized_sample"), 
     ObjectType("detected_peak_group"), ObjectType("parameterized_peak_group")};

  for(ObjectType* ot = otypes; ot != otypes+num_otypes; ++ot){
    set<KeySptr> db1_keys = db1.keys_for_type(*ot);
    set<KeySptr> db2_keys = db2.keys_for_type(*ot);

    k1.insert(db1_keys.begin(), db1_keys.end());
    k2.insert(db2_keys.begin(), db2_keys.end());
    
    {
      set<KeySptr>::iterator it1, it2;
      for(it1 = db1_keys.begin(); it1 != db1_keys.end(); ++it1){
	for(it2 = db2_keys.begin(); it2 != db2_keys.end(); ++it2){
	  if(have_same_non_key_parameters(*it1, *it2)){
	    r.insert(std::make_pair(*it1,*it2));
	  }
	}
      }
    }

    if(r.project_first() != k1){ 
      return false; 
    }else if(r.project_second() != k2){
      return false;
    }

  }

  MappingList maps = r;
  MappingListConstIterator cur = maps.begin();
  while(cur != maps.end()){    
    if(cur.keys() != k1){
      ++cur; continue;
    }
    if(cur.values() != k2){
      ++cur; continue;
    }

    //DEBUG
    const bool dbg = false;
    if(dbg){
      for(std::set<KeySptr>::const_iterator k = k1.begin(); k != k1.end(); ++k){
	std::cerr << "<" << ((*k)->to_string()) << "," 
		  << (cur(*k)->to_string()) << ">";
      }
      std::cerr << "\n";
    }
    //end DEBUG
    
    //Check for two keys mapping to the same value
    std::set<KeySptr> seen;
    bool bad_mapping = false;
    for(std::set<KeySptr>::const_iterator k = k1.begin(); k != k1.end(); ++k){
      if(seen.count(cur(*k)) != 0){
	bad_mapping = true; break;
      }else{
	seen.insert(cur(*k));
      }
    }
    if(bad_mapping){
      ++cur; continue;
    }

    if(dbg) std::cerr << "Good mapping\n";//DEBUG

    //Check for equivalence under the mapping
    for(std::set<KeySptr>::iterator k = k1.begin(); k != k1.end(); ++k){
      std::auto_ptr<PMObject> o1 = (*k)->obj_copy();
      std::auto_ptr<PMObject> o2 = cur(*k)->obj_copy();
      if(o1->type() != o2->type()){
	if(dbg) std::cerr << "Bad type\n";//DEBUG
	bad_mapping = true; break;
      }else if(! o1->has_same_non_key_parameters(o2.get()) ){
	if(dbg) std::cerr << "Bad non-key params\n";//DEBUG
	bad_mapping = true; break;
      }else{
	//if the keys are different after transforming the keys of the
	//first object then we have a bad mapping
	std::vector<KeySptr> fk1_raw = o1->foreign_keys(db1);
	std::vector<KeySptr> fk1_transformed; 
	fk1_transformed.reserve(fk1_raw.size());
	for(std::vector<KeySptr>::iterator it=fk1_raw.begin(); 
	    it != fk1_raw.end(); ++it){
	  KeySptr it_xformed = cur(*it);
	  fk1_transformed.push_back(it_xformed);
	}
	std::vector<KeySptr> fk2 = o2->foreign_keys(db2);
	if(fk1_transformed != fk2){
	  if(dbg) std::cerr << "Bad transformed keys\n";//DEBUG
	  if(dbg) std::cerr << "fk1_raw: " << fk1_raw << "\n";//DEBUG
	  if(dbg) std::cerr << "fk1: " << fk1_transformed << "\n";//DEBUG
	  if(dbg) std::cerr << "fk2: " << fk2 << "\n";//DEBUG
	  bad_mapping = true; break;
	}
      }
    }

    if(!bad_mapping){
      return true;
    }else{
      ++cur;
    }
  }

  //All mappings were bad
  return false;
}

}
///\brief The main routine for equivalent_db
///
///\param argc The number of elements in the argv vector
///
///\param argv The command line arguments to this program - an array of strings
///
///\return error status to the operating system
int main(int argc, char**argv){
  using namespace HoughPeakMatch;
  if(argc != 3){
    print_usage_and_exit("ERROR: Wrong number of arguments");
  }

  PeakMatchingDatabase db1 = 
    read_database(argv[1],"the first", print_usage_and_exit);
  PeakMatchingDatabase db2 = 
    read_database(argv[2],"the second", print_usage_and_exit);

  if(are_equivalent(db1,db2)){
    std::cout << "Databases ARE equivalent" << std::endl;
  }else{
    std::cout << "Databases ARE NOT equivalent" << std::endl;
  }
  
  return 0;
}
