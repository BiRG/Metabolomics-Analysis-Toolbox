#include <exception>
#include <iostream>
#include <utility>
#include <GClasses/GApp.h>
#include <GClasses/GError.h>
#include <GClasses/GMatrix.h>
#include <GClasses/GAssignment.h>

using namespace GClasses;
using std::cerr;
using std::cout;
using std::endl;

///Thrown when there is an expected speedy exit
class expected_exception: public std::exception{
public:
  ///The exit status of the application.
  int exit_status;

  ///Create an expected exception that should cause the given
  ///exit_status to be returned from the application
  expected_exception(int exit_status):exit_status(exit_status){}
};

///\brief Print usage and an optional message before throwing an
///"expected_exception"
void printUsageAndExit(std::ostream& out, const char*executableName, std::string msg=""){
  out 
    << "Usage: " << executableName << " [expected.arff] [predicted.arff] [misclassification|distance]\n"
    << "\n"
    << "Calculate the loss from the predicted spectrum labeling contained \n"
    << "in predicted.arff given that expected.arff contains the expected\n"
    << "spectrum labeling.  Then print the loss to standard output.\n"
    << "\n"
    << "The two arff files must each have three specified fields:\n"
    << "'spectrum identifier' an integer identifier for the spectrom from\n"
    << "                      which the peak comes\n"
    << "'window center index' an integer sample location for the peak in its\n"
    << "                      spectrum\n"
    << "'has peaks'           a nominal value - {false, true}.  True if\n"
    << "                      there is a peak closer to that sample location\n"
    << "                      than to any other.  False otherwise.\n"
    << "                      \n"
    << "\n"
    << "For the distances, each peak is considered to have an x location\n"
    << "at the 'window center index' field in the spectrum identified by\n"
    << "the 'spectrum identifier' field.\n"
    << "\n"
    << "\n"
    << "\n"
    << "There are two loss functions that can be chosen:\n" 
    << "\n"
    << "  misclassification: calculates the fraction of misclassified\n"
    << "                     patterns.\n"
    << "\n"
    << "  distance:          aligns the predicted with the expected peaks\n"
    << "                     and then sums the distances from each to its\n"
    << "                     corresponding peak.  Each distance is capped\n"
    << "                     so its maximum is the window width for the\n"
    << "                     expected peaks file.  Any expected or predicted\n"
    << "                     peak with no corresponding peak is given a\n"
    << "                     value of twice the window width.  Finally the\n"
    << "                     total is divided by the number of expected\n"
    << "                     peaks.\n"
    << "                     \n"
    << "\n"
    << msg << "\n";
    ;
  throw expected_exception(-1);
}

///\brief Return the index of the field named \a name in \a matrix or
///-1 if there is no such field.
///
///\param name The name of the field to locate
///
///\param matrix The matrix in which to locate the field
///
///\return the index of the field named \a name in \a matrix or -1
///if there is no such field.
int fieldIdx(std::string name, const GMatrix& m){
  smart_ptr< const GRelation > r = m.relation();
  for(unsigned i = 0; i < r->size(); ++i){
    if(name == r->attrNameStr(i)){ 
      return i;
    }
  }
  return -1;
}

///\brief A comparator indicating whether two rows of a GMatrix are in
///the original order of the spectra generating the test cases they
///represent.  (The name is an abbreviation for Spectrum Location
///Less-Than.)
class SpectrumLocLess{
  ///\brief The index of the "spectrum identifier" field in the matrix
  ///(will always be non-negative, the int is just to make some parts
  ///of the code easier)
  int specIDIdx;

  ///\brief The index of the "window center index" field in the matrix
  ///(will always be non-negative, the int is just to make some parts
  ///of the code easier)
  int winCenterIdx;

public:
  ///\brief Create a comparator to sort \a m into the original
  ///spectrum order
  ///
  ///\param m A matrix containing fields named "spectrum identifier"
  ///         and "window center index".  A GException is thrown if no
  ///         such fields are present.
  SpectrumLocLess(const GMatrix&m):
    specIDIdx(fieldIdx("spectrum identifier",m)), 
    winCenterIdx(fieldIdx("window center index",m))
  {
    if(specIDIdx < 0){
      ThrowError("Matrix is missing \"spectrum identifier\" field");
    }else if(winCenterIdx < 0){
      ThrowError("Matrix is missing \"window center index\" field");
    }
  }

  ///\brief Return true if \a a comes before \a b in the original
  ///spectrum given that a and b are rows from the matrx from which
  ///this SpectrumLocLess was constructed
  bool operator()(double const*a, double const*b) const{
    if(a[specIDIdx] == b[specIDIdx]){
      return a[winCenterIdx] < b[winCenterIdx];
    }else{
      return a[specIDIdx] < b[specIDIdx];
    }
  }
};



///\brief Sorts \a m into the original order of the
///spectra using "spectrum identifier" and "window center index"
///fields.
///
///\param m a matrix with fields named "spectrum identifier" and
///         "window center index" that will be sorted.
///         
void sortIntoOriginalOrder(GMatrix& m){
  SpectrumLocLess less(m);
  m.sort(less);
}

///\brief Return true iff \a a and \a b have the same contents of the
///same spectra in the same order
///
///Checks to see that the projection onto the "spectrum
///identification" and "window center" fields is identical for the
///matrices a and b
///
///\param a a matrix with "spectrum identifier" and "window center
///         index" fields that will be compared with \a b
///
///\param b a matrix with "spectrum identifier" and "window center
///         index" fields that will be compared with \a a
///
///\return true iff \a a and \a b have the same contents of the same
///spectra in the same order
///
///\throw GException if any of the matrices does not have the required fields
bool haveSameSpectraInSameOrder(const GMatrix& a, const GMatrix& b){
  int aSidx = fieldIdx("spectrum identifier", a);
  int bSidx = fieldIdx("spectrum identifier", b);
  int aCidx = fieldIdx("window center index", a);
  int bCidx = fieldIdx("window center index", b);
  if(aSidx < 0 || bSidx < 0 || aCidx < 0 || bCidx < 0){
    ThrowError("A matrix passed to haveSameSpectraInSameOrder is "
	       "missing either the 'spectrum identifier' "
	       "field or the 'window center index' field.");
  }
  if(a.rows() != b.rows()){ return false; }
  for(std::size_t i = 0; i < a.rows(); ++i){
    if(a[i][aSidx] != b[i][bSidx] || a[i][aCidx] != b[i][bCidx]){
      return false;
    }
  }
  return true;
}

///\brief Return the "window center index" coordinates of all the
///samples that have "has peaks" set to true in the matrix m, the
///peaks in each spectrum are in their own vector.
///
///The returned vectors will be sorted in increasing order by
///"spectrum identifier", that is the spectrum identifier for
///result[0] will be strictly less than the spectrum identifier for
///result[1]
///
///\throw GException if m is missing the "window center index" field,
///                  the "spectrum identifier" field, or the "has
///                  peaks" field
///
///\param m the matrix containing the samples whose peaks are to be
///         extracted.  Must have a "window center index" field and a
///         "has peaks" field.  
///
///\return the "window center index" coordinates of all the samples
///that have "has peaks" set to true in the matrix m
std::vector<std::vector<double> > peakLocs(const GMatrix& m){
  int hp  = fieldIdx("has peaks",m);
  int sid = fieldIdx("spectrum identifier",m);
  int wc  = fieldIdx("window center index", m);
  if(hp < 0 || wc < 0 || sid < 0){
    ThrowError("A matrix passed to peakLocs is "
	       "missing either the 'spectrum identifier' "
	       "field, the 'window center index' field, or the "
	       "'has peaks' field.");
  }

  //Make a list of the full coordinates of the peaks in the spectra

  //pks has the full coordinates.  The first entry in the double is
  //the spectrum id and the second the window center index
  std::set<std::pair<double, double> > pks; 

  //sid_set has spectrum ids only
  std::set<double> sid_set; 
  for(size_t i = 0; i < m.rows(); ++i){
    sid_set.insert(m[i][sid]);
    if(m[i][hp]){ //If the sample has peaks
      pks.insert(std::make_pair(m[i][sid], m[i][wc]));
    }
  }

  //Assign one vector to receive the peaks for each spectrum
  std::map<double, int> vec_for_sid;

  int idx = 0;
  std::set<double>::const_iterator sid_iter = sid_set.begin();
  for(;sid_iter != sid_set.end(); ++sid_iter, ++idx){
    vec_for_sid[*sid_iter] = idx;
  }
  

  //Set up the vectors to return
  std::vector<std::vector<double> > result(sid_set.size());
  
  //Fill the appropriate vectors with the appropriate peaks
  std::set<std::pair<double, double> >::const_iterator pk_iter = pks.begin();
  for(; pk_iter != pks.end(); ++pk_iter){
    result[vec_for_sid[pk_iter->first]].push_back(pk_iter->second);
  }
  return result;
}

///\brief Return the width of the window used in creating the dataset
///\a m.  This is the number of fields that have the substring
///"intensity"
unsigned windowWidth(const GMatrix& m){
  unsigned numFields = 0;
  for(unsigned i = 0; i < m.cols(); ++i){
    std::string name = m.relation()->attrNameStr(i);
    if(name.find("intensity") != std::string::npos){
      ++numFields;
    }
  }
  return numFields;
}

///\brief Return the distance loss for the \a expected and \a
///predicted matrix pair
///
///
///\param expected the expected values for correct classification
///                along with the window data in "delta intensity xx"
///                fields, "spectrum identifier" and "window center
///                index" fields.  This is not const because it may be
///                reordered.  When projected onto the "spectrum
///                identifier" and "window center index" fields, must
///                have be the same set as the same projection of \a
///                predicted.  "spectrum identifier" and "window
///                center index" must form a key for the data.
///
///\param predicted the values predicted for the peak location along
///                with "window center index" and "spectrum
///                identifier" fields.  This is not const because it
///                may be reordered.  When projected onto the
///                "spectrum identifier" and "window center index"
///                fields, must have be the same set as the same
///                projection of \a expected. "spectrum identifier"
///                and "window center index" must form a key for the
///                data.
///
///\throw GException if the matrices do not meet the requirements
double distanceLoss(GMatrix& expected, GMatrix& predicted){
  sortIntoOriginalOrder(expected);
  sortIntoOriginalOrder(predicted);
  if(!haveSameSpectraInSameOrder(expected, predicted)){
    ThrowError("The expected and predicted sets have different subsections of spectra.");
  }
    // "  distance:          aligns the predicted with the expected peaks\n"
    // "                     and then sums the distances from each to its\n"
    // "                     corresponding peak.  Each distance is capped\n"
    // "                     so its maximum is the window width for the\n"
    // "                     expected peaks file.  Any expected or predicted\n"
    // "                     peak with no corresponding peak is given a\n"
    // "                     value of twice the window width.\n"
    // "                     \n"

  
  std::vector<std::vector<double> > expectedLocs = peakLocs(expected);
  std::vector<std::vector<double> > predictedLocs = peakLocs(predicted);

  //Calculate a where a[i] is the assignements for spectrum i
  std::vector<GSimpleAssignment> a; a.reserve(expectedLocs.size());
  for(unsigned i = 0; i < expectedLocs.size(); ++i){
    //Calculate the costs of the individual assignments for spectrum i
    GMatrix cost(expectedLocs[i].size(), predictedLocs[i].size());
    for(unsigned r = 0; r < cost.rows(); ++r){
      for(unsigned c = 0; c < cost.cols(); ++c){
	cost[r][c]=abs(expectedLocs[i].at(r) - predictedLocs[i].at(c));
      }
    }
    //Calculate the optimal assignment
    a.push_back(linearAssignment(cost));
  }
  

  
  //Calculate the distance loss for all assigned peaks
  double maxDist = windowWidth(expected);
  double loss = 0;

  for(std::size_t s = 0; s < a.size(); ++s){
    for(std::size_t expIdx = 0; expIdx < a[s].sizeA(); ++expIdx){
      int predIdx = a[s](expIdx);
      if(predIdx >= 0){
	double d = abs(expectedLocs[s].at(expIdx) - 
		       predictedLocs[s].at(predIdx));
	loss += std::min(maxDist, d);
      }
    }
  }
  
  //Count the number of unassigned 
  unsigned numUnassigned = 0;
  for(std::size_t s = 0; s < a.size(); ++s){
    for(std::size_t i = 0; i < a[s].sizeA(); ++i){
      if(a[s](i) < 0){ ++numUnassigned; }
    }
    for(std::size_t i = 0; i < a[s].sizeB(); ++i){
      if(a[s].inverse(i) < 0){ ++numUnassigned; }
    }
  }

  //Add the penalty for unassigned
  double unassignedPenalty = 2*maxDist; 
  loss += unassignedPenalty * numUnassigned;

  //Transform total penalty into average penalty per expected peak
  unsigned numExpected = 0;
  for(std::size_t s = 0; s < a.size(); ++s){
    numExpected += expectedLocs[s].size();
  }
  loss /= numExpected;
  
  return loss;
}

///\brief Return the misclassificaiton loss for the \a expected and \a
///predicted matrix pair
///
///\param expected the expected values for correct classification in
///                the "has peaks" field, along with the window data in
///                "delta intensity xx" fields, "spectrum identifier"
///                and "window center index" fields.  This is not
///                const because it may be reordered.  When projected
///                onto the "spectrum identifier" and "window center
///                index" fields, must have be the same set as the
///                same projection of \a predicted.  "spectrum
///                identifier" and "window center index" must form a
///                key for the data.
///
///\param predicted the values predicted for the peak location in the
///                "has peaks" field, along with "window center index"
///                and "spectrum identifier" fields.  This is not
///                const because it may be reordered.  When projected
///                onto the "spectrum identifier" and "window center
///                index" fields, must have be the same set as the
///                same projection of \a expected. "spectrum
///                identifier" and "window center index" must form a
///                key for the data.
///
///\throw GException if the matrices do not meet the requirements
double misclassificationLoss(GMatrix& expected, GMatrix& predicted){
  sortIntoOriginalOrder(expected);
  sortIntoOriginalOrder(predicted);
  if(!haveSameSpectraInSameOrder(expected, predicted)){
    ThrowError("The expected and predicted sets have different subsections of spectra.");
  }

  int eHp = fieldIdx("has peaks", expected);
  int pHp = fieldIdx("has peaks", predicted);
  if(eHp < 0 || pHp < 0){
    ThrowError("Matrix passed to misclassification loss is missing the 'has peaks' field");
  }

  unsigned incorrect=0;
  for(std::size_t i = 0; i < expected.rows(); ++i){
    if(expected[i][eHp] != predicted[i][pHp]){ ++incorrect; }
  }
  
  return static_cast<double>(incorrect)/static_cast<double>(expected.rows());
}

///\brief Calculate the loss function given by the arguments in \a args
void calcLoss(GArgReader& args){
  const char* exe = args.pop_string();
  if(args.size() != 3){ 
    printUsageAndExit(cerr, exe, 
		      to_str("Wrong number of arguments got ")+ to_str(args.size())+" expected 3."); }
  const char* expectedFName = args.pop_string();
  const char* predictedFName = args.pop_string();
  std::string lossName = args.pop_string();

  //Read expected matrix and check its fields
  GClasses::Holder<GMatrix> expectedMatrix(GMatrix::loadArff(expectedFName));
  if(fieldIdx("spectrum identifier", *expectedMatrix) < 0){
    printUsageAndExit(cerr, exe, "The expected arff file is missing the "
		      "\"spectrum identifier\" field");
  }else if(fieldIdx("window center index", *expectedMatrix) < 0){
    printUsageAndExit(cerr, exe, "The expected arff file is missing the "
		      "\"window center index\" field");
  }else if(fieldIdx("has peaks", *expectedMatrix) < 0){
    printUsageAndExit(cerr, exe, "The expected arff file is missing the "
		      "\"has peaks\" field");
  }else if(fieldIdx("intensity 1", *expectedMatrix) < 0){
    printUsageAndExit(cerr, exe, "The expected arff file is missing the "
		      "\"intensity 1\" field");
  }

  //Read predicted matrix and check its fields
  GClasses::Holder<GMatrix> predictedMatrix(GMatrix::loadArff(predictedFName));
  if(fieldIdx("spectrum identifier", *predictedMatrix) < 0){
    printUsageAndExit(cerr, exe, "The predicted arff file is missing the "
		      "\"spectrum identifier\" field");
  }else if(fieldIdx("window center index", *predictedMatrix) < 0){
    printUsageAndExit(cerr, exe, "The predicted arff file is missing the "
		      "\"window center index\" field");
  }else if(fieldIdx("has peaks", *predictedMatrix) < 0){
    printUsageAndExit(cerr, exe, "The predicted arff file is missing the "
		      "\"has peaks\" field");
  }

  //Do the loss calculations
  if(lossName == "distance"){
    cout << distanceLoss(*expectedMatrix.get(), *predictedMatrix.get())
	 << endl;
  }else if(lossName == "misclassification"){
    cout << misclassificationLoss(*expectedMatrix.get(), *predictedMatrix.get())
	 << endl;
  }else{
    printUsageAndExit(cerr, exe,
		      to_str('"')+lossName+
		      "\" is not a known loss function name.");
  }
  
}

int main(int argc, char *argv[]){
  GApp::enableFloatingPointExceptions();
  
  int nRet = 0;
  try {
    GArgReader args(argc, argv);
    calcLoss(args);
  } catch(const GException& e){
    cerr << "Error: " << e.what() << std::endl;
  } catch(const expected_exception& e){
    nRet = e.exit_status;
  } catch(const std::exception& e) {
    cerr << "Unhandled exception caught: " << e.what() << "\n";
    nRet = 1;
  }
  
  return nRet;
}

