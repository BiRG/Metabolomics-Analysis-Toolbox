/**
 * 
 */
package edu.wright.cs.birg;

import java.io.IOException;
import java.util.List;

import org.sureassert.uc.annotation.Exemplar;

import au.com.bytecode.opencsv.CSVReader;

/**
 * @author Eric Moyer
 *
 */
public final class CSVUtil {
	/**
	 * Private 0-argument constructor to keep unsuspecting people from implementing
	 */
	@Exemplar(expect="isa(retval,CSVUtil)")
	private CSVUtil(){}

	/**
	 * Return a 2D matrix composed of the entries in the csv file.
	 * 
	 * All the lines in the csv file must be the same length (except for blank
	 * lines). All fields must be doubles with one exception. If the first line
	 * has an entry that is not a parseable as a number, it will be ignored
	 * (this enables files with text headers)
	 * 
	 * @param in
	 *            The csv file to read from
	 * @return a 2D matrix composed of the entries in the csv file
	 * @throws IOException
	 *             if there was a problem reading from the csv
	 * @throws java.text.ParseException
	 *             if all of the non-blank lines were not the same length or if
	 *             there were non-numbers in the input (after the first line).
	 *             The offset field is set to the line number (first line being
	 *             line 1.
	 */
	public static double[][] csvToMatrix(CSVReader in) 
			throws IOException, java.text.ParseException{
		List<double[]> ld = new java.util.LinkedList<double[]>();
		
		String[] line;
		Integer len = null;
		int linesRead = 0;
		while((line = in.readNext()) != null){
			++linesRead;
			
			//Skip blank lines
			if(line.length == 0){ continue; } 
			
			//Ensure that all lines are the same length
			if(len == null){ len = new Integer(line.length); }
			if(len.intValue() != line.length){
				throw new java.text.ParseException(
						"Line "+linesRead+" of the input file had "+line.length+
						" fields, but all previous lines had "+len+" fields. "+
						"csvToMatrix only works on files which have the same number "+
						"of fields on each line.",
						linesRead);
			}
			
			//Convert the line to double
			int i = 0; //declare the loop variable here so I can use it in the 
			double[] data = new double[line.length];
			try{
				for(i = 0; i < line.length; ++i){
					data[i] = Double.parseDouble(line[i]);
				}
			}catch(java.lang.NumberFormatException e){
				if(linesRead == 1){ 
					continue;  //Allow for a header on the first line
				}else{ 
					throw new java.text.ParseException(
							"Line "+linesRead+" had field "+i+" as "+line[i]+
							"which could not be interpreted as a real number. (Note:"+
							"the first field is numbered 0).",
							linesRead);
				}
			}
			ld.add(data);
		}
		
		//Now we have a list of lines all the same length, move them to an array
		double[][] out = new double[ld.size()][];
		int rowNum = 0;
		for(double[] row:ld){
			out[rowNum++]=row;
		}
		
		return out;
	}


}
