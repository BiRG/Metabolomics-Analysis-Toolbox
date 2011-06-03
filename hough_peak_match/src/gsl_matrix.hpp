#ifndef BIRG_PEAKS_GSL_MATRIX_HPP
#define BIRG_PEAKS_GSL_MATRIX_HPP

#ifndef HAVE_INLINE
#define HAVE_INLINE
#endif 

#include <gsl/gsl_matrix.h>
#include <iostream>

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
  
  ///\brief Return the number of rows in this matrix
  ///
  ///\return the number of rows in this matrix
  std::size_t rows() const { return data->size1; }

  ///\brief Return the number of columns in this matrix
  ///
  ///\return the number of columns in this matrix
  std::size_t cols() const { return data->size2; }

  ///\brief Return the underlying data pointer - be sure to keep it valid
  ///
  ///\warning Do not free this pointer 
  ///
  ///\return the underlying data pointer
  gsl_matrix* ptr(){ return data; }
  
  ///\brief Return the underlying data pointer
  ///
  ///\return the underlying data pointer 
  const gsl_matrix* ptr() const { return data; }

  ///\brief Return the transpose of this matrix
  ///
  ///\return The transpose of this matrix
  Matrix transpose() const{
    Matrix ret(cols(),rows());
    gsl_matrix_transpose_memcpy(ret.ptr(), ptr());
    return ret;
  }

  ///\brief Return a reference to the element of the matrix at the
  ///given row and column
  ///
  ///\param row the row location of the desired element
  ///
  ///\param col the column location of the desired element
  ///
  ///\return a reference to the element of the matrix at the
  ///given row and column
  double& at(std::size_t row, std::size_t col){
    return *gsl_matrix_ptr(data, row, col);
  }

  ///\brief Return the element of the matrix at the given row and
  ///column
  ///
  ///\param row the row location of the desired element
  ///
  ///\param col the column location of the desired element
  ///
  ///\return the element of the matrix at the given row and column
  double at(std::size_t row, std::size_t col) const{
    return gsl_matrix_get(data, row, col);
  }
  
  
  ///\brief Deallocates the underlying matrix data with the gsl routine
  ~Matrix(){ gsl_matrix_free(data); data = NULL; }
};

///\brief Print a human-readable version of \a m to \a out
///
///The printed form of the matrix contains newlines (and ends with a newline)
///
///\param out the stream to print to
///
///\param m the matrix to print
///
///\return \a out after printing
std::ostream& operator<<(std::ostream& out, const GSL::Matrix& m){
  out << "{";
  for(std::size_t row = 0; row < m.rows(); ++row){
    if(row == 0){
      out << "{ ";
    }else{
      out << " { ";
    }
    for(std::size_t col = 0; col < m.cols(); ++col){
      out << m.at(row,col);
      if(col+1 < m.cols()){
	out << ", ";
      }
    }
    out << " }";
    if(row+1 < m.rows()){ out << "\n"; }
  }
  return out << "}\n";
}

}


#endif //BIRG_PEAKS_GSL_MATRIX_HPP
