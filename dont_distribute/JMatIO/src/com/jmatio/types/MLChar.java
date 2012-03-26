package com.jmatio.types;

import java.util.Arrays;

/**
 * Matlab char array
 * 
 * @author Wojciech Gradkowski <wgradkowski@gmail.com>
 * 
 */
public class MLChar extends MLArray
{
    Character[] chars;

    /**
     * Create a char array with the given name and value
     * @param name name of the array
     * @param value The characters in this array as a string
     */
    public MLChar(String name, String value )
    {
        this( name, new int[] { 1, value.length() } , MLArray.mxCHAR_CLASS, 0);
        set(value);
    }
    
    /**
     * Create a character array with the given name and dimensions
     * @param name name of the array
     * @param dims dimensions of the array
     * @param type Type field for the variable
     * @param attributes Attributes for the variable
     */
    public MLChar(String name, int[] dims, int type, int attributes)
    {
        super(name, dims, type, attributes);
        chars = new Character[getM()*getN()];
    }

    public void setChar(char ch, int index)
    {
        chars[index] = new Character(ch);
    }
    public void set(String value)
    {
        char[] cha = value.toCharArray();
        for ( int i = 0; i < getN() &&  i < value.length(); i++ )
        {
            setChar(cha[i], i);
        }
    }
    
    public Character getChar(int m, int n)
    {
        return chars[getIndex(m,n)];
    }
    public Character[] exportChar()
    {
        return chars;
    }
    
    @Override
    public boolean equals(Object o)
    {
        if ( o instanceof MLChar )
        {
            return Arrays.equals( chars, ((MLChar)o).chars );
        }
        return super.equals( o );
    }
    
    /**
     * Gets the m-th character matrix's row as <code>String</code>.
     * 
     * @param m - row number
     * @return - <code>String</code>
     */
    public String getString( int m )
    {
        StringBuffer charbuff = new StringBuffer();
        
        for (int n = 0; n < getN(); n++)
        {
            charbuff.append(getChar(m, n));
        }
        
        return charbuff.toString();
    }
    
    public String contentToString()
    {
        StringBuffer sb = new StringBuffer();
        sb.append(name + " = \n");
        
        for ( int m = 0; m < getM(); m++ )
        {
           sb.append("\t");
           StringBuffer charbuff = new StringBuffer();
           charbuff.append("'");
           for ( int n = 0; n < getN(); n++ )
           {
               charbuff.append( getChar(m,n) );
           }
           charbuff.append("'");
           sb.append(charbuff);
           sb.append("\n");
        }
        return sb.toString();
        
    }

}
