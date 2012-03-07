/**
 * 
 */
package edu.wright.cs.birg.feature_selection.correlation;

import java.util.Arrays;
import java.util.PriorityQueue;

/**
 * @author Eric Moyer
 *
 */
public class BestFirstFeatureSearch extends FeatureSelectionSearchMethod {
	/**
	 * Quits if nonImprovementsBeforeQuit node expansions take place without an improvement in the 
	 * best solution found 
	 */
	private int nonImprovementsBeforeQuit;

	/**
	 * Create a BestFirstFeatureSearch that was passed the given args on the command line
	 * @param args the command line arguments given to this operation
	 */
	public BestFirstFeatureSearch(String[] args) {
		super(args);
		if(args.length != 1){
			printUsage("Error: the best first search method requires one parameter");
			System.exit(-1); return;
		}
		
		try{
			nonImprovementsBeforeQuit = Integer.parseInt(args[0]);
		}catch (NumberFormatException e){
			printUsage("Error: the numFailures parameter to the best-first search method must be an integer");
			System.exit(-1); return;			
		}
	}

	/* (non-Javadoc)
	 * @see edu.wright.cs.birg.feature_selection.correlation.FeatureSelectionSearchMethod#bestFeatures(edu.wright.cs.birg.feature_selection.correlation.Dependences, int)
	 */
	@Override
	public FeatureSet bestFeatures(Dependences deps, int labelIndex)
			throws OutOfMemoryError {
		int numFeatures = deps.getNumFeatures()-1;
		double[] classDep = new double[numFeatures];
		double[][] featureDep = new double[numFeatures][numFeatures];
		depsToArrays(deps, labelIndex, classDep, featureDep);
		
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
