/**
 * 
 */
package edu.wright.cs.birg.feature_selection.correlation;

import java.io.IOException;
import java.io.InputStreamReader;
import java.io.ObjectOutputStream;
import java.util.Arrays;
import java.util.Collections;
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
	 * Print the usage message followed by msg on its own line. If msg is null, it is not printed, 
	 * but the usage is still printed.
	 * @param msg The message to print after the usage message. not printed if null.
	 */	
	@Exemplars(set={
	@Exemplar(args={"'foo'"}, expect=""),
	@Exemplar(args={"null"}, expect=""), 
	})
	public static void printUsage(String msg){
		System.err.println("Usage: java -jar cbfs.jar -dependences method < input_data.csv > dependences.ser");		
		System.err.println(" or:   java -jar cbfs.jar -features labelIndex -bestFirst numFailures < dependences.ser > features.txt");
		System.err.println(" or:   java -jar cbfs.jar -features labelIndex -beam numFailures beamSize < dependences.ser > features.txt");
		System.err.println(" or:   java -jar cbfs.jar -maxBeamSize < dependences.ser > maxBeamSize.txt");		
		System.err.println(" or:   java -jar cbfs.jar -testData < input_data.csv > test_data.txt");
		System.err.println("");
		System.err.println("-dependences reads in a csv and ouputs the dependences between the ");
		System.err.println("                 different attributes to a binary file.");
		System.err.println("");
		System.err.println("-features: reads in a binary file giving the dependences between ");
		System.err.println("              attributes. writes the selected list of features to ");
		System.err.println("              stdout: 1 per line.");
		System.err.println("");
		System.err.println("-testData: reads in a csv. Then prints test lines to stdout.");
		System.err.println("");
		System.err.println("-maxBeamSize: reads in the dependences and outputs a number that is the ");
		System.err.println("              beam size one lower than one which causes an out of memory exception");
		System.err.println("              Divide this by 3 to get a guess for the largest beam one can");
		System.err.println("              use in \"-features ... beam\" without running out of memory.");
		System.err.println("");
		System.err.println("-beam: an argument to -features that generates the features using a beam ");
		System.err.println("       search that terminates when numFailures expansions have failed to ");
		System.err.println("       improve the best item in the beam");
		System.err.println("");
		System.err.println("method: the method used to calculate the dependence between features.");
		System.err.println("        it can be one of: mic, pearson");
		System.err.println("");
		System.err.println("labelIndex: the column index of the class feature. First column is 0.");
		System.err.println("");
		System.err.println("input_data.csv the columns of the csv are features and the rows are samples.");
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
			System.err.print(" "+v1.getIndex());
			for(int f2 = 0; f2 < numFeatures; ++f2){
				Variable v2 = dat.features[f2];
				featureDep[f1][f2] = featureDep[f2][f1] = measure.dependence(v1, v2);
			}
		}
		System.err.println();
	
		//Do the feature selection
		FeatureSet bestSet;
		try{
			bestSet=bestFirstSearch(classDep, featureDep, non_improvements_before_quit);
		}catch (BestFirstSearchRanOutOfMemoryException e){
			bestSet=beamSearch(classDep, featureDep, e.getMaxQueueSize()/3, non_improvements_before_quit);
		}
		int[] best = bestSet.features();
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
		if(args.length < 1){
			printUsage("ERROR: Wrong number of arguments - missing main operation argument");
			return;
		}
		Operation operation;
		String[] restOfArgs = Arrays.copyOfRange(args, Math.min(1, args.length), args.length);
		if("testData".equals(args[0])){
			operation = new TestDataOperation(restOfArgs);			
		}else if("features".equals(args[0])){
			operation = new FeatureSelectionOperation(restOfArgs);
		}else if("dependences".equals(args[0])){
			operation = new DependenceCalculationOperation(restOfArgs);
		}else if("maxBeamSize".equals(args[0])){
			operation = new MaxBeamSizeOperation(restOfArgs);
		}else{
			printUsage("ERROR: Unknown operation \""+args[0]+"\"");
			return;
		}
		operation.run();
	}
	
	private static FeatureSet bestFirstSearch(double[] classDep,
			double[][] featureDep, int nonImprovementsBeforeQuit) throws BestFirstSearchRanOutOfMemoryException {
		int numFeatures = classDep.length;

		//Set up the priority queue for best-first with an empty feature set to start with
		PriorityQueue<FeatureSet> unexplored = 
				new PriorityQueue<FeatureSet>(numFeatures*numFeatures, 
						new BetterFeatureSetCBFS(classDep, featureDep));
		unexplored.add(new FeatureSet(numFeatures));
		int oomQueueSize; //queue size variable for use by the out of memory handler 
		
		try{
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
		}catch (OutOfMemoryError e){
			//Save the number of elements in the queue
			oomQueueSize = unexplored.size();
			//Clear the queue to free up memory
			unexplored.clear();
			//Throw a new exception to alert the caller
			throw new BestFirstSearchRanOutOfMemoryException(oomQueueSize);
		}
		
	}
	
	private static FeatureSet beamSearch(double[] classDep,
			double[][] featureDep, int maxBeamSize, int nonImprovementsBeforeQuit) {
		int numFeatures = classDep.length;

		SearchBeam<FeatureSet> oldBeam = new SearchBeam<FeatureSet>
			(maxBeamSize, new BetterFeatureSetCBFS(classDep, featureDep));
		oldBeam.add(new FeatureSet(numFeatures));
		int numUnsuccessfulExpansions = 0;
		while(numUnsuccessfulExpansions < nonImprovementsBeforeQuit){
			//Expand old beam into new beam
			
			//Start with the elements from the old beam.  The benefit of this method is we'll never lose a
			//good solution. The drawback is that a good solution with poor descendants will be expanded
			//many times. The shallow copy is to make it so memory doesn't grow more than it has to.
			SearchBeam<FeatureSet> newBeam = oldBeam.shallowCopy();
			
			//Add all successors (eliminating the worst elements that don't fit in the beam)
			for(FeatureSet f:oldBeam){
				Collections.addAll(newBeam, f.allSetsWithOneFeatureMore());
			}
			
			//If score of top candidates in old beam and new beam is the same, this is an unsuccessful
			//expansion. Note that the score cannot decrease because we start the beam with all of the old elements
			if(newBeam.best().cbfsScore(classDep, featureDep) == oldBeam.best().cbfsScore(classDep, featureDep)){
				++numUnsuccessfulExpansions;
			}else{
				numUnsuccessfulExpansions = 0;
			}
						
			//Make the new beam into the old beam
			oldBeam = newBeam;
		}
		return oldBeam.best();
	}

}
