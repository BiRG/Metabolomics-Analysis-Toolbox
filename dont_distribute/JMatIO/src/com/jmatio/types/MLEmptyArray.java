package com.jmatio.types;

/**
 * Matlab empty array
 * 
 * @author Wojciech Gradkowski <wgradkowski@gmail.com>
 * 
 */
public class MLEmptyArray extends MLArray
{
	/**
	 * Create an empty array with no name
	 */
    public MLEmptyArray()
    {
        this(null);
    }
    
    /**
     * Create an empty array variable named <code>name</code>
     * @param name The name of the new variable
     */
    public MLEmptyArray(String name)
    {
        this(name, new int[] {0,0}, mxDOUBLE_CLASS, 0);
    }
    
    
    /**
     * Create an empty array with the given name and dimensions
     * @param name name of the array
     * @param dims dimensions of the array
     * @param type Type field for the variable
     * @param attributes Attributes for the variable
     */
    public MLEmptyArray(String name, int[] dims, int type, int attributes)
    {
        super(name, dims, type, attributes);
        // TODO Auto-generated constructor stub
    }

}
