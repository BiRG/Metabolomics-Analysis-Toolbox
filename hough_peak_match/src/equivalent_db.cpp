///\file
///\brief Main routine and supporting code for the equivalent_db executable

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
    out << k->to_string();
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
  using std::cerr; using std::endl; //DEBUG
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
#if 0
	  if(*ot == ObjectType("detected_peak_group")){ //DEBUG
	    std::auto_ptr<PMObject> o1ap = (*it1)->obj_copy();
	    DetectedPeakGroup*o1 = (DetectedPeakGroup*)o1ap.get();
	    cerr << (o1->to_text());
	    std::auto_ptr<PMObject> o2ap = (*it2)->obj_copy();
	    DetectedPeakGroup*o2 = (DetectedPeakGroup*)o2ap.get();
	    cerr << (o2->to_text());
	    
	  }
#endif
	  if(have_same_non_key_parameters(*it1, *it2)){
	    r.insert(std::make_pair(*it1,*it2));
	  }
	}
      }
    }
#if 0
    std::cerr << "R1:" << (r.project_first()) << std::endl; //DEBUG
    std::cerr << "K1:" << k1 << std::endl;//DEBUG
#endif

    if(r.project_first() != k1){ 
      return false; 
    }else if(r.project_second() != k2){
      return false;
    }

  }

  ///\todo finish -- write all candidate search

  return true;///\todo DEBUG
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
