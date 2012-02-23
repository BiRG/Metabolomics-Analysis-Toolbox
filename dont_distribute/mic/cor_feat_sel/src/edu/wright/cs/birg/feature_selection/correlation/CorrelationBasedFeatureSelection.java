/**
 * 
 */
package edu.wright.cs.birg.feature_selection.correlation;

import java.io.FileReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.LinkedList;
import java.util.List;

import au.com.bytecode.opencsv.CSVReader;

/**
 * @author Eric Moyer
 *
 */
public class CorrelationBasedFeatureSelection {

	private static final double default_correlation = 0.0000001;
	
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
			System.err.println("var1 must be either an integer from 0..n or the letter c (for the class variable).");
			System.err.println("var2 must be an integer from 0..n.  If var1 is not c then var1 < var2 must hold.");
			System.err.println("correlation must be the decimal representation of a real number");
			System.err.println("");
			System.err.println("Unless n is 0, if variable n is present, variable n-1 is assumed to exist (no gaps in numbering)");
			System.err.println("Any pairs that do not get assigned a \"correlation\" value will be given a value of "+default_correlation);
			System.err.println("because that is the cutoff MINE.jar uses for display");
			return;
		}

		int numFeatures = 0;
		double[] classCor = null;
		double[][] featureCor = null;
		try{
			CSVReader in; 
			if(args.length == 0){
				in = new CSVReader(new InputStreamReader(System.in));
			}else{
				in = new CSVReader(new FileReader(args[0])); 
			}
			
			//Read in lines into lists of class-feature correlations and feature-feature correlations, counting the number of features
			class CFCor{ int feat; double cor; public CFCor(int f, double c){feat = f; cor = c; } }
			class FFCor{ int feat1; int feat2; double cor; public FFCor(int f1, int f2, double c){feat1 = f1; feat2 = f2; cor = c; } }
			List<CFCor> cfcors = new LinkedList<CFCor>();
			List<FFCor> ffcors = new LinkedList<FFCor>();
			String[] line;
			while((line = in.readNext()) != null){
				if(line.length != 3){ System.err.println("Error: CSV Line not 3 fields long."); return; }
				numFeatures = Math.max(numFeatures, 1+Integer.parseInt(line[1]));

				int f1 = Integer.parseInt(line[1]);
				double cor = Double.parseDouble(line[2]);
				if(line[0].equals("c")){
					cfcors.add(new CFCor(f1,cor));
				}else{
					int f0 = Integer.parseInt(line[0]);
					ffcors.add(new FFCor(f0,f1,cor));
				}				
			}
			in.close();
			
			//Initialize arrays of class-feature correlations and feature-feature correlations to NaN using the now known number of features
			classCor = new double[numFeatures];
			featureCor = new double[numFeatures][numFeatures];
			for(int i = 0; i < numFeatures; ++i){
				classCor[i]=Double.NaN;
				for(int j = 0; j < numFeatures; ++j){
					featureCor[i][j]=Double.NaN;
				}
			}
			
			//Take values read in and transfer them to the arrays
			for(CFCor cur: cfcors){
				classCor[cur.feat]=cur.cor;
			}
			for(FFCor cur: ffcors){
				featureCor[cur.feat1][cur.feat2]=cur.cor;
				featureCor[cur.feat2][cur.feat1]=cur.cor;
			}
			
			//Initialize all correlations not read in to default_correlation
			for(int i = 0; i < numFeatures; ++i){
				if(Double.isNaN(classCor[i])){ classCor[i]=default_correlation; }
				for(int j = 0; j < numFeatures; ++j){
					if(Double.isNaN(featureCor[i][j])){ featureCor[i][j]=default_correlation; }
				}
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
		for(int i = 0; i < numFeatures; ++i){
			System.out.println("c,"+i+","+classCor[i]);
			for(int j = 0; j < numFeatures; ++j){
				System.out.println(i+","+j+","+featureCor[i][j]);
			}
		}
	}

}
