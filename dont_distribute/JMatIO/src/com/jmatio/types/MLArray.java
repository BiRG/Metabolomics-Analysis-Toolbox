package com.jmatio.types;

/**
 * Base for all the major Matlab variable types.
 * 
 * @author Wojciech Gradkowski <wgradkowski@gmail.com>
 *
 */
public class MLArray
{
	/**
	 * Logger for error messages related to matlab variables
	 */
    public static final org.apache.log4j.Logger logger = org.apache.log4j.Logger.getLogger( MLArray.class.getName() );

    
    /* Matlab mx Array Types (Classes) */
    /**
     * Unknown type
     */
    public static final int mxUNKNOWN_CLASS = 0;
    /**
     * Cell array type
     */
    public static final int mxCELL_CLASS    = 1;
    /**
     * Struct array type
     */
    public static final int mxSTRUCT_CLASS  = 2;
    /**
     * Object type
     */
    public static final int mxOBJECT_CLASS  = 3;
    /**
     * Char type
     */
    public static final int mxCHAR_CLASS    = 4;
    /**
     * Sparse matrix type
     */
    public static final int mxSPARSE_CLASS  = 5;
    /**
     * Double type
     */
    public static final int mxDOUBLE_CLASS  = 6;
    /**
     * Single type
     */
    public static final int mxSINGLE_CLASS  = 7;
    /**
     * 8 bit signed integer type
     */
    public static final int mxINT8_CLASS    = 8;
    /**
     * 8 bit unsigned integer type
     */
    public static final int mxUINT8_CLASS   = 9;
    /**
     * 16 bit signed integer type
     */
    public static final int mxINT16_CLASS   = 10;
    /**
     * 16 bit unsigned integer type
     */
    public static final int mxUINT16_CLASS  = 11;
    /**
     * 32 bit signed integer type
     */
    public static final int mxINT32_CLASS   = 12;
    /**
     * 32 bit unsigned integer type
     */
    public static final int mxUINT32_CLASS  = 13;
    /**
     * 64 bit signed integer type
     */
    public static final int mxINT64_CLASS   = 14;
    /**
     * 64 bit unsigned integer type
     */
    public static final int mxUINT64_CLASS  = 15;
    /**
     * Function type
     */
    public static final int mxFUNCTION_CLASS = 16;
    /**
     * Opaque data type
     */
    public static final int mxOPAQUE_CLASS  = 17;
    
    /**
     * Flag for complex attribute
     */
    public static final int mtFLAG_COMPLEX       = 0x0800;
    /**
     * Flag for global attribute
     */
    public static final int mtFLAG_GLOBAL        = 0x0400;
    /**
     * Flag for logical attribute
     */
    public static final int mtFLAG_LOGICAL       = 0x0200;
    /**
     * Type attribute mask
     */
    public static final int mtFLAG_TYPE          = 0xff;
    
    protected int dims[];
    /**
     * The name of this MLArray
     */
    public String name;
    protected int attributes;
    protected int type;

    /**
     * Create an MLArray
     * @param name - array name - the name of the matlab variable
     * @param dims - array dimensions - an array of the dimensions, as would be returned from a size() invocation
     * @param type - array type - from the mx*CLASS constants
     * @param attributes - array flags - from the mtFLAG* constants
     */
    public MLArray(String name, int[] dims, int type, int attributes)
    {
        this.dims = new int[dims.length];
        System.arraycopy(dims, 0, this.dims, 0, dims.length);
        
        
        if ( name != null && !name.equals("") )
        {
            this.name = name;
        }
        else
        {
            this.name = "@"; //default name
        }
        
        
        this.type = type;
        this.attributes = attributes;
    }
    
    /**
     * Gets array name
     * 
     * @return - array name
     */
    public String getName()
    {
        return name;
    }
    /**
     * Return the attribute flags for this variable
     * @return the attribute flags for this variable
     */
    public int getFlags()
    { 
        int flags = type & mtFLAG_TYPE | attributes & 0xffffff00;
        
        return flags;
    }
    /**
     * Return the name of this variable as a byte array
     * @return the name of this variable as a byte array
     */
    public byte[] getNameToByteArray()
    {
        return name.getBytes();
    }
    
    /**
     * Return the dimensions of this variable. Similar to the value from a call to size.
     * @return the dimensions of this variable. 
     */
    public int[] getDimensions()
    {
        int ai[] = null;
        if(dims != null)
        {
            ai = new int[dims.length];
            System.arraycopy(dims, 0, ai, 0, dims.length);
        }
        return ai;
    }

    /**
     * Return the size of the first dimension of this variable
     * @return the size of the first dimension of this variable
     */
    public int getM()
    {
        int i = 0;
        if( dims != null )
        {
            i = dims[0];
        }
        return i;
    }

    /**
     * Return the size of the second dimension of this variable treated as a matrix
     * @return the size of the second dimension of this variable treated as a matrix
     */
    public int getN()
    {
        int i = 0;
        if(dims != null)
        {
            if(dims.length > 2)
            {
                i = 1;
                for(int j = 1; j < dims.length; j++)
                {
                    i *= dims[j];
                }
            } 
            else
            {
                i = dims[1];
            }
        }
        return i;
    }

    /**
     * Return the number of dimensions this variable has
     * @return the number of dimensions this variable has
     */
    public int getNDimensions()
    {
        int i = 0;
        if(dims != null)
        {
            i = dims.length;
        }
        return i;
    }
    
    /**
     * Return the number of entries in this variable
     * @return the number of entries in this variable
     */
    public int getSize()
    {
        return getM()*getN();
    }
    /**
     * Return the type id for this variable
     * @return the type id for this variable
     */
    public int getType()
    {
        return type;
    }

    /**
     * Return true if and only if this variable has no entries
     * @return true if and only if this variable has no entries
     */
    public boolean isEmpty()
    {
        return getN() == 0;
    }
    
    /**
     * Return a string that tells what type the integer constant refers to
     * @param type An integer type constant taken from the mx*Class constants
     * @return a string that tells what type the integer constant refers to
     */
    public static final String typeToString(int type)
    {
        String s;
        switch (type)
        {
            case mxUNKNOWN_CLASS:
                s = "unknown";
                break;
            case mxCELL_CLASS:
                s = "cell";
                break;
            case mxSTRUCT_CLASS:
                s = "struct";
                break;
            case mxCHAR_CLASS:
                s = "char";
                break;
            case mxSPARSE_CLASS:
                s = "sparse";
                break;
            case mxDOUBLE_CLASS:
                s = "double";
                break;
            case mxSINGLE_CLASS:
                s = "single";
                break;
            case mxINT8_CLASS:
                s = "int8";
                break;
            case mxUINT8_CLASS:
                s = "uint8";
                break;
            case mxINT16_CLASS:
                s = "int16";
                break;
            case mxUINT16_CLASS:
                s = "uint16";
                break;
            case mxINT32_CLASS:
                s = "int32";
                break;
            case mxUINT32_CLASS:
                s = "uint32";
                break;
            case mxINT64_CLASS:
                s = "int64";
                break;
            case mxUINT64_CLASS:
                s = "uint64";
                break;
            case mxFUNCTION_CLASS:
                s = "function_handle";
                break;
            case mxOPAQUE_CLASS:
                s = "opaque";
                break;
            case mxOBJECT_CLASS:
                s = "object";
                break;
            default:
                s = "unknown";
                break;
        }
        return s;
    }
    
    /**
     * Return true if and only if this variable is of cell type
     * @return true if and only if this variable is of cell type
     */
    public boolean isCell()
    {
        return type == mxCELL_CLASS;
    }

    /**
     * Return true if and only if this variable is of char type
     * @return true if and only if this variable is of char type
     */
    public boolean isChar()
    {
        return type == mxCHAR_CLASS;
    }

    /**
     * Return true if and only if this variable is of complex type
     * @return true if and only if this variable is of complex type
     */
    public boolean isComplex()
    {
        return (attributes & mtFLAG_COMPLEX) != 0;
    }
    /**
     * Return true if and only if this variable is of sparse type
     * @return true if and only if this variable is of sparse type
     */
    public boolean isSparse()
    {
        return type == mxSPARSE_CLASS;
    }

    /**
     * Return true if and only if this variable is of struct type
     * @return true if and only if this variable is of struct type
     */
    public boolean isStruct()
    {
        return type == mxSTRUCT_CLASS;
    }

    /**
     * Return true if and only if this variable is of double type
     * @return true if and only if this variable is of double type
     */
    public boolean isDouble()
    {
        return type == mxDOUBLE_CLASS;
    }
    
    /**
     * Return true if and only if this variable is of single type
     * @return true if and only if this variable is of single type
     */
    public boolean isSingle()
    {
        return type == mxSINGLE_CLASS;
    }

    /**
     * Return true if and only if this variable is of int8 type
     * @return true if and only if this variable is of int8 type
     */
    public boolean isInt8()
    {
        return type == mxINT8_CLASS;
    }

    /**
     * Return true if and only if this variable is of uint8 type
     * @return true if and only if this variable is of uint8 type
     */
    public boolean isUint8()
    {
        return type == mxUINT8_CLASS;
    }

    /**
     * Return true if and only if this variable is of int16 type
     * @return true if and only if this variable is of int16 type
     */
    public boolean isInt16()
    {
        return type == mxINT16_CLASS;
    }

    /**
     * Return true if and only if this variable is of uint16 type
     * @return true if and only if this variable is of uint16 type
     */
    public boolean isUint16()
    {
        return type == mxUINT16_CLASS;
    }

    /**
     * Return true if and only if this variable is of int32 type
     * @return true if and only if this variable is of int32 type
     */
    public boolean isInt32()
    {
        return type == mxINT32_CLASS;
    }

    /**
     * Return true if and only if this variable is of uint32 type
     * @return true if and only if this variable is of uint32 type
     */
    public boolean isUint32()
    {
        return type == mxUINT32_CLASS;
    }

    /**
     * Return true if and only if this variable is of int64 type
     * @return true if and only if this variable is of int64 type
     */
    public boolean isInt64()
    {
        return type == mxINT64_CLASS;
    }

    /**
     * Return true if and only if this variable is of uint64 type
     * @return true if and only if this variable is of uint64 type
     */
    public boolean isUint64()
    {
        return type == mxUINT64_CLASS;
    }

    /**
     * Return true if and only if this variable is of object type
     * @return true if and only if this variable is of object type
     */
    public boolean isObject()
    {
        return type == mxOBJECT_CLASS;
    }

    /**
     * Return true if and only if this variable is of opaque type
     * @return true if and only if this variable is of opaque type
     */
    public boolean isOpaque()
    {
        return type == mxOPAQUE_CLASS;
    }

    /**
     * Return true if and only if this variable has the logical attribute
     * @return true if and only if this variable has the logical attribute
     */
    public boolean isLogical()
    {
        return (attributes & mtFLAG_LOGICAL) != 0;
    }

    /**
     * Return true if and only if this variable is of function type
     * @return true if and only if this variable is of function type
     */
    public boolean isFunctionObject()
    {
        return type == mxFUNCTION_CLASS;
    }

    /**
     * Return true if and only if this variable is of unknown type
     * @return true if and only if this variable is of unknown type
     */
    public boolean isUnknown()
    {
        return type == mxUNKNOWN_CLASS;
    }
    protected int getIndex(int m, int n)
    {
        return m+n*getM();
    }
    
    public String toString()
    {
        StringBuffer sb = new StringBuffer();
        if (dims != null)
        {
            sb.append('[');
            if (dims.length > 3)
            {
                sb.append(dims.length);
                sb.append('D');
            }
            else
            {
                sb.append(dims[0]);
                sb.append('x');
                sb.append(dims[1]);
                if (dims.length == 3)
                {
                    sb.append('x');
                    sb.append(dims[2]);
                }
            }
            sb.append("  ");
            sb.append(typeToString(type));
            sb.append(" array");
            if (isSparse())
            {
                sb.append(" (sparse");
                if (isComplex())
                {
                    sb.append(" complex");
                }
                sb.append(")");
            }
            else if (isComplex())
            {
                sb.append(" (complex)");
            }
            sb.append(']');
        }
        else
        {
            sb.append("[invalid]");
        }
        return sb.toString();
    }
    
    /**
     * Return A string representation of the content of this variable
     * @return A string representation of the content of this variable
     */
    @SuppressWarnings("static-method")
	public String contentToString()
    {
        return "content cannot be displayed";
    }
}
