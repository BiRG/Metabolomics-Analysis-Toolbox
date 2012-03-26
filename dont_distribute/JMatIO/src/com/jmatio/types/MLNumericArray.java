package com.jmatio.types;

import java.util.Arrays;

/**
 * Abstract class for numeric arrays.
 * 
 * @author Wojciech Gradkowski <wgradkowski@gmail.com>
 *
 * @param <T> The type stored in the array
 */
public abstract class MLNumericArray<T extends Number> extends MLArray 
{
    private T[] real;
    private T[] imaginary;

    /**
     * Helper method for dense array subclasses called to allocate the real and imaginary arrays by the 
     * MLNumericArray constructor
     * 
     * A subclass may return null but must handle its own storage allocation then.
     * 
     * @param m First dimension of the array to allocate
     * @param n Second dimension of the array to allocate
     * @return The allocated array
     */
    protected abstract T[] createArray(int m, int n);

    /**
     * Normally this constructor is used only by MatFileReader and MatFileWriter
     * 
     * @param name - array name
     * @param dims - array dimensions
     * @param type - array type
     * @param attributes - array flags
     */
    public MLNumericArray(String name, int[] dims, int type, int attributes)
    {
        super(name, dims, type, attributes);
        
        real = createArray(getM(), getN());
        imaginary = createArray(getM(), getN());
    }
    /**
     * <a href="http://math.nist.gov/javanumerics/jama/">Jama</a> [math.nist.gov] style: 
     * construct a 2D real matrix from a one-dimensional packed array
     * 
     * @param name - array name
     * @param type - array type
     * @param vals - One-dimensional array of doubles, packed by columns (ala Fortran).
     * @param m - Number of rows
     */
    public MLNumericArray(String name, int type, T[] vals, int m )
    {
        this(name, new int[] {  m, vals.length/m }, type, 0);
        //fill the array
        for ( int i = 0; i < vals.length; i++ )
        {
            set( vals[i], i );
        }
    }
    /**
     * Gets single real array element of A(m,n).
     * 
     * @param m - row index
     * @param n - column index
     * @return - array element
     */
    public T getReal(int m, int n)
    {
        return real[getIndex(m,n)];
    }
    /**
     * Sets single real array element.
     * 
     * @param value - element value
     * @param m - row index
     * @param n - column index
     */
    public void setReal(T value, int m, int n)
    {
        real[getIndex(m,n)] = value;
    }
    /**
     * Sets single real array element.
     * 
     * @param value - element value
     * @param index - column-packed vector index
     */
    public void setReal(T value, int index)
    {
        real[index] = value;
    }
    /**
     * Sets real part of matrix
     * 
     * @param vector - column-packed vector of elements
     */
    public void setReal( T[] vector )
    {
        if ( vector.length != getSize() )
        {
            throw new IllegalArgumentException("Matrix dimensions do not match. " + getSize() + " not " + vector.length);
        }
        System.arraycopy(vector, 0, real, 0, vector.length);
    }
    /**
     * Sets single imaginary array element.
     * 
     * @param value - element value
     * @param m - row index
     * @param n - column index
     */
    public void setImaginary(T value, int m, int n)
    {
        imaginary[getIndex(m,n)] = value;
    }
    /**
     * Sets single real array element.
     * 
     * @param value - element value
     * @param index - column-packed vector index
     */
    public void setImaginary(T value, int index)
    {
        imaginary[index] = value;
    }
    /**
     * Gets single imaginary array element of A(m,n).
     * 
     * @param m - row index
     * @param n - column index
     * @return - array element
     */
    public T getImaginary(int m, int n)
    {
        return imaginary[getIndex(m,n)];
    }
    /**
     * Exports column-packed vector of real elements
     * 
     * @return - column-packed vector of real elements
     */
    public T[] exportReal()
    {
        return real.clone();
    }
    /**
     * Exports column-packed vector of imaginary elements
     * 
     * @return - column-packed vector of imaginary elements
     */
    public T[] exportImaginary()
    {
        return imaginary.clone();
    }
    /**
     * Does the same as <code>setReal</code>.
     * 
     * @param value - element value
     * @param m - row index
     * @param n - column index
     */
    public void set(T value, int m, int n)
    {
        if ( isComplex() )
        {
            throw new IllegalStateException("Cannot use this method for Complex matrices");
        }
        setReal(value, m, n);
    }
    /**
     * Does the same as <code>setReal</code>.
     * 
     * @param value - element value
     * @param index - column-packed vector index
     */
    public void set(T value, int index)
    {
        if ( isComplex() )
        {
            throw new IllegalStateException("Cannot use this method for Complex matrices");
        }
        setReal(value, index);
    }
    /**
     * Does the same as <code>getReal</code>.
     * 
     * @param m - row index
     * @param n - column index
     * @return - array element
     */
    public T get( int m, int n )
    {
        if ( isComplex() )
        {
            throw new IllegalStateException("Cannot use this method for Complex matrices");
        }
        return getReal(m, n);
    }
    /**
     * @param index The index of the desired element
     * @return the element at index
     */
    public T get ( int index )
    {
        if ( isComplex() )
        {
            throw new IllegalStateException("Cannot use this method for Complex matrices");
        }
        return real[index];
    }
    /**
     * Set the contents of this to the contents of vector
     * @param vector the new values
     */
    public void set(T[] vector)
    {
        if ( isComplex() )
        {
            throw new IllegalStateException("Cannot use this method for Complex matrices");
        }
        setReal(vector);
    }
    /* (non-Javadoc)
     * @see com.jmatio.types.MLArray#contentToString()
     */
    public String contentToString()
    {
        StringBuffer sb = new StringBuffer();
        sb.append(name + " = \n");
        
        if ( getSize() > 1000 )
        {
            sb.append("Cannot display variables with more than 1000 elements.");
            return sb.toString();
        }
        for ( int m = 0; m < getM(); m++ )
        {
           sb.append("\t");
           for ( int n = 0; n < getN(); n++ )
           {
               sb.append( getReal(m,n) );
               if ( isComplex() )
               {
                   sb.append("+" + getImaginary(m,n) );
               }
               sb.append("\t");
           }
           sb.append("\n");
        }
        return sb.toString();
    }
    /* (non-Javadoc)
     * @see java.lang.Object#equals(java.lang.Object)
     */
    @Override
    public boolean equals(Object o)
    {
        if ( o instanceof  MLNumericArray )
        {
            return Arrays.equals( real, ((MLNumericArray)o).real )
                    && Arrays.equals( imaginary, ((MLNumericArray)o).imaginary )
                    && Arrays.equals( dims, ((MLNumericArray)o).dims )
                    ;
        }
        return super.equals( o );
    }
    
}
