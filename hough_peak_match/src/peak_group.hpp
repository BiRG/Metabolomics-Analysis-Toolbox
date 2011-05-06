///\file
///\brief Declares the PeakGroup class

#ifndef HOUGH_PEAK_MATCH_PEAK_GROUP
#define HOUGH_PEAK_MATCH_PEAK_GROUP

namespace HoughPeakMatch{

///A grouping to which peaks can be assigned
class PeakGroup{
protected:
  ///\brief Non-negative integer uniquely identifying this peak group
  ///\brief among all others
  unsigned peak_group_id;
public:
  ///\brief Create an uninitialized PeakGroup object
  PeakGroup():peak_group_id(){}
  
  ///\brief Create a PeakGroup object with the given id
  ///
  ///\param id the number that uniquely identifies this PeakGroup
  ///object
  PeakGroup(unsigned id):peak_group_id(id){}
  
  ///\brief Returns the peak_group_id for this PeakGroup object
  ///
  ///\return the peak_group_id for this PeakGroup
  virtual unsigned id() const{ return peak_group_id; }
  virtual ~PeakGroup(){}
};

}
#endif //HOUGH_PEAK_MATCH_PEAK_GROUP
