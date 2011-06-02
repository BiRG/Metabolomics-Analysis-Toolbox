#ifndef BIRG_PEAKS_GSL_VECTOR_HPP
#define BIRG_PEAKS_GSL_VECTOR_HPP

#ifndef HAVE_INLINE
#define HAVE_INLINE
#endif 

#include <gsl/gsl_vector.h>

namespace GSL{

///\brief Wrap the gsl_vector structure
///
///Provides a conversion to gsl_vector*, and, more importantly, calls
///the appropriate allocation/deallocation operators enabling
///exception safety.
class Vector{
  ///\brief The underlying vector data - must always be valid for the
  ///life-span of the object
  gsl_vector* data;
public:
  ///\brief Create a Vector with dimensions of \a rows x \a cols
  ///
  ///\param num_elements The number of columns in the vector
  Vector(std::size_t num_elements)
    :data(gsl_vector_alloc(num_elements)){}

  ///\brief Make a copy of \a o
  ///
  ///\param o The original vector which is being copied
  Vector(const Vector& o)
    :data(gsl_vector_alloc(o.data->size)){
    gsl_vector_memcpy(data, o.data);
  }

  ///\brief Make this a copy of \a o
  ///
  ///\param o The original vector which is being copied
  ///
  ///\return a reference to this Vector after it has been modified
  Vector& operator=(const Vector& o){
    if( ! (data->size == o.data->size) ){
      gsl_vector_free(data);
      data = gsl_vector_alloc(o.data->size);
    }
    gsl_vector_memcpy(data, o.data);
    return *this;
  }

  ///\brief Return the underlying data pointer - be sure to keep it valid
  ///
  ///\warning Do not free this pointer 
  ///
  ///\return the underlying data pointer
  gsl_vector* ptr(){ return data; }
  
  ///\brief Return the underlying data pointer
  ///
  ///\return the underlying data pointer 
  const gsl_vector* ptr() const { return data; }

  ///\brief Return the number of elements in the vector
  ///
  ///\return the number of elements in the vector
  std::size_t size() const { return data->size; }

  ///\brief Return the vector element at index
  ///
  ///\note: unlike the stl vectors this operator[] is range-checked
  ///
  ///\param index the index (0-based) of the desired the vector element
  ///
  ///\return the vector element at index
  double operator[](std::size_t index) const{
    return gsl_vector_get(data, index);
  }

  ///\brief Return a reference to the vector element at index
  ///
  ///\note: unlike the stl vectors this operator[] is range-checked
  ///
  ///\param index the index (0-based) of the desired the vector element
  ///
  ///\return a reference to the vector element at index
  double& operator[](std::size_t index) {
    return *gsl_vector_ptr(data, index);
  }
  
  ///\brief Deallocates the underlying vector data with the gsl routine
  ~Vector(){ gsl_vector_free(data); data = NULL; }
};

}

#endif //BIRG_PEAKS_GSL_VECTOR_HPP
