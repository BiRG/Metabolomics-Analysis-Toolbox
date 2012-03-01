/**
 * 
 */
package edu.wright.cs.birg.feature_selection.correlation;

import java.io.IOException;
import java.io.InputStreamReader;
import java.util.Arrays;
import java.util.PriorityQueue;

import org.sureassert.uc.annotation.Exemplars;
import org.sureassert.uc.annotation.Exemplar;

import edu.wright.cs.birg.CSVUtil;
import edu.wright.cs.birg.mic.MIC;
import edu.wright.cs.birg.test.ArrayUtils;

import au.com.bytecode.opencsv.CSVReader;

/**
 * @author Eric Moyer
 *
 */
public class CorrelationBasedFeatureSelection {

	/**
	 * The number of nodes that can be expanded without improving the solution before the best-first optimization quits.
	 * That is if non_improvements_before_quit is 5, then on the if there have been 4 feature-sets in a row 
	 * for which none of the solutions with one more feature have had a better optimum value, then if the next 
	 * feature-set's children also do not have a better value, the search is terminated and the smallest of the feature
	 * sets with this optimum value is returned.
	 */
	private static final int non_improvements_before_quit = 5;
		
	/**
	 * Print the usage message follwed by msg on its own line. If msg is null, it is not printed, 
	 * but the usage is still printed.
	 * @param msg The message to print after the usage message. not printed if null.
	 */
	
	@Exemplars(set={
	@Exemplar(args={"'foo'"}, expect=""),
	@Exemplar(args={"null"}, expect=""), 
	})
	public static void printUsage(String msg){
		System.err.println("Usage: java -jar cbfs.jar -genfeatures classIdx < input_data.csv > features");
		System.err.println(" or:   java -jar cbfs.jar -gentestdata < input_data.csv > test_data.txt");
		System.err.println(" or:   java -jar cbfs.jar -gentestdata input_data.csv > test_data.txt");
		System.err.println("");
		System.err.println("Reads a csv from stdin or a file and if the option is -genfeatures");
		System.err.println("writes the selected list of features to stdout: 1 per line.");
		System.err.println("classIdx is the column index of the class feature. First column is 0.");
		System.err.println("");
		System.err.println("The -gentestdata option reads in a csv but the columns of the csv ");
		System.err.println("are features and the rows are samples. Then appropriate test lines ");
		System.err.println("are printed to stdout.");
		System.err.println("");
		System.err.println("The first line of the csv may be a header (if it is, it must ");
		System.err.println("contain a letter).  All other lines must be the same length and must ");
		System.err.println("have the decimal representation of a real number. The columns of the ");
		System.err.println("csv are features and the rows are samples.");
		if(msg != null){
			System.err.println("");			
			System.err.println(msg);
		}
	}
	
	/**
	 * Reads data matrix from in and writes list of features to stdout
	 * @param in CSV file holding the data matrix
	 * @param classIdx 0-based index of the class feature - there must be at least 1 other feature
	 */
	private static void generateFeatures(CSVReader in, final int classIdx){
		//Read in the 2d array from the test file
		double[][] data;
		String[] varNames;
		try{
			CSVUtil.Matrix m = CSVUtil.csvToMatrix(in);
			data = m.entries;
			varNames = m.header;
		}catch(java.text.ParseException e){
			System.err.println("Error parsing input csv file as a matrix:" + e.getMessage());
			System.exit(-1); return;
		}catch(IOException e){
			System.err.println("IO Error reading input csv file:" + e.getLocalizedMessage());
			System.exit(-1); return;
		}
		if(data.length <= 0){ return; }
		

		//Transpose the array to make an array of variables/features
		double[][] vars = new double[data[0].length][data.length];
		for(int i = 0; i < vars.length; ++i){
			for(int j=0; j < data.length; ++j){
				vars[i][j]=data[j][i];
			}
		}

		//Ensure valid classIdx input
		if(classIdx < 0 || classIdx >= vars.length){
			throw new IllegalArgumentException("classIdx out of bounds: classIdx was "+classIdx+" when there "+
					"were only "+vars.length+" variables.  Legal indices were 0.."+(vars.length-1));
		}
		
		//Separate features and class from one another
		int numFeatures = varNames.length-1;
		double[] classV = vars[classIdx];
		double[][] featureV = new double[numFeatures][];
		for(int feat = 0; feat < numFeatures; ++feat){
			if(feat < classIdx){
				featureV[feat]=vars[feat];
			}else if(feat > classIdx){
				featureV[feat]=vars[feat+1];
			}else{
				//Do nothing, this is the class variable
			}
		}

		//Calculate class-feature MICs
		double[] classCor = new double[numFeatures];
	
		System.err.println("Calculating class MICs.");
		
		for(int feat = 0; feat < numFeatures; ++feat){
			classCor[feat]=MIC.mic(featureV[feat], classV);
		}
		
		//Calculate feature-feature MICs
		System.err.print("Calculating MICs for feature:");
		double[][] featureCor = new double[numFeatures][numFeatures];
		for(int f1 = 0; f1 < numFeatures; ++f1){
			System.err.print(" "+f1);
			featureCor[f1][f1] = 1.0;
			double[] v1 = featureV[f1];
			for(int f2 = 0; f2 < numFeatures; ++f2){
				double[] v2 = featureV[f2];
				featureCor[f1][f2] = featureCor[f2][f1] = MIC.mic(v1,v2);
			}
		}
		System.err.println();
	
		//Do the feature selection
		int[] best = bestFirstSearch(classCor, featureCor, non_improvements_before_quit).features();
		for(int i = 0; i < best.length; ++i){
			System.out.println(best[i]);
		}
		
	}
	
	/**
	 * @param args name of input file or (if empty) reads from stdin
	 * 
	 */
	public static void main(String[] args) {
		if(args.length != 1 && args.length != 2){
			printUsage("Wrong number of arguments");
			return;
		}

		if(!(args[0].equals("-gentestdata") || args[0].equals("-genfeatures"))){
			printUsage("Unknown output generation option \""+args[1]+"\"");
		}
		boolean genFeatures = args[0].equals("-genfeatures");

		if(genFeatures){
			if(args.length != 2){
				printUsage("You must include a class feature index to select features for predicting that class.");
				return;
			}
			try{
				Integer.parseInt(args[1]);
			}catch (NumberFormatException e){
				printUsage("The argument to -genfeatures must be an integer");
				return;
			}
		}
		
		try{
			CSVReader in = new CSVReader(new InputStreamReader(System.in)); 

			if(genFeatures){
				assert(args.length == 2);
				generateFeatures(in, Integer.parseInt(args[1]));
				return;
			}else{
				generateTestData(in);
				return;
			}
		} catch (IOException e) {
			String filename;
			if (args.length == 0) {
				filename = "the standard input stream";
			} else {
				filename = args[0];
			}
			System.err.println("Error reading from " + filename + ": "
					+ e.getMessage());
		}
	}
	
	/**
	 * Prints test data to stdout generated from the input csv file.
	 * 
	 * The input csv must be all doubles and the same number of columns on every row.
	 * There must be at least one row.
	 * @param in The csv file used as input
	 * 
	 * @throws IOException if there is a problem reading from the CSVReader
	 */
	private static void generateTestData(CSVReader in) throws IOException {
	
		//Read in the 2d array from the test file
		double[][] data;
		try{
			data = CSVUtil.csvToMatrix(in).entries;
		}catch(java.text.ParseException e){
			System.err.println("Error parsing input csv file as a matrix:" + e.getMessage());
			System.exit(-1); return;
		}
		if(data.length <= 0){ return; }
		
		double[][] vars = new double[data[0].length][data.length];
		for(int i = 0; i < vars.length; ++i){
			for(int j=0; j < data.length; ++j){
				vars[i][j]=data[j][i];
			}
		}
		for(int i = 0; i < vars.length; ++i){
			double[] x = vars[i];
			for(int j = i+1; j < vars.length; ++j){
				double[] y = vars[j];
				for (int numBins = 4; numBins <= x.length; ++numBins) {
					double clumpRatio = 15; //Later vary this
					double[][] result = MIC.testApproxMatrix(x, y, numBins,
							clumpRatio);
					System.out.println("@Exemplar(a={"
							+ ArrayUtils.qExemplar(x) + ","
							+ ArrayUtils.qExemplar(y) + ",\"" + numBins
							+ "\",\"" + clumpRatio + "\"},e={\"#=(retval,"
							+ ArrayUtils.exemplarString(result) + ")\"}),");

				}
			}
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
