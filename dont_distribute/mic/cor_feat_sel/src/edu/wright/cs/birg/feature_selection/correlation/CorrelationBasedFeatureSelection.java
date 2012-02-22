/**
 * 
 */
package edu.wright.cs.birg.feature_selection.correlation;

import java.io.FileReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.List;

import au.com.bytecode.opencsv.CSVReader;

/**
 * @author Eric Moyer
 *
 */
public class CorrelationBasedFeatureSelection {

	/**
	 * @param args name of input file or (if empty) reads from stdin
	 * 
	 */
	public static void main(String[] args) {
		if(args.length != 0 && args.length != 1){
			System.err.println("Usage: java edu.wright.cs.birg.feature_selection.correlation < filename.csv > features");
			System.err.println(" or: java edu.wright.cs.birg.feature_selection.correlation filename.csv > features");
			System.err.println("Reads a csv from stdin or a file and writes the selected list of features to stdout: 1/line.");
			System.err.println("The csv must have all lines as:");
			System.err.println("var1,var2,correlation");
			System.err.println("var must be either an integer from 0..n or the letter c (for the class variable).");
			System.err.println("Unless n is 0, if variable n is present, variable n-1 must be present (no gaps in numbering)");
			return;
		}

		List<Double> classCor = new java.util.ArrayList<Double>();
		List<Double> featureCor = new java.util.ArrayList<Double>();
		try{
			CSVReader in; 
			if(args.length == 0){
				in = new CSVReader(new InputStreamReader(System.in));
			}else{
				in = new CSVReader(new FileReader(args[0])); 
			}
			
			String[] line;
			while((line = in.readNext()) != null){
				if(line.length != 3){ System.err.println("Error: CSV Line not 3 fields long."); return; }
				if(line[0] != "c"){ String tmp = line[0]; line[0]=line[1]; line[1]=tmp; }
				
			}
		}catch(IOException e){
			String filename;
			if(args.length == 0){
				filename = "the standard input stream";
			}else{
				filename = args[0];
			}
			System.err.println("Error reading from "+filename+": "+e.getMessage());
		}
	}

}
