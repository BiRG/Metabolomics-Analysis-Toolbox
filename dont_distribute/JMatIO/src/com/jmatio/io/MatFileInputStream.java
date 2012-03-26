package com.jmatio.io;

import java.io.IOException;
import java.nio.ByteBuffer;

import com.jmatio.common.MatDataTypes;

/**
 * MAT-file input stream class. 
 * 
 * @author Wojciech Gradkowski <wgradkowski@gmail.com>
 */
class MatFileInputStream
{
    private int type;
    private ByteBuffer buf;
    
    /**
     * Attach MAT-file input stream to <code>InputStream</code>
     * 
     * @param is - input stream
     * @param type - type of data in the stream
     * @see com.jmatio.common.MatDataTypes
     */
    public MatFileInputStream( ByteBuffer buf, int type )
    {
        this.type = type;
        this.buf = buf;
    }
    
    /**
     * Reads data (number of bytes red is determined by <i>data type</i>)
     * from the stream to <code>int</code>.
     * 
     * @return
     * @throws IOException
     */
    public int readInt() throws IOException
    {
        switch ( type )
        {
            case MatDataTypes.miUINT8:
                return (int)( buf.get() & 0xFF);
            case MatDataTypes.miINT8:
                return (int) buf.get();
            case MatDataTypes.miUINT16:
                return (int)( buf.getShort() & 0xFFFF);
            case MatDataTypes.miINT16:
                return (int) buf.getShort();
            case MatDataTypes.miUINT32:
                return (int)( buf.getInt() & 0xFFFFFFFF);
            case MatDataTypes.miINT32:
                return (int) buf.getInt();
            case MatDataTypes.miDOUBLE:
                return (int) buf.getDouble();
            default:
                throw new IllegalArgumentException("Unknown data type: " + type);
        }
    }
    /**
     * Reads data (number of bytes red is determined by <i>data type</i>)
     * from the stream to <code>char</code>.
     * 
     * @return - char
     * @throws IOException
     */
    public char readChar() throws IOException
    {
        switch ( type )
        {
            case MatDataTypes.miUINT8:
                return (char)( buf.get() & 0xFF);
            case MatDataTypes.miINT8:
                return (char) buf.get();
            case MatDataTypes.miUINT16:
                return (char)( buf.getShort() & 0xFFFF);
            case MatDataTypes.miINT16:
                return (char) buf.getShort();
            case MatDataTypes.miUINT32:
                return (char)( buf.getInt() & 0xFFFFFFFF);
            case MatDataTypes.miINT32:
                return (char) buf.getInt();
            case MatDataTypes.miDOUBLE:
                return (char) buf.getDouble();
            case MatDataTypes.miUTF8:
                return (char) buf.get();
            default:
                throw new IllegalArgumentException("Unknown data type: " + type);
        }
    }
    /**
     * Reads data (number of bytes red is determined by <i>data type</i>)
     * from the stream to <code>double</code>.
     * 
     * @return - double
     * @throws IOException
     */
    public double readDouble() throws IOException
    {
        switch ( type )
        {
            case MatDataTypes.miUINT8:
                return (double)( buf.get() & 0xFF);
            case MatDataTypes.miINT8:
                return (double) buf.get();
            case MatDataTypes.miUINT16:
                return (double)( buf.getShort() & 0xFFFF);
            case MatDataTypes.miINT16:
                return (double) buf.getShort();
            case MatDataTypes.miUINT32:
                return (double)( buf.getInt() & 0xFFFFFFFF);
            case MatDataTypes.miINT32:
                return (double) buf.getInt();
            case MatDataTypes.miDOUBLE:
                return (double) buf.getDouble();
            default:
                throw new IllegalArgumentException("Unknown data type: " + type);
        }
    }

}
