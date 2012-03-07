/**
 * 
 */
package edu.wright.cs.birg.feature_selection.correlation;

import java.io.IOException;
import java.io.InputStreamReader;
import java.io.ObjectInputStream;

import edu.wright.cs.birg.CSVUtil;
import edu.wright.cs.birg.variable_dependence.Variable;

import au.com.bytecode.opencsv.CSVReader;

/**
 * A main operation for the correlation based feature-selection application.
 * 
 * Run causes the operation to take place.
 * @author Eric Moyer
 *
 */
public abstract class Operation implements Runnable {
	/**
	 * Open System.in as a CSVReader printing error messages and exiting if necessary 
	 * @return System.in as a CSVReader
	 */
	protected static CSVReader stdinAsCSV(){
		return new CSVReader(new InputStreamReader(System.in)); 
	}
	
	/**
	 * Open System.in as an ObjectInputStream printing error messages and exiting if necessary 
	 * @return System.in as an ObjectInputStream
	 */
	protected static ObjectInputStream stdinAsObjectInputStream(){
		try{
			return new ObjectInputStream(System.in);
		}catch (IOException e){
			System.err.println("Error trying to create an object input stream from standard input:"+
					e.getMessage());
			System.exit(-1); return null;
		}
	}

	/**
	 * Return the variables read from the given CSV file. The variables are in
	 * columns and the samples in rows.
	 * 
	 * @param in
	 *            The CSV file to read from.
	 * @return the variables read from the given CSV file.
	 */
	protected static Variable[] readVariables(CSVReader in){
		//Read in the 2d array from the test file
		double[][] data;
		String[] varNames;
		try{
			CSVUtil.Matrix m = CSVUtil.csvToMatrix(in);
			data = m.entries;
			varNames = m.header;
		}catch(java.text.ParseException e){
			System.err.println("Error parsing input csv file as a matrix:" + e.getMessage());
			System.exit(-1); return null;
		}catch(IOException e){
			System.err.println("IO Error reading input csv file:" + e.getLocalizedMessage());
			System.exit(-1); return null;
		}
		if(data.length <= 0){ return new Variable[0]; }
		

		//Transpose the array to make an array of variables/features
		double[][] vars = new double[data[0].length][data.length];
		for(int i = 0; i < vars.length; ++i){
			for(int j=0; j < data.length; ++j){
				vars[i][j]=data[j][i];
			}
		}
		
		//Convert the array into an array of variable objects for output
		Variable[] out = new Variable[vars.length];
		for(int i = 0; i < vars.length; ++i){
			out[i] = new Variable(varNames[i], vars[i], i);
		}
		return out;
	}
	
	/**
	 * Print the usage message follwed by msg on its own line. If msg is null, it is not printed, 
	 * but the usage is still printed.
	 * @param msg The message to print after the usage message. not printed if null.
	 */
	public static void printUsage(String msg){
		CorrelationBasedFeatureSelection.printUsage(msg);
	}
	
	/**
	 * Return a Dependences object read from java serialization data on standard input. Prints a message to 
	 * System.err and exits the JVM if there is an error reading the object.
	 * 
	 * @return a Dependences object read from java serialization data on standard input
	 */
	public static Dependences dependencesFromStdin(){
		Dependences deps;
		try{
			ObjectInputStream depsIn = stdinAsObjectInputStream();
			deps = (Dependences) depsIn.readObject();
		}catch(IOException e){
			System.err.println("Error reading dependencies from standard input stream");
			System.exit(-1); return null;
		}catch(Exception e){
			System.err.println("Error deserializing dependencies from standard input stream:"+e.getMessage());
			e.printStackTrace(System.err);
			System.exit(-1); return null;			
		}
		return deps;
	}
}
