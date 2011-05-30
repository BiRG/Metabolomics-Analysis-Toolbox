#include "params_extractor.hpp"
#include "unique_parameter_ordering.hpp"
#include "peak_matching_database.hpp"
#include "utils.hpp"
#include <algorithm>

namespace HoughPeakMatch{
  namespace{
    ///\brief A row in the matrix of parameters from all database objects
    typedef std::vector<double> Row;

    ///\brief Functional that compares two rows by looking at whether
    ///their sorted contents are lexically in order
    struct RowSortedLessThan{
      ///\brief returns true if sorted \a a_orig lexically comes 
      ///before \a b_orig
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
    ///database
    class Column:public std::vector<double>{
    public:
      ///\param The index this column had before being
      ///reordered
      std::size_t original_index;

      ///\brief create a colum with \a v as contents and \a
      ///original_index as the original index
      ///
      ///\param original_index the index this column had before being
      ///reordered
      ///
      ///\param v the contents of this column
      Column(std::size_t original_index=0, 
	     const std::vector<double>& v=std::vector<double>()):
	std::vector<double>(v),original_index(original_index){}      
    };
  }
  UniqueParameterOrdering::UniqueParameterOrdering(const PeakMatchingDatabase& pmd)
    :occupant(){
    using std::vector; using std::transform; using std::size_t;
    using std::back_insert_iterator;
    using Private::ParamsExtractor;
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
