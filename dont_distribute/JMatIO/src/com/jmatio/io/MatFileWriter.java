package com.jmatio.io;


import java.io.ByteArrayOutputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.ByteBuffer;
import java.nio.channels.WritableByteChannel;
import java.util.Collection;
import java.util.zip.Deflater;
import java.util.zip.DeflaterOutputStream;

import com.jmatio.common.MatDataTypes;
import com.jmatio.types.MLArray;
import com.jmatio.types.MLCell;
import com.jmatio.types.MLChar;
import com.jmatio.types.MLDouble;
import com.jmatio.types.MLSparse;
import com.jmatio.types.MLStructure;

/**
 * Writes MAT-files.
 * 
 * <h2>Static Method Usage</h2>
 * 
 * The basic method of writing MAT-files is to use the static methods called
 * <code>MatFileWriter.writeMat</code>
 * 
 * <pre>
 * <code>
 * //1. First create example arrays
 * double[] src = new double[] { 1.0, 2.0, 3.0, 4.0, 5.0, 6.0 };
 * MLDouble mlDouble = new MLDouble( "double_arr", src, 3 );
 * MLChar mlChar = new MLChar( "char_arr", "I am dummy" );
 *         
 * //2. write arrays to file
 * ArrayList<MLArray> list = new ArrayList<MLArray>();
 * list.add( mlDouble );
 * list.add( mlChar );
 * 
 * MatFileWriter.writeMat( "mat_file.mat", list );
 * </code>
 * </pre>
 * 
 * this is "equal" to Matlab commands:
 * 
 * <pre>
 * <code>
 * >> double_arr = [ 1 2; 3 4; 5 6];
 * >> char_arr = 'I am dummy';
 * >>
 * >> save('mat_file.mat', 'double_arr', 'char_arr');
 * </code>
 * </pre>
 * 
 * <h2>Constructor Usage</h2>
 * 
 * To mirror the MatFileReader structure, you can also write files by creating a
 * MatFileWriter object with the appropriate constructor.
 * 
 * So, the last line of the code above:
 * 
 * <pre>
 * <code>
 * MatFileWriter.writeMat( "mat_file.mat", list );
 * </code>
 * </pre>
 * 
 * Can be rewritten, with identical behavior, as:
 * 
 * <pre>
 * <code>
 * new MatFileWriter( "mat_file.mat", list );
 * </code>
 * </pre>
 * 
 * @author Wojciech Gradkowski (<a
 *         href="mailto:wgradkowski@gmail.com">wgradkowski@gmail.com</a>)
 * @author Eric Moyer (<img src="doc-files/eric_handwritten_email.png"
 *         style="vertical-align:-50%"/>)
 */
public class MatFileWriter
{
//    private static final Logger logger = Logger.getLogger(MatFileWriter.class);
    
	/**
	 * Writes a collection of <code>MLArrays</code> to the file named <code>fileName</code>.
	 * 
	 * @param fileName
	 *            name of output file
	 * @param data
	 *            <code>Collection</code> of <code>MLArray</code> elements
	 * @throws IOException
	 *             if there is an error writing to the file
	 */
    @SuppressWarnings("unused")
	public static void writeMat(String fileName, Collection<MLArray> data) throws IOException
    {
        new MatFileWriter( new File(fileName), data );
    }

    /**
	 * Writes <code>MLArrays</code> into file given by <code>fileName</code>.
	 * 
	 * @param fileName
	 *            name of output file
	 * @param data
	 *            A <code>Collection</code> of <code>MLArray</code> elements
	 * @throws IOException
	 *             if there is an error writing to the file
	 * @see #writeMat(String fileName, Collection data)
	 */
    public MatFileWriter(String fileName, Collection<MLArray> data) throws IOException
    {
        this( new File(fileName), data );
    }
    
    
	/**
	 * Writes a collection of <code>MLArrays</code> to the <code>File</code>, <code>file</code>
	 * 
	 * @param file
	 *            The output file
	 * @param data
	 *            A <code>Collection</code> of <code>MLArray</code> elements
	 * @throws IOException
	 *             if there is an error writing to the file
	 */
    @SuppressWarnings("unused")
	public static void writeMat(File file, Collection<MLArray> data) throws IOException
    {
        new MatFileWriter( file, data );
    }

    /**
     * Writes <code>MLArrays</code> into <code>File</code>.
     * 
     * @param file the output <code>File</code>
     * @param data a <code>Collection</code> of <code>MLArray</code> elements
     * @throws IOException if there is an error writing to the file
     * @see #writeMat(File, Collection)
     */
    public MatFileWriter(File file, Collection<MLArray> data) throws IOException
    {
        this( new FileOutputStream(file).getChannel(), data );
    }
    
	/**
	 * Writes a collection of <code>MLArrays</code> to <code>channel</code>
	 * 
	 * @param channel
	 *            The output channel
	 * @param data
	 *            A <code>Collection</code> of <code>MLArray</code> elements
	 * @throws IOException
	 *             if there is an error writing to the channel
	 */
    @SuppressWarnings("unused")
	public static void writeMat(WritableByteChannel channel, Collection<MLArray> data) throws IOException
    {
        new MatFileWriter( channel, data );
    }

    /**
	 * Writes a collection of <code>MLArrays</code> to <code>out</code>
	 * 
	 * @param out
	 *            the stream on which the data will be written. Cannot be null.
	 * @param data
	 *            A <code>Collection</code> of <code>MLArray</code> elements. Cannot be null.
	 * @throws IOException
	 *             if there is an error writing to the channel
     */
    @SuppressWarnings("unused")
	public static void writeMat(OutputStream out, Collection<MLArray> data) throws IOException
    {
        new MatFileWriter( new OutputStreamChannel(out), data );
 
    }

    /**
     * Writes <code>MLArrays<code> into <code>channel</code>.
     * 
     * Writes MAT-file header and compressed data (<code>miCOMPRESSED</code>).
     * 
     * @param channel - <code>WritableByteChannel</code> the output stream
     * @param data - <code>Collection</code> of <code>MLArray</code> elements
     * @throws IOException if there is an error writing to the stream
     */
    public MatFileWriter(WritableByteChannel channel, Collection<MLArray> data) throws IOException
    {
        //write header
        writeHeader(channel);
        
        //write data
        for ( MLArray matrix : data )
        {
            //prepare buffer for MATRIX data
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            DataOutputStream dos = new DataOutputStream( baos );
            //write MATRIX bytes into buffer
            writeMatrix( dos, matrix );
            
            //compress data to save storage
            Deflater compresser = new Deflater();
            
            byte[] input = baos.toByteArray();
            
            ByteArrayOutputStream compressed = new ByteArrayOutputStream();
            DataOutputStream dout = new DataOutputStream(new DeflaterOutputStream(compressed, compresser));
            
            dout.write(input);
            
            dout.close();
            compressed.close();
            
            //write COMPRESSED tag and compressed data into output channel
            byte[] compressedBytes = compressed.toByteArray();
            ByteBuffer buf = ByteBuffer.allocateDirect(2 * 4 /* Int size */ + compressedBytes.length);
            buf.putInt( MatDataTypes.miCOMPRESSED );
            buf.putInt( compressedBytes.length );
            buf.put( compressedBytes );
            
            buf.flip();
            channel.write( buf );
        }
        
        channel.close();        
    }
    
    /**
     * Writes MAT-file header into <code>channel</code>
     * @param channel The stream to which the header will be written
     * @throws IOException if there is an error writing to the channel
     */
    private static void writeHeader(WritableByteChannel channel) throws IOException
    {
        //write descriptive text
        MatFileHeader header = MatFileHeader.createHeader();
        char[] dest = new char[116];
        char[] src = header.getDescription().toCharArray();
        System.arraycopy(src, 0, dest, 0, src.length);
        
        byte[] endianIndicator = header.getEndianIndicator();
        
        ByteBuffer buf = ByteBuffer.allocateDirect(dest.length * 2 /* Char size */ + 2 + endianIndicator.length);
        
        for ( int i = 0; i < dest.length; i++ )
        {
            buf.put( (byte)dest[i] );
        }
        //write subsyst data offset
        buf.position( buf.position() + 8);
        
        //write version
        int version = header.getVersion();
        buf.put( (byte)(version >> 8) );
        buf.put( (byte)version );
        
        buf.put( endianIndicator );
        
        buf.flip();
        channel.write(buf);
    }
    
    /**
     * Writes the matrix <code>array</code> to the stream <code>output</code>.
     * 
     * @param output the stream to which the matrix will be written
     * @param array the array or matrix to write to the stream
     * @throws IOException if there is a problem with writing to <code>output</code>
     */
    private static void writeMatrix(DataOutputStream output, MLArray array) throws IOException
    {   
        OSArrayTag tag;
        ByteArrayOutputStream buffer;         
        DataOutputStream bufferDOS;
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        DataOutputStream dos = new DataOutputStream(baos);
        
        //flags
        writeFlags(dos, array);

        //dimensions
        writeDimensions(dos, array);
        
        //array name
        writeName(dos, array);
        
        switch ( array.getType() )
        {
            case MLArray.mxCHAR_CLASS:
                //write char data
                buffer = new ByteArrayOutputStream();
                bufferDOS = new DataOutputStream(buffer);
                Character[] ac = ((MLChar)array).exportChar();
                for ( int i = 0; i < ac.length; i++ )
                {
                    bufferDOS.writeByte( (byte)ac[i].charValue() );
                }
                tag = new OSArrayTag(MatDataTypes.miUTF8, buffer.toByteArray() );
                tag.writeTo( dos );
                
                break;
            case MLArray.mxDOUBLE_CLASS:
                Double[] ad;                
                
                //write real data
                buffer = new ByteArrayOutputStream();
                bufferDOS = new DataOutputStream(buffer);
                ad = ((MLDouble)array).exportReal();
                for ( int i = 0; i < ad.length; i++ )
                {
                    bufferDOS.writeDouble( ad[i].doubleValue() );
                }
                tag = new OSArrayTag(MatDataTypes.miDOUBLE, buffer.toByteArray() );
                tag.writeTo( dos );
                
                //write real imaginary
                if ( array.isComplex() )
                {
                    buffer = new ByteArrayOutputStream();
                    bufferDOS = new DataOutputStream(buffer);
                    ad = ((MLDouble)array).exportImaginary();
                    for ( int i = 0; i < ad.length; i++ )
                    {
                        bufferDOS.writeDouble( ad[i].doubleValue() );
                    }
                    tag = new OSArrayTag(MatDataTypes.miDOUBLE, buffer.toByteArray() );
                    tag.writeTo( dos );
                }
                break;
            case MLArray.mxSTRUCT_CLASS:
                //field name length
                int itag = 4 << 16 | MatDataTypes.miINT32 & 0xffff;
                dos.writeInt( itag );
                dos.writeInt( ((MLStructure)array).getMaxFieldLenth() );
                
                //get field names
                tag = new OSArrayTag(MatDataTypes.miINT8, ((MLStructure)array).getKeySetToByteArray() );
                tag.writeTo( dos );

                for ( MLArray a : ((MLStructure)array).getAllFields() )
                {
                    writeMatrix(dos, a);
                }
                break;
            case MLArray.mxCELL_CLASS:
                for ( MLArray a : ((MLCell)array).cells() )
                {
                    writeMatrix(dos, a);
                }
                break;
            case MLArray.mxSPARSE_CLASS:
                int[] ai;
                //write ir
                buffer = new ByteArrayOutputStream();
                bufferDOS = new DataOutputStream(buffer);
                ai = ((MLSparse)array).getIR();
                for ( int i : ai )
                {
                        bufferDOS.writeInt( i );
                }
                tag = new OSArrayTag(MatDataTypes.miINT32, buffer.toByteArray() );
                tag.writeTo( dos );
                //write jc
                buffer = new ByteArrayOutputStream();
                bufferDOS = new DataOutputStream(buffer);
                ai = ((MLSparse)array).getJC();
                for ( int i : ai )
                {
                        bufferDOS.writeInt( i );
                }
                tag = new OSArrayTag(MatDataTypes.miINT32, buffer.toByteArray() );
                tag.writeTo( dos );
                //write real
                buffer = new ByteArrayOutputStream();
                bufferDOS = new DataOutputStream(buffer);
                ad = ((MLSparse)array).exportReal();
                for ( int i = 0; i < ad.length; i++ )
                {
                    bufferDOS.writeDouble( ad[i].doubleValue() );
                }
                tag = new OSArrayTag(MatDataTypes.miDOUBLE, buffer.toByteArray() );
                tag.writeTo( dos );
                //write real imaginary
                if ( array.isComplex() )
                {
                    buffer = new ByteArrayOutputStream();
                    bufferDOS = new DataOutputStream(buffer);
                    ad = ((MLSparse)array).exportImaginary();
                    for ( int i = 0; i < ad.length; i++ )
                    {
                        bufferDOS.writeDouble( ad[i].doubleValue() );
                    }
                    tag = new OSArrayTag(MatDataTypes.miDOUBLE, buffer.toByteArray() );
                    tag.writeTo( dos );
                }
                break;
            default:
                throw new MatlabIOException("Cannot write matrix of type: " + MLArray.typeToString( array.getType() ));
                
        }
        
        
        //write matrix
        output.writeInt(MatDataTypes.miMATRIX); //matrix tag
        output.writeInt( baos.size() ); //size of matrix
        output.write( baos.toByteArray() ); //matrix data
    }
    
    /**
     * Writes MATRIX flags into <code>OutputStream</code>.
     * 
     * @param os - <code>OutputStream</code>
     * @param array - a <code>MLArray</code>
     * @throws IOException If there is a problem doing the writing
     */
    private static void writeFlags(DataOutputStream os, MLArray array) throws IOException
    {
        ByteArrayOutputStream buffer = new ByteArrayOutputStream();
        DataOutputStream bufferDOS = new DataOutputStream(buffer);

        bufferDOS.writeInt( array.getFlags() );
        
        if ( array.isSparse() )
        {
            bufferDOS.writeInt( ((MLSparse)array).getMaxNZ() );
        }
        else
        {
            bufferDOS.writeInt( 0 );
        }
        OSArrayTag tag = new OSArrayTag(MatDataTypes.miUINT32, buffer.toByteArray() );
        tag.writeTo( os );
        
    }
    
    /**
     * Writes MATRIX dimensions into <code>OutputStream</code>.
     * 
     * @param os - <code>OutputStream</code>
     * @param array - a <code>MLArray</code>
     * @throws IOException If there is a problem doing the writing
     */
    private static void writeDimensions(DataOutputStream os, MLArray array) throws IOException
    {
        ByteArrayOutputStream buffer = new ByteArrayOutputStream();
        DataOutputStream bufferDOS = new DataOutputStream(buffer);
        
        int[] dims = array.getDimensions();
        for ( int i = 0; i < dims.length; i++ )
        {
            bufferDOS.writeInt(dims[i]);
        }
        OSArrayTag tag = new OSArrayTag(MatDataTypes.miUINT32, buffer.toByteArray() );
        tag.writeTo( os );
        
    }
    
    /**
     * Writes MATRIX name into <code>OutputStream</code>.
     * 
     * @param os - <code>OutputStream</code>
     * @param array - a <code>MLArray</code>
     * @throws IOException if there is a problem doing the writing
     */
    private static void writeName(DataOutputStream os, MLArray array) throws IOException
    {
        ByteArrayOutputStream buffer = new ByteArrayOutputStream();
        DataOutputStream bufferDOS = new DataOutputStream(buffer);

        byte[] nameByteArray = array.getNameToByteArray();
        buffer = new ByteArrayOutputStream();
        bufferDOS = new DataOutputStream(buffer);
        bufferDOS.write( nameByteArray );
        OSArrayTag tag = new OSArrayTag(16, buffer.toByteArray() );
        tag.writeTo( os );
    }
    
    /**
	 * Tiny class that represents MAT-file TAG It simplifies writing data.
	 * Automates writing padding for instance.
	 * 
	 * @author Wojciech Gradkowski (<a
	 *         href="mailto:wgradkowski@gmail.com">wgradkowski@gmail.com</a>)
	 */
    private static class OSArrayTag extends MatTag
    {
        private byte[] data;
        private int padding;
        /**
         * Creates TAG and sets its <code>size</code> as size of byte array
         * 
         * @param type a type id
         * @param data the attached data
         */
        public OSArrayTag(int type, byte[] data )
        {
            super( type, data.length );
            this.data = data;
            this.padding = getPadding(data.length, false);
            
        }
        /**
         * Writes tag and data to <code>DataOutputStream</code>. Wites padding if neccesary.
         * 
         * @param os The stream to write to
         * @throws IOException If there is a problem doing the writing
         */
        public void writeTo(DataOutputStream os) throws IOException
        {
            os.writeInt(type);
            os.writeInt(size);
            
            os.write(data);

            if ( padding > 0 )
            {
                os.write( new byte[padding] );
            }
        }
    }
    
}
