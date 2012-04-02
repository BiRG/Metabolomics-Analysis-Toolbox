package com.jmatio.types;

import java.util.ArrayList;

/**
 * Matlab cell array
 * 
 * @author Wojciech Gradkowski <wgradkowski@gmail.com>
 * 
 */
public class MLCell extends MLArray
{
    private ArrayList<MLArray> cells;
    
    /**
     * Create a cell array with the given name and dimensions
     * @param name name of the array
     * @param dims dimensions of the array
     */
    public MLCell(String name, int[] dims )
    {
        this( name, dims, MLArray.mxCELL_CLASS, 0);
    }
    
    /**
     * Create a cell array with the given name and dimensions
     * @param name name of the array
     * @param dims dimensions of the array
     * @param type Type field for the variable
     * @param attributes Attributes for the variable
     */
    public MLCell(String name, int[] dims, int type, int attributes)
    {
        super(name, dims, type, attributes);
        
        cells = new ArrayList<MLArray>(getM()*getN());
        
        for ( int i = 0; i < getM()*getN(); i++ )
        {
            cells.add( new MLEmptyArray() );
        }
    }
    
    /**
     * Set the contents of the cell at <code>m</code>,<code>n</code> to <code>value</code>
     * @param value The new value for the cell
     * @param m The first index of the cell to set
     * @param n The second index of the cell to set
     */
    public void set(MLArray value, int m, int n)
    {
        cells.set( getIndex(m,n), value );
    }
    
    /**
     * Set the contents of the cell at <code>index</code> to <code>value</code>
     * 
     * @param value The new value for the cell
     * @param index The index of the cell to set
     */
    public void set(MLArray value, int index)
    {
        cells.set( index, value );
    }

    /**
     * Return the contents of the cell at <code>m</code>,<code>n</code>
     * @param m The first index of the cell to return
     * @param n The second index of the cell to return
     * @return the contents of the cell at <code>m</code>,<code>n</code>
     */
    public MLArray get(int m, int n)
    {
        return cells.get( getIndex(m,n) );
    }

    /**
     * Return the contents of the cell at <code>index</code>
     * @param index The index of the cell to return
     * @return the contents of the cell at <code>index</code>
     */
    public MLArray get(int index)
    {
        return cells.get( index );
    }

	/**
	 * Return the 1 dimensional index corresponding to the given two dimensional
	 * index into this cell array.
	 * @param m The first index into the array
	 * @param n The second index into the array
	 */
    public int getIndex(int m, int n)
    {
        return m+n*getM();
    }
    
    /**
     * Return the underlying cells
     * @return the underlying cells
     */
    public ArrayList<MLArray> cells()
    {
        return cells;
    }
    public String contentToString()
    {
        StringBuffer sb = new StringBuffer();
        sb.append(name + " = \n");
        
        for ( int m = 0; m < getM(); m++ )
        {
           sb.append("\t");
           for ( int n = 0; n < getN(); n++ )
           {
               sb.append( get(m,n) );
               sb.append("\t");
           }
           sb.append("\n");
        }
        return sb.toString();
    }

}
