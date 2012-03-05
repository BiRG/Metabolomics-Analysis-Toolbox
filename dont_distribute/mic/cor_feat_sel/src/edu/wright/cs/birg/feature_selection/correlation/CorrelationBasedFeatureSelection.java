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
import edu.wright.cs.birg.variable_dependence.MaximalInformationCoefficientMeasure;
import edu.wright.cs.birg.variable_dependence.PearsonCorrelationMeasure;
import edu.wright.cs.birg.variable_dependence.SymmetricDependenceMeasure;
import edu.wright.cs.birg.variable_dependence.Variable;

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
		System.err.println("Usage: java -jar cbfs.jar -genfeatures method labelIndex < input_data.csv > features");
		System.err.println(" or:   java -jar cbfs.jar -gentestdata < input_data.csv > test_data.txt");
		System.err.println(" or:   java -jar cbfs.jar -gentestdata input_data.csv > test_data.txt");
		System.err.println("");
		System.err.println("Reads a csv from stdin or a file ");
		System.err.println("-genfeatures: writes the selected list of features to stdout: 1 per line.");
		System.err.println("");
		System.err.println("method: the method used to calculate the dependence between features.");
		System.err.println("        it can be one of: mic, pearson");
		System.err.println("");
		System.err.println("labelIndex: the column index of the class feature. First column is 0.");
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
	private static Variable[] readVariables(CSVReader in){
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
	 * Reads data matrix from in and writes list of features to stdout
	 * @param in CSV file holding the data matrix
	 * @param labelIndex 0-based index of the class feature - there must be at least 1 other feature
	 * @param measure The dependence measure to use
	 */
	private static void generateFeatures(CSVReader in, final int labelIndex, SymmetricDependenceMeasure measure){
		//Read in the variables
		Variable[] vars = readVariables(in);
		
		//Separate out the label from the rest of the data
		SupervisedData dat = new SupervisedData(vars, labelIndex);
				
		//Calculate class-feature dependence
		int numFeatures = dat.features.length;
		double[] classDep = new double[numFeatures];
	
		System.err.println("Calculating class dependence using "+measure.name());		
		System.err.println("Calculating class dependence on feature:");
		for(int feat = 0; feat < numFeatures; ++feat){
			System.err.print(" "+dat.features[feat].getIndex());
			classDep[feat]=measure.dependence(dat.features[feat], dat.label);
		}
		
		//Calculate feature-feature dependence
		System.err.print("Calculating dependence on feature:");
		double[][] featureDep = new double[numFeatures][numFeatures];
		for(int f1 = 0; f1 < numFeatures; ++f1){
			featureDep[f1][f1] = 1.0;
			Variable v1 = dat.features[f1];
			System.err.print(" "+v1.getIndex()+"(");
			for(int f2 = 0; f2 < numFeatures; ++f2){
				Variable v2 = dat.features[f2];
				System.err.print(" "+v2.getIndex());
				featureDep[f1][f2] = featureDep[f2][f1] = measure.dependence(v1, v2);
			}
			System.err.print(" )");
		}
		System.err.println();
	
		//Do the feature selection
		int[] best = bestFirstSearch(classDep, featureDep, non_improvements_before_quit).features();
		for(int i = 0; i < best.length; ++i){
			int featureNumber = best[i];
			Variable feature = dat.features[featureNumber];
			System.out.println(feature.getIndex());
		}
		
	}
	
	/**
	 * @param args name of input file or (if empty) reads from stdin
	 * 
	 */
	public static void main(String[] args) {
		if(args.length != 1 && args.length != 3){
			printUsage("ERROR: Wrong number of arguments");
			return;
		}

		if(!(args[0].equals("-gentestdata") || args[0].equals("-genfeatures"))){
			printUsage("ERROR: Unknown output generation option \""+args[1]+"\"");
			return;
		}
		boolean genFeatures = args[0].equals("-genfeatures");

		if(genFeatures){
			if(args.length != 3){
				printUsage("ERROR: You must include dependence measure method and a class feature index to select features for predicting that class.");
				return;
			}
			try{
				Integer.parseInt(args[1]);
			}catch (NumberFormatException e){
				printUsage("ERROR: The argument to -genfeatures must be an integer");
				return;
			}
		}
		SymmetricDependenceMeasure measure = null;
		if(genFeatures){
			if(args[2].equals("mic")){
				measure = new MaximalInformationCoefficientMeasure();
			}else if(args[2].equals("pearson")){
				measure = new PearsonCorrelationMeasure();
			}else{
				printUsage("ERROR: \""+args[2]+"\" is not a known dependence calculation method.");
				return;
			}
		}
		
		try{
			CSVReader in = new CSVReader(new InputStreamReader(System.in)); 

			if(genFeatures){
				assert(args.length == 2);
				generateFeatures(in, Integer.parseInt(args[1]), measure);
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

	private static FeatureSet bestFirstSearch(double[] classDep,
			double[][] featureDep, int nonImprovementsBeforeQuit) {
		int numFeatures = classDep.length;

		//Set up the priority queue for best-first with an empty feature set to start with
		PriorityQueue<FeatureSet> unexplored = 
				new PriorityQueue<FeatureSet>(numFeatures*numFeatures, 
						new BetterFeatureSetCBFS(classDep, featureDep));
		unexplored.add(new FeatureSet(numFeatures));
		
		//Remove the top of the queue and expand it each iteration
		int numUnsuccessfulExpansions = 0;
		FeatureSet best = unexplored.peek();
		double lastBestScore = best.cbfsScore(classDep, featureDep);
		while(numUnsuccessfulExpansions < nonImprovementsBeforeQuit &&
				!unexplored.isEmpty()){
			FeatureSet good = unexplored.remove();
			unexplored.addAll(Arrays.asList(good.allSetsWithOneFeatureMore()));
			
			FeatureSet top = unexplored.peek();
			double topScore = top.cbfsScore(classDep, featureDep); 
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
