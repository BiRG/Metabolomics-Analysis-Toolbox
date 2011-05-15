///\file
///\brief Main routine and supporting code for the equivalent_db executable

#include "utils.hpp"
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

#include <set> //For multiset
#include <sstream>

namespace HoughPeakMatch{
///\brief A unique encoding of the semantics of a PeakMatchinDatabase
///\biief for comparing the semantics of two databses
///
///PeakMatchingDatabase objects are designed for easy serialization to
///a format that can be read in other languages and easy conversion
///to/from the data forms needed by the various peak-matching
///algorithms.  However, they are not easy to semantically compare.  A
///PMDatabaseSemantics re-encodes the semantics of the database (what
///objects exist with which parameters and connected to what other
///objects) in a form that is easy to compare.
class PMDatabaseSemantics{
private:
  std::multiset<std::string> contents;
public:
  ///\brief Create a PMDatabaseSemantics that encodes the semantics of \a pmd
  PMDatabaseSemantics(const PeakMatchingDatabase& pmd);

  ///\brief Return whether the two databases are semantically the same
  ///
  ///\return True if the two databases have the same underlying
  ///semantic content and false otherwise
  bool operator==(const PMDatabaseSemantics& rhs) const{
    return std::equal(contents.begin(), contents.end(),
		      rhs.contents.begin());
  }
};
  namespace{
    ///\brief Returns a unique string-multiset representation for a
    ///\brief collection of objects
    ///
    ///Given a collection specified by \a begin and \a end
    ///(one-past-the-end, as usual), applies \a flatten to each and
    ///adds the elements to the given multiset.
    ///
    ///\param c The collection to be flattened
    ///
    ///\param flatten A function object that can be treated as if it
    ///had the signature <code>std::string
    ///flatten(InputIter::value_type& o)</code>
    template<class Collection, class FlattenerT>
      std::multiset<std::string> flatten(const Collection & c,
					 FlattenerT flatten){
      typename Collection::const_iterator cur = c.begin();
      std::multiset<std::string> ret;
      while(cur != c.end()){
	ret.insert(flatten(*cur));
	++cur;
      }
      return ret;
    }

    ///\brief Base class encapsulating common functionality for
    ///\brief flattener objects
    class Flattener{
    protected:
      ///\brief the database with respect to which the objects will be
      ///\brief flattened
      const PeakMatchingDatabase& db;
      ///\brief Construct a Flattener that initializes the database to db
      ///
      ///\param db the database used to resolve references in flattening
      Flattener(const PeakMatchingDatabase& db):db(db){}
      virtual ~Flattener(){}
    };

    ///\brief Flattens ParameterizedPeakGroups from one db
    class ParameterizedPeakGroupFlattener:public Flattener{
    public:
      ///\brief Create a Flattener that flattens
      ///\brief ParameterizedPeakGroups from the database \a db
      ///
      ///\param db The database from which come the
      ///ParameterizedPeakGroup objects flattened by this flattener
      ParameterizedPeakGroupFlattener(const PeakMatchingDatabase& db):
	Flattener(db){}
      
      ///\brief Return a flattened representation of the given
      ///\brief ParameterizedPeakGroup
      ///
      ///Returns a string that uniquely represents this parameterized
      ///peak group within its database and that has no references to
      ///other objects
      ///
      ///\param f The peak group to flatten
      ///
      ///\return Return a flattened representation of the given
      ///ParameterizedPeakGroup
      std::string operator()(const ParameterizedPeakGroup& f) const{
	std::ostringstream o;
	o << "parameterized_peak_group " << f.ppm() 
	  << " "; space_separate(o, f.params());
	return o.str();
      }
    };
  }

  PMDatabaseSemantics::PMDatabaseSemantics(const PeakMatchingDatabase& pmd)
    :contents(){
    std::multiset<std::string> tmp = 
      flatten(pmd.parameterized_peak_groups(),
	      ParameterizedPeakGroupFlattener(pmd));
    contents.insert(tmp.begin(), tmp.end());
    ///\todo write for detected_peak_group

    ///\todo write for human_verified_peak

    ///\todo write for unverified_peak

    ///\todo write for unknown_peak

    ///\todo write for sample

    ///\todo write for sample_params
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

  PMDatabaseSemantics cpmd1(db1);
  PMDatabaseSemantics cpmd2(db2);

  if(cpmd1==cpmd2){
    std::cout << "Databases ARE equivalent" << std::endl;
  }else{
    std::cout << "Databases ARE NOT equivalent" << std::endl;
  }
  
  return 0;
}
