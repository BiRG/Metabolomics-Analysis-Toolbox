///\file
///\brief Declares and defines the ObjectType
#ifndef HOUGH_PEAK_MATCH_OBJECT_TYPE
#define HOUGH_PEAK_MATCH_OBJECT_TYPE

#include <string>
#include <stdexcept> //For invalid_argument
#include <algorithm> //For find


namespace HoughPeakMatch{
///\brief Represents the type of a given peak matching object
class ObjectType{
  ///\brief The name of the type
  std::string type_name_;
public:
  ///\brief Create a new type object for the type named \a type_name
  ///
  ///\param type_name the name of the type to be represented by this
  ///object.  Valid names include: peak_group, detected_peak_group,
  ///parameterized_peak_group, human_verified_peak, unverified_peak,
  ///unknown_peak, parameterized_sample,
  ///unparameterized_sample, and param_stats
  ///
  ///\throws invalid_argument if \a type_name is not one of the types
  ///of object that are represented directly in the database.  There
  ///should be no: peak, known_peak, file_format_sample,
  ///file_format_sample_params, sample, or sample_params objects.
  ObjectType(std::string type_name):type_name_(type_name){
    const char* valid_types[9]=
      {"peak_group","detected_peak_group","parameterized_peak_group",
       "human_verified_peak",
       "unverified_peak","unknown_peak","parameterized_sample",
       "unparameterized_sample", "param_stats"};
    if(std::find(valid_types, valid_types+9, type_name)==
       valid_types+9){
      throw std::invalid_argument
	("ERROR: "+type_name+" is not a known object type.");
    }
  }

  ///\brief return true iff \a o represents the same type as this
  ///object does
  ///
  ///\param o the object being compared to this one
  ///
  ///\return true iff \a o represents the same type as this object does
  bool operator==(const ObjectType& o) const{
    return type_name_ == o.type_name_;
  }

  ///\brief return true iff \a o does not represent the same type as
  ///this \brief object does
  ///
  ///\param o the object being compared to this one
  ///
  ///\return true iff \a o does not represent the same type as this
  ///object does
  bool operator!=(const ObjectType& o) const{
    return type_name_ != o.type_name_;
  }

  ///\brief return true iff this type sorts strictly before \a o
  ///
  ///No specific ordering (like sorting type names in alphabetical
  ///order or sorting by class hierarchy depth) is guaranteed.
  ///However, there is guaranteed to be an ordering.
  ///
  ///\param o the object being compared to this one
  ///
  ///\return true iff this type sorts strictly before \a o
  bool operator<(const ObjectType& o) const{
    return type_name_ < o.type_name_;
  }

};

}
#endif //HOUGH_PEAK_MATCH_OBJECT_TYPE
