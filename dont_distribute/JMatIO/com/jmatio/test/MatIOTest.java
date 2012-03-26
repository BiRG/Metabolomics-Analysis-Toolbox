package com.jmatio.test;

import org.junit.Test;
import static org.junit.Assert.assertEquals;
import junit.framework.JUnit4TestAdapter;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Map;

import org.apache.log4j.Logger;

import com.jmatio.io.MatFileFilter;
import com.jmatio.io.MatFileReader;
import com.jmatio.io.MatFileWriter;
import com.jmatio.types.MLArray;
import com.jmatio.types.MLChar;
import com.jmatio.types.MLDouble;

/**
 * The test suite for JMatIO
 * 
 * @author Wojciech Gradkowski <wgradkowski@gmail.com>
 */
public class MatIOTest
{
    static Logger logger = Logger.getLogger( MatIOTest.class );
    /**
     * Tests <code>MLChar</code> reading and writing.
     * 
     * @throws IOException
     */
    @Test public void MLCharArrayTest() throws IOException
    {
        //array name
        String name = "chararr";
        //file name in which array will be storred
        String fileName = "mlchar.mat";
        //temp
        String valueS;

        //create MLChar array of a name "chararr" containig one
        //string value "dummy"
        MLChar mlChar = new MLChar(name, "dummy");
        
        //get array name
        valueS = mlChar.getName();
        assertEquals("MLChar name getter", name, valueS);
        
        //get value of the first element
        valueS = mlChar.getString(0);
        assertEquals("MLChar value getter", "dummy", valueS);
        
        //write array to file
        ArrayList<MLArray> list = new ArrayList<MLArray>();
        list.add( mlChar );
        
        //write arrays to file
        new MatFileWriter( fileName, list );
        
        //read array form file
        MatFileReader mfr = new MatFileReader( fileName );
        MLArray mlCharRetrived = mfr.getMLArray( name );
        
        assertEquals("Test if value red from file equals value stored", mlChar, mlCharRetrived);
        
        //try to read non existent array
        mlCharRetrived = mfr.getMLArray( "nonexistent" );
        assertEquals("Test if non existent value is null", null, mlCharRetrived);
    }
    
    /**
     * Tests <code>MLDouble</code> reading and writing.
     * 
     * @throws IOException
     */
    @Test public void MLDoubleArrayTest() throws IOException
    {
        //array name
        String name = "doublearr";
        //file name in which array will be storred
        String fileName = "mldouble.mat";

        //test column-packed vector
        double[] src = new double[] { 1.3, 2.0, 3.0, 4.0, 5.0, 6.0 };
        //test 2D array coresponding to test vector
        double[][] src2D = new double[][] { { 1.3, 4.0 },
                                            { 2.0, 5.0 },
                                            { 3.0, 6.0 }
                                        };

        //create 3x2 double matrix
        //[ 1.0 4.0 ;
        //  2.0 5.0 ;
        //  3.0 6.0 ]
        MLDouble mlDouble = new MLDouble( name, src, 3 );
        
        //write array to file
        ArrayList<MLArray> list = new ArrayList<MLArray>();
        list.add( mlDouble );
        
        //write arrays to file
        new MatFileWriter( fileName, list );
        
        //read array form file
        MatFileReader mfr = new MatFileReader( fileName );
        MLArray mlArrayRetrived = mfr.getMLArray( name );
        
        //test if MLArray objects are equal
        assertEquals("Test if value red from file equals value stored", mlDouble, mlArrayRetrived);
        
        //test if 2D array match
        for ( int i = 0; i < src2D.length; i++ )
        {
            boolean result = Arrays.equals( src2D[i], ((MLDouble)mlArrayRetrived ).getArray()[i] );
            assertEquals( "2D array match", true, result );
        }
        
        //test new constructor
        MLArray mlDouble2D = new MLDouble(name, src2D );
        //compare it with original
        assertEquals( "Test if double[][] constructor produces the same matrix as normal one", mlDouble2D, mlDouble );
    }
    
    /**
     * Test <code>MatFileFilter</code> options
     */
    @Test public void filterTest()
    {
        //create new filter instance
        MatFileFilter filter = new MatFileFilter();
        
        //empty filter should match all patterns
        assertEquals("Test if empty filter matches all patterns", true, filter.matches("any") );
    
        //now add something to the filter
        filter.addArrayName("my_array");
        
        //test if filter matches my_array
        assertEquals("Test if filter matches given array name", true, filter.matches("my_array") );
        
        //test if filter returns false if does not match given name
        assertEquals("Test if filter does not match non existent name", false, filter.matches("dummy") );
    
    }
    
    /**
     * Tests filtered reading
     * 
     * @throws IOException
     */
    @Test public void filteredReadingTest() throws IOException
    {
        //1. First create arrays
        //array name
        String name = "doublearr";
        String name2 = "dummy";
        //file name in which array will be storred
        String fileName = "filter.mat";

        double[] src = new double[] { 1.3, 2.0, 3.0, 4.0, 5.0, 6.0 };
        MLDouble mlDouble = new MLDouble( name, src, 3 );
        MLChar mlChar = new MLChar( name2, "I am dummy" );
        
        //2. write arrays to file
        ArrayList<MLArray> list = new ArrayList<MLArray>();
        list.add( mlDouble );
        list.add( mlChar );
        new MatFileWriter( fileName, list );
        
        //3. create new filter instance
        MatFileFilter filter = new MatFileFilter();
        filter.addArrayName( name );
        
        //4. read array form file
        MatFileReader mfr = new MatFileReader( fileName, filter );
        
        //check size of
        Map content = mfr.getContent();
        assertEquals("Test if only one array was red", 1, content.size() );
        
    }
    
    public static junit.framework.Test suite()
    {
        return new JUnit4TestAdapter( MatIOTest.class );
    }
    
    
}
