#ifndef HOUGH_PEAK_MATCH_PEAK_MATCHING_DATABASE
#define HOUGH_PEAK_MATCH_PEAK_MATCHING_DATABASE
#include <iostream>

///Holds all the library classes for the Hough peak matching prototype
namespace HoughPeakMatch{
  
  ///Common database for the Hough peak matching tools

  ///The Hough peak matching executables work on a common data object
  ///model whose relationships are shown in the following
  ///diagram. (Arrows denote is_a/subclass relationship pointing from
  ///the subclass to the superclass.)
  ///
  ///One constraint that is not drawn in the diagram is that the
  ///parameter vectors in sample params objects and in peak group
  ///objects must have the same dimension.
  ///
  ///\image html hough_peak_match_database_object_model.png
  ///
  ///The PeakMatchingDatabase object encapsulates this database.  It
  ///allows reading, writing, and manipulating the databases as well
  ///as transforming them into structures that are more appropriate
  ///for direct computation.
  ///
  ///All of the peak matching documents use a
  ///\ref file_format_docs "common file format"
  class PeakMatchingDatabase{
  public:
    ///Create an empty PeakMatchingDatabase

    ///
    ///\todo Write default constructor for PeakMatchingDatabase
    PeakMatchingDatabase(){}

    ///Read database from the given stream replacing current contents
    
    ///\param in the stream to read the new contents from.
    ///
    ///\return true on success and false on failure.  On failure the
    ///database contents will be left unchanged.
    bool read(std::istream& in);
  };
  
}

#endif //HOUGH_PEAK_MATCH_PEAK_MATCHING_DATABASE
