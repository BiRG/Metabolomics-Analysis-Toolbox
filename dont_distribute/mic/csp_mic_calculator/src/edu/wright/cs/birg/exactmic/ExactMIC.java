/**
 * 
 */
package edu.wright.cs.birg.exactmic;

import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.util.ArrayList;
import java.util.List;

import au.com.bytecode.opencsv.CSVReader;
import au.com.bytecode.opencsv.CSVWriter;

/**
 * @author Eric Moyer
 *
 */
public class ExactMIC {

	/**
	 * @param args The command line arguments
	 */
	public static void main(String[] args) {
		if(args.length != 0){
			System.err.println("Usage: java edu.wright.cs.birg.exactmic < filename.csv > mics.csv");
			System.err.println("Prints the exact mic's for all pairs of variables in filename to stdout.");
			System.err.println("If the first line of filename is not all numeric, it is assumed to be a header line");
			return;
		}
		
		// Initialize data and header from the file (if the file has no header, one is created for it)
		List<double[]> data = null;
		String[] header = null;
		try {
			List<String[]> contents = (new CSVReader(new InputStreamReader(System.in))).readAll();
			data = new ArrayList<double[]>(contents.size());
			
			//Convert the data to double
			for(String[] line: contents){
				double[] row = new double[line.length];
				try{
					for(int i = 0; i < line.length; ++i){
						row[i]=Double.parseDouble(line[i]);
					}
					data.add(row);
					if(row.length != data.get(0).length){
						System.err.println("Error: Row "+data.size()+" in the data file had a different "+
								"number of elements from the first row.  All rows in the CSV " + 
								"must be the same length.");
					}
				} catch(NumberFormatException e){
					//Skip lines that contain things that can't be parsed as doubles
					//
					//The first unparsable line is treated as the header
					if(header==null){ header = line; }
				}
			}
			
			if(data.size()==0){
				System.err.println("Error: The CSV file must have at least one row which only contains "+
						"numeric data.  The CSV file on standard input had no such rows.  Cannot process.");
				return;
			}
			
			if(data.get(0).length==0){
				System.err.println("The CSV file has only 0-length lines.  Cannot process.");
				return;
			}
			
			// Create a header if there was none 
			if(header == null){
				header = new String[data.get(0).length];
				for(int i = 0; i < header.length; ++i){
					header[i]="Variable["+i+"]";
				}
			}
			
			// Ensure that the header is the right length by padding it with default values if necessary
			if(header.length < data.get(0).length){
				String[] oldHeader = header;
				header = new String[data.get(0).length];
				for(int i = 0; i < header.length; ++i){
					if(i < oldHeader.length){
						header[i]=oldHeader[i];
					}else{
						header[i]="Variable["+i+"]";
					}
				}
			}
		} catch (IOException e) {
			System.err.println("Error trying to parse CSV from standard input.");
			return;
		}
		
		assert(header != null && data.size() > 0 && data.get(0).length > 0);

		// vars holds the individual variables represented in the CSV file
		SampleVariable[] vars=new SampleVariable[data.get(0).length];
		for(int i=0; i < vars.length; ++i){
			double[] col = new double[data.size()];
			for(int j=0; j < data.size(); ++j){
				col[j]=data.get(i)[j];
			}
			vars[i]=new SampleVariable(header[i],col);
		}
		
		// Create the object that writes the CSV to standard output
		CSVWriter out = new CSVWriter(new OutputStreamWriter(System.out));

		// Write the output header
		String[] outputHeader = {"X Var Index","Y Var Index","X Var Name","Y Var Name","Maximal Information Coefficient"};
		out.writeNext(outputHeader);
		
		// loop through all non-identical pairs of variables, printing the results to output at each pass
		java.text.NumberFormat micFormat=java.text.NumberFormat.getInstance();
		micFormat.setGroupingUsed(false);
		micFormat.setMinimumFractionDigits(Math.min(18,micFormat.getMaximumFractionDigits()));
		for(int i = 0; i < vars.length; ++i){
			SampleVariable x=vars[i];
			for(int j = i+1; j < vars.length; ++j){
				SampleVariable y=vars[j];
				double mic = calcMIC(vars[i],vars[j]);
				String[] line = {Integer.toString(i),Integer.toString(j),
						x.getName(), y.getName(), micFormat.format(mic)
				};
				out.writeNext(line);
			}
		}
	}

	private static double calcMIC(SampleVariable x,
			SampleVariable y) {
		// TODO Auto-generated method stub
		return 0;
	}

}
