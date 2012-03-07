/**
 * 
 */
package edu.wright.cs.birg.feature_selection.correlation;

import java.util.Collections;

/**
 * @author Eric Moyer
 *
 */
public class BeamFeatureSearch extends FeatureSelectionSearchMethod {

	/**
	 * Maximum number of feature sets in the search beam
	 */
	private int maxBeamSize;
	
	/**
	 * Quits if nonImprovementsBeforeQuit beam expansions take place without an improvement in the 
	 * best solution found 
	 */
	private int nonImprovementsBeforeQuit; 

	
	/**
	 * Create a BeamFeatureSearch that was passed the given args on the command line
	 * @param args the command line arguments given to this operation
	 */
	public BeamFeatureSearch(String[] args) {
		super(args);
		if(args.length != 2){
			printUsage("Error: the beam search method requires two parameters");
			System.exit(-1); return;
		}
		
		try{
			nonImprovementsBeforeQuit = Integer.parseInt(args[0]);
			maxBeamSize = Integer.parseInt(args[1]);
		}catch (NumberFormatException e){
			printUsage("Error: both parameters to the beam search method must be integers");
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
