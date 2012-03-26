package com.jmatio.types;

import java.io.ByteArrayOutputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * This class represents Matlab's Structure object (struct array).
 * 
 * Note: array of structures can contain only structures of the same type
 * , that means structues that have the same field names.
 * 
 * @author Wojciech Gradkowski <wgradkowski@gmail.com>
 */
public class MLStructure extends MLArray
{
    /**
     * A Set that keeps structure field names
     */
    private Set<String> keys;
    /**
     * Array of structures
     */
    private List< Map<String,MLArray> > mlStructArray;
    /**
     * Current structure pointer for bulk insertion 
     */
    private int currentIndex = 0;
    
    /**
     * Create a structure array with the given name and dimensions
     * @param name The name of the array variable
     * @param dims The dimensions of the struct array
     */
    public MLStructure(String name, int[] dims)
    {
        this(name, dims, MLArray.mxSTRUCT_CLASS, 0 );
    }

    /**
     * Create a structure array with the given name and dimensions
     * @param name The name of the array variable
     * @param dims The dimensions of the struct array
     * @param type The array type
     * @param attributes  array flags
     */
    public MLStructure(String name, int[] dims, int type, int attributes)
    {
        super(name, dims, type, attributes);
        
        mlStructArray = new ArrayList< Map<String,MLArray> >();
        keys = new LinkedHashSet<String>();
    }
    /**
     * Sets field for current structure
     * 
     * @param name - name of the field
     * @param value - <code>MLArray</code> field value
     */
    public void setField(String name, MLArray value)
    {
        //fields.put(name, value);
        setField(name, value, currentIndex);
    }
    /**
     * Sets field for (m,n)'th structure in struct array
     * 
     * @param name - name of the field
     * @param value - <code>MLArray</code> field value
     * @param m first index of the structure whose field will be set
     * @param n second index of the structure whose field will be set
     */
    public void setField(String name, MLArray value, int m, int n)
    {
        setField(name, value, getIndex(m,n) );
    }
    /**
     * Sets filed for structure described by index in struct array
     * 
     * @param name - name of the field
     * @param value - <code>MLArray</code> field value
     * @param index the index of the structure whose field will be set
     */
    public void setField(String name, MLArray value, int index)
    {
        keys.add(name);
        currentIndex = index;
        
        if ( mlStructArray.isEmpty() || mlStructArray.size() <= index )
        {
            mlStructArray.add(index, new LinkedHashMap<String, MLArray>() );
        }
        mlStructArray.get(index).put(name, value);
    }
    
    /**
     * Gets the maximum length of field desctiptor
     * 
     * @return the maximum length of field desctiptor
     */
    public int getMaxFieldLenth()
    {
        //get max field name
        int maxLen = 0;
        for ( String s : keys )
        {
            maxLen = s.length() > maxLen ? s.length() : maxLen;
        }
        return maxLen+1;
        
    }
    
    /**
     * Dumps field names to byte array. Field names are written as null-terminated Strings
     * 
     * @return Field names are written as null-terminated Strings in a byte array.
     */
    public byte[] getKeySetToByteArray() 
    {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        DataOutputStream dos = new DataOutputStream(baos);
        
        char[] buffer = new char[getMaxFieldLenth()];
        
        try
        {
            for ( String s : keys )
            {
                Arrays.fill(buffer, (char)0);
                System.arraycopy( s.toCharArray(), 0, buffer, 0, s.length() );
                dos.writeBytes( new String(buffer) );
            }
        }
        catch  (IOException e)
        {
            logger.error("Could not write Structure key set to byte array: " + e );
            return new byte[0];
        }
        return baos.toByteArray();
        
    }
    /**
     * Gets all fields from struct array as flat list of fields.
     * 
     * @return all fields from struct array as flat list of fields.
     */
    public Collection<MLArray> getAllFields()
    {
        ArrayList<MLArray> fields = new ArrayList<MLArray>();
        
        for ( Map<String, MLArray> struct : mlStructArray )
        {
            fields.addAll( struct.values() );
        }
        return fields;
    }
    
	/**
	 * Gets the value of the field described by name from current struct in
	 * struct array.
	 * 
	 * @param name
	 *            The name of the field to return
	 * @return the value of the field described by name from current struct in
	 *         struct array.
	 */
    public MLArray getField(@SuppressWarnings("hiding") String name)
    {
        return getField(name, currentIndex);
    }

	/**
	 * Gets the value of the field described by name from (m,n)'th struct in
	 * struct array.
	 * 
	 * @param name
	 *            Name of the field to get
	 * @param m
	 *            first index
	 * @param n
	 *            second index
	 * @return the value of the field described by name from (m,n)'th struct in
	 *         struct array.
	 */
    public MLArray getField(@SuppressWarnings("hiding") String name, int m, int n)
    {
        return getField(name, getIndex(m,n) );
    }

	/**
	 * Gets the value of the field described by name from index'th struct in
	 * struct array.
	 * 
	 * @param name
	 *            The name of the field to get
	 * @param index
	 *            The index of the field in the struct array
	 * @return the value of the field described by name from index'th struct in
	 *         struct array.
	 */
    public MLArray getField(@SuppressWarnings("hiding") String name, int index)
    {
        return mlStructArray.get(index).get(name);
    }
    /* (non-Javadoc)
     * @see com.paradigmdesigner.matlab.types.MLArray#contentToString()
     */
    public String contentToString()
    {
        StringBuffer sb = new StringBuffer();
        sb.append(name + " = \n");
        
        if ( getM()*getN() == 1 )
        {
            for ( String key : keys )
            {
                sb.append("\t" + key + " : " + getField(key) + "\n" );
            }
        }
        else
        {
            sb.append("\n");
            sb.append(getM() + "x" + getN() );
            sb.append(" struct array with fields: \n");
            for ( String key : keys)
            {
                sb.append("\t" + key + "\n");
            }
        }
        return sb.toString();
    }

}
