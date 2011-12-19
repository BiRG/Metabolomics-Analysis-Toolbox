#include <exception>
#include <iostream>
#include <GClasses/GApp.h>
#include <GClasses/GError.h>
#include <GClasses/GMatrix.h>

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
void printUsageAndExit(std::ostream& out, GArgReader& args, std::string msg=""){
  out 
    << "Usage: " << args.peek() << " [expected.arff] [predicted.arff] [misclassification|distance]\n"
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
    << "                     corresponding peak.  Any expected or predicted\n"
    << "                     peak with no corresponding peak is given a\n"
    << "                     value of twice the distance from the lowest\n"
    << "                     point location to the highest.\n"
    << "                     \n"
    << "\n"
    << msg << "\n";
    ;
  throw expected_exception(-1);
}

///\brief Return the distance loss for the \a expected and \a
///predicted matrix pair
double distanceLoss(const GMatrix& expected, const GMatrix& predicted){
  //TODO: stub
  return -1;
}

///\brief Return the misclassificaiton loss for the \a expected and \a
///predicted matrix pair
double misclassificationLoss(const GMatrix& expected, const GMatrix& predicted){
  //TODO: stub
  return -1;
}

///\brief Calculate the loss function given by the arguments in \a args
void calcLoss(GArgReader& args){
  if(args.size() != 3){ printUsageAndExit(cerr, args); }
  const char* expectedFName = args.pop_string();
  const char* predictedFName = args.pop_string();
  std::string lossName = args.pop_string();
  GClasses::Holder<GMatrix> expectedMatrix(GMatrix::loadArff(expectedFName));
  GClasses::Holder<GMatrix> predictedMatrix(GMatrix::loadArff(predictedFName));
  

  if(lossName == "distance"){
    cerr << "Warning: distance loss function is not yet implemented.\n";
    cout << distanceLoss(*expectedMatrix.get(), *predictedMatrix.get());
  }else if(lossName == "misclassification"){
    cerr << "Warning: misclassification loss function is yet unimplemented.\n";
    cout << misclassificationLoss(*expectedMatrix.get(), *predictedMatrix.get());
  }else{
    printUsageAndExit(cerr, args,
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
  } catch(const expected_exception& e){
    nRet = e.exit_status;
  } catch(const std::exception& e) {
    cerr << "Unhandled exception caught: " << e.what() << "\n";
    nRet = 1;
  }
  
  return nRet;
}

