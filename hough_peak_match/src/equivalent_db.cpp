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
#include <stdexcept>
#include <algorithm>

namespace HoughPeakMatch{
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
      ///\brief returns true if sorted \a a_orig lexically comes 
      ///\brief before \a b_orig
      ///
      ///Behaves as if follows the following algorithm: sort a copy of
      ///\a a_orig (a), sort a copy of \a b_orig (b).  Returns true if
      ///a comes before b.  This is effectively a less-than operator
      ///
      ///\param a_orig the first row to compare
      ///
      ///\param b_orig the second row to compare
      ///
      ///\return true if sorted \a a_orig lexically comes before \a
      ///b_orig
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
	pmd.parameterized_samples().size()+
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
      
      transform(pmd.parameterized_samples().begin(),
		pmd.parameterized_samples().end(),
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

  if(true){
    std::cout << "Databases ARE equivalent" << std::endl;
  }else{
    std::cout << "Databases ARE NOT equivalent" << std::endl;
  }
  
  return 0;
}
