#include "peak_matching_database.hpp"
namespace HoughPeakMatch{
void remove_sample_params_from(HoughPeakMatch::PeakMatchingDatabase& db){
  using namespace HoughPeakMatch;
  using std::vector;
  vector<ParameterizedSample>::iterator ps;
  for(ps = db.parameterized_samples().begin(); 
      ps != db.parameterized_samples().end();
      ++ps){
    db.unparameterized_samples().push_back(ps->without_params());
  }
  db.parameterized_samples().clear();
  assert(db.satisfies_constraints());
}
}
