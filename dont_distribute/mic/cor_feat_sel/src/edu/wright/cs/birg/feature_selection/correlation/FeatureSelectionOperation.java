/**
 * 
 */
package edu.wright.cs.birg.feature_selection.correlation;

import java.io.IOException;
import java.io.ObjectInputStream;
import java.util.Arrays;

/**
 * Performs CBFS feature selection with a particular search methodology given the 
 * Dependences structure read from standard input 
 * @author Eric Moyer
 *
 */
public class FeatureSelectionOperation extends Operation {
	/**
	 * The algorithm used to search for the optimum feature set
	 */
	FeatureSelectionSearchMethod method;
	
	/**
	 * The index of the class variable in the dependencies object
	 */
	private int labelIndex;
	
	/**
	 * Create a FeatureSelectionOperation that was passed the given args on the command line
	 * @param args the command line arguments given to this operation
	 */
	public FeatureSelectionOperation(String[] args) {
		if(args.length < 2){
			printUsage("Error: the feature selection operation was not passed any feature subset search method");
			System.exit(-1); return;
		}
		
		try{
			labelIndex = Integer.parseInt(args[0]);
		}catch (NumberFormatException e){
			printUsage("ERROR: The first argument to -features must be an integer labelIndex");
			System.exit(-1); return;
		}

		
		if("-bestFirst".equals(args[1])){
			method = new BestFirstFeatureSearch(Arrays.copyOfRange(args, 2, args.length));
		}else if("-beam".equals(args[1])){
			method = new BeamFeatureSearch(Arrays.copyOfRange(args, 2, args.length));			
		}else{
			printUsage("Error: \""+args[1]+"\" is an unknown feature selection search method. Valid methods are -beam and -bestFirst");
			System.exit(-1); return;
		}
	}

	/* (non-Javadoc)
	 * @see java.lang.Runnable#run()
	 */
	@Override
	public void run() {
		Dependences deps;
		try{
			ObjectInputStream depsIn = stdinAsObjectInputStream();
			deps = (Dependences) depsIn.readObject();
		}catch(IOException e){
			System.err.println("Error reading dependencies from standard input stream");
			System.exit(-1); return;
		}catch(Exception e){
			System.err.println("Error deserializing dependencies from standard input stream:"+e.getMessage());
			e.printStackTrace(System.err);
			System.exit(-1); return;			
		}
	
		//Do the feature selection
		FeatureSet bestSet;
		try{
			bestSet = method.bestFeatures(deps, labelIndex);
		}catch (OutOfMemoryError e){
			System.err.println("Error: ran out of memory searching for best set of features");
			System.exit(-1); return;
		}
		
		int[] best = bestSet.features();
		int[] originalIndices = FeatureSelectionSearchMethod.originalIndices(deps, labelIndex);
		for(int i = 0; i < best.length; ++i){
			int featureNumber = best[i];
			System.out.println(originalIndices[featureNumber]);
		}
		
	}

}
