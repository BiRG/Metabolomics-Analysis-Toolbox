#ifndef BIRG_PEAKS_GSL_MATRIX_HPP
#define BIRG_PEAKS_GSL_MATRIX_HPP

#include <gsl/gsl_matrix.h>

namespace GSL{

///\brief Wrap the gsl_matrix structure
///
///Provides a conversion to gsl_matrix*, and, more importantly, calls
///the appropriate allocation/deallocation operators enabling
///exception safety.
class Matrix{
  ///\brief The underlying matrix data - must always be valid for the
  ///life-span of the object
  gsl_matrix* data;
public:
  ///\brief Create a Matrix with dimensions of \a rows x \a cols
  ///
  ///\param rows The number of rows in the matrix
  ///\param cols The number of columns in the matrix
  Matrix(std::size_t rows,std::size_t cols)
    :data(gsl_matrix_alloc(rows,cols)){}

  ///\brief Make a copy of \a o
  ///
  ///\param o The original matrix which is being copied
  Matrix(const Matrix& o)
    :data(gsl_matrix_alloc(o.data->size1,o.data->size2)){
    gsl_matrix_memcpy(data, o.data);
  }

  ///\brief Make this a copy of \a o
  ///
  ///\param o The original matrix which is being copied
  ///
  ///\return a reference to this Matrix after it has been modified
  Matrix& operator=(const Matrix& o){
    if( ! (data->size1 == o.data->size1 && data->size2 == o.data->size2) ){
      gsl_matrix_free(data);
      data = gsl_matrix_alloc(o.data->size1,o.data->size2);
    }
    gsl_matrix_memcpy(data, o.data);
    return *this;
  }

  ///\brief Return the underlying data pointer - be sure to keep it valid
  ///\warning Do not free this pointer 
  ///\return the underlying data pointer
  gsl_matrix* ptr(){ return data; }
  
  ///\brief Return the underlying data pointer
  ///\return the underlying data pointer 
  const gsl_matrix* ptr() const { return data; }
  
  ///\brief Deallocates the underlying matrix data with the gsl routine
  ~Matrix(){ gsl_matrix_free(data); data = NULL; }
};

}

#endif //BIRG_PEAKS_GSL_MATRIX_HPP
