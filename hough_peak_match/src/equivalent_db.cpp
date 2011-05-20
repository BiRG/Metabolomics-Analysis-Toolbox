///\file
///\brief Main routine and supporting code for the equivalent_db executable

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

#include "utils.hpp"
#include <set> //For multiset
#include <sstream>
#include <stdexcept>
#include <algorithm>

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
    ///\brief Represents a unique parameter ordering for a particular
    ///\brief PeakMatchingDatabase
    ///
    ///This parameter ordering depends only on the contents of the
    ///database not on the external keys.  It can be applied to
    ///parameter vectors to reorder them in this unique/canonical
    ///ordering
    class ParameterOrdering{
      ///\brief occupant[i] gives the original index of the value to
      ///\brief occupy position i in the reordered array
      std::vector<std::size_t> occupant;
    public:
      ///\brief Extract the parameter ordering for \a pmd
      ///
      ///\param pmd The database whose canonical ordering is to be
      ///extracted
      ParameterOrdering(const PeakMatchingDatabase& pmd);

      ///\brief Return the given vector reordered into this ordering
      ///
      ///\param v The vector whose elements will be reordered for the
      ///return value.  Must have the same number of elements as the
      ///number of parameters in the PeakMatchingDatabase used to
      ///initialize this ParameterOrdering
      ///
      ///\return the given vector reordered into this ordering
      ///
      ///\throw invalid_argument if v has the wrong number of elements
      template<class T>
      std::vector<T> return_reordered(const std::vector<T>& v) const{
	using std::size_t;
	if(v.size() != occupant.size()){
	  throw std::invalid_argument("ERROR: Vector with the wrong number "
				      "of elements passed to "
				      "ParameterOrdering::return_reordered");
	}
	typename std::vector<T> ret(v.size());
	typename std::vector<T>::iterator out = ret.begin();
	typename std::vector<size_t>::const_iterator in_idx = occupant.begin();
	while(out != ret.end()){
	  *out = v.at(*in_idx);
	  ++out; ++in_idx;
	}
	return ret;
      }
    };

    ///\brief A row in the matrix of parameters from all database objects
    typedef std::vector<double> Row;

    ///\brief Functional that extracts the parameters in an object
    struct ParamsExtractor{
      ///\brief Returns the parameters for an object of type T
      ///
      ///\param t The object whose parameters are being extracted
      ///
      ///\return the parameters for an instance of type T
      template<class T>
      inline Row operator()(const T& t) const{ 
	return t.params(); }
    };
    
    /// @cond SUPPRESS

    ///\brief Specialization returning the parameters in a
    ///\brief ParamStats object
    ///
    ///\param ps The ParamStats object whose parameters are being extracted
    ///
    ///\return the parameters for the ParamStats object
    template<>
      inline Row ParamsExtractor::operator()(const ParamStats& ps) const{ 
      return ps.frac_variances(); }

    /// @endcond 

    ///\brief Functional that compares two rows by looking at whether
    ///\brief their sorted contents are lexically in order
    struct RowSortedLessThan{
      bool operator()(const Row& a_orig, const Row& b_orig) const{
	Row a=a_orig; Row b=b_orig;
	sort(a.begin(),a.end());
	sort(b.begin(),b.end());
	return a < b;
      }
    };

    ///\brief A column of the parameter vectors for all objects in the
    ///\brief database
    class Column:public std::vector<double>{
    public:
      ///\param The index this column had before being
      ///reordered
      std::size_t original_index;

      ///\brief create a colum with \a v as contents and \a
      ///\brief original_index as the original index
      ///
      ///\param original_index the index this column had before being
      ///reordered
      ///
      ///\param v the contents of this column
      Column(std::size_t original_index=0, 
	     const std::vector<double>& v=std::vector<double>()):
	std::vector<double>(v),original_index(original_index){}      
    };

    ParameterOrdering::ParameterOrdering(const PeakMatchingDatabase& pmd)
      :occupant(){
      using std::vector; using std::transform; using std::size_t;
      using std::back_insert_iterator;
      //Extract the list of parameters (one object per row)
      size_t num_objects = pmd.parameterized_peak_groups().size()+
	pmd.detected_peak_groups().size()+
	pmd.sample_params().size()+
	pmd.param_stats().size();
      vector<Row> rows; rows.reserve(num_objects);
      back_insert_iterator<vector<Row> > inserter = 
	std::back_inserter(rows);
      transform(pmd.parameterized_peak_groups().begin(),
		pmd.parameterized_peak_groups().end(),
		inserter, ParamsExtractor());
      
      transform(pmd.detected_peak_groups().begin(),
		pmd.detected_peak_groups().end(),
		inserter, ParamsExtractor());
      
      transform(pmd.sample_params().begin(),
		pmd.sample_params().end(),
		inserter, ParamsExtractor());
      
      transform(pmd.param_stats().begin(),
		pmd.param_stats().end(),
		inserter, ParamsExtractor());      

      //Sort lexically by sorted rows (treat each row as a set)
      std::sort(rows.begin(), rows.end(), RowSortedLessThan());

      //Transpose the matrix into columns (that remember their
      //original index) - note that this step depends on pmd elements
      //all having the same number of parameters (which should be an
      //invariant of the object)
      size_t num_params = 0;
      if(rows.size() > 0){ num_params = rows.at(0).size(); }
      vector<Column> cols; cols.reserve(num_params);
      for(size_t col = 0; col < num_params; ++col){
	Column c(col); c.reserve(num_objects);
	for(vector<Row>::const_iterator row = rows.begin(); 
	    row != rows.end(); ++row){
	  c.push_back(row->at(col));
	}
	cols.push_back(c);
      }

      //Sort columns lexically 
      sort(cols.begin(), cols.end());

      //Store this ordering in occupant
      for(size_t col = 0; col < cols.size(); ++col){
	occupant.push_back(cols.at(col).original_index);
      }      
    }

    
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
      ///\brief The ordering of the parameters to use in the flattened
      ///\brief peak groups
      ParameterOrdering ordering_;
    public:
      ///\brief Create a Flattener that flattens
      ///\brief ParameterizedPeakGroups from the database \a db
      ///
      ///\param db The database from which come the
      ///
      ///\param ordering The ordering of the parameters to use in the flattened
      ///peak groups.
      ParameterizedPeakGroupFlattener(const PeakMatchingDatabase& db,
				      const ParameterOrdering& ordering)
	:Flattener(db), ordering_(ordering){}
      
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
	  << " "; space_separate(o, ordering_.return_reordered(f.params()));
	return o.str();
      }
    };

    ///\brief Flattens DetectedPeakGroups from one db
    class DetectedPeakGroupFlattener:public Flattener{
      ///\brief The ordering of the parameters to use in the flattened
      ///\brief peak groups
      ParameterOrdering ordering_;
    public:
      ///\brief Create a Flattener that flattens
      ///\brief DetectedPeakGroups from the database \a db
      ///
      ///\param db The database from which come the
      ///
      ///\param ordering The ordering of the parameters to use in the flattened
      ///peak groups.
      DetectedPeakGroupFlattener(const PeakMatchingDatabase& db,
				 const ParameterOrdering& ordering)
	:Flattener(db), ordering_(ordering){}
      
      ///\brief Return a flattened representation of the given
      ///\brief DetectedPeakGroup
      ///
      ///Returns a string that uniquely represents this detected
      ///peak group within its database and that has no references to
      ///other objects
      ///
      ///\param f The peak group to flatten
      ///
      ///\return Return a flattened representation of the given
      ///DetectedPeakGroup
      std::string operator()(const DetectedPeakGroup& f) const{
	std::ostringstream o;
	o << "detected_peak_group " << f.ppm() 
	  << " "; space_separate(o, ordering_.return_reordered(f.params()));
	return o.str();
      }
    };

  }

  PMDatabaseSemantics::PMDatabaseSemantics(const PeakMatchingDatabase& pmd)
    :contents(){
    ParameterOrdering ordering(pmd);
    std::multiset<std::string> tmp = 
      flatten(pmd.parameterized_peak_groups(),
	      ParameterizedPeakGroupFlattener(pmd,ordering));
    contents.insert(tmp.begin(), tmp.end());

    tmp=flatten(pmd.detected_peak_groups(),
		DetectedPeakGroupFlattener(pmd,ordering));
    contents.insert(tmp.begin(), tmp.end());

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
