/**
 * 
 */
package edu.wright.cs.birg.feature_selection.correlation;

import java.io.FileReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.Arrays;
import java.util.LinkedList;
import java.util.List;
import java.util.PriorityQueue;

import au.com.bytecode.opencsv.CSVReader;

/**
 * @author Eric Moyer
 *
 */
public class CorrelationBasedFeatureSelection {

	/**
	 * The default correlation that will be given to any entries not appearing in the input file
	 */
	private static final double default_correlation = 0.0000001;
	
	/**
	 * The number of nodes that can be expanded without improving the solution before the best-first optimization quits.
	 * That is if non_improvements_before_quit is 5, then on the if there have been 4 feature-sets in a row 
	 * for which none of the solutions with one more feature have had a better optimum value, then if the next 
	 * feature-set's children also do not have a better value, the search is terminated and the smallest of the feature
	 * sets with this optimum value is returned.
	 */
	private static final int non_improvements_before_quit = 5;
		
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
		
		int[] best = bestFirstSearch(classCor, featureCor, non_improvements_before_quit).features();
		for(int i = 0; i < best.length; ++i){
			System.out.println(best[i]);
		}
	}

	private static FeatureSet bestFirstSearch(double[] classCor,
			double[][] featureCor, int nonImprovementsBeforeQuit) {
		int numFeatures = classCor.length;

		//Set up the priority queue for best-first with an empty feature set to start with
		PriorityQueue<FeatureSet> unexplored = 
				new PriorityQueue<FeatureSet>(numFeatures*numFeatures, 
						new BetterFeatureSetCBFS(classCor, featureCor));
		unexplored.add(new FeatureSet(numFeatures));
		
		//Remove the top of the queue and expand it each iteration
		int numUnsuccessfulExpansions = 0;
		FeatureSet best = unexplored.peek();
		double lastBestScore = best.cbfsScore(classCor, featureCor);
		while(numUnsuccessfulExpansions < nonImprovementsBeforeQuit &&
				!unexplored.isEmpty()){
			FeatureSet good = unexplored.remove();
			unexplored.addAll(Arrays.asList(good.allSetsWithOneFeatureMore()));
			
			FeatureSet top = unexplored.peek();
			double topScore = top.cbfsScore(classCor, featureCor); 
			if(topScore > lastBestScore){
				lastBestScore = topScore; best = top; numUnsuccessfulExpansions = 0;
				//System.err.println("New Best:"+best+". Score:"+ topScore); //TODO: remove
			}else{
				++numUnsuccessfulExpansions;
			}
		}
		
		return best;
	}

}
