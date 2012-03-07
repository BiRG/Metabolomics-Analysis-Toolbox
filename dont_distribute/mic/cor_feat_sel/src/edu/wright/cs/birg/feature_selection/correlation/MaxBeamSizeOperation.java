/**
 * 
 */
package edu.wright.cs.birg.feature_selection.correlation;

import java.util.Comparator;

/**
 * @author Eric Moyer
 *
 */
public class MaxBeamSizeOperation extends Operation {

	/**
	 * Create a MaxBeamSizeOperation that was passed the given args on the command line
	 * @param args the command line arguments given to this operation
	 */
	public MaxBeamSizeOperation(String[] args) {
		if(args.length > 0){
			printUsage("Error: the maxBeamSize operation takes no arguments");
			System.exit(-1); return;
		}
		
	}

	/**
	 * A simple comparator for FeatureSet objects that just compares their hash
	 * values (since I don't care about their ordering for determining maximum
	 * beam size)
	 * 
	 * @author Eric Moyer
	 * 
	 */
	private static final class HashComparator implements Comparator<FeatureSet>{
		@Override
		public int compare(FeatureSet o1, FeatureSet o2) {
			return o1.hashCode()-o2.hashCode();
		}
	}
	/* (non-Javadoc)
	 * @see java.lang.Runnable#run()
	 */
	@Override
	public void run() {
		Dependences deps = dependencesFromStdin();
		int numFeatures = deps.getNumFeatures() - 1;
		int numEntries = 0;
		try{
			SearchBeam<FeatureSet> beam = new SearchBeam<FeatureSet>(Integer.MAX_VALUE, new HashComparator());
			while(true){ beam.add(new FeatureSet(numFeatures)); ++numEntries; }
		}catch (OutOfMemoryError e){	
		}
		System.out.println(numEntries);
	}

}
