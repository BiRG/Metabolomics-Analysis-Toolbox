/**
 * 
 */
package edu.wright.cs.birg.experiment.micdistribution;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

/**
 * @author Eric Moyer
 *
 */
public class SpearmanDep implements DependenceMeasure {

	/* (non-Javadoc)
	 * @see edu.wright.cs.birg.experiment.micdistribution.DependenceMeasure#getID()
	 */
	@Override
	public int getID() {
		return 2;
	}

	/* (non-Javadoc)
	 * @see edu.wright.cs.birg.experiment.micdistribution.DependenceMeasure#getName()
	 */
	@Override
	public String getName() {
		return "Spearman rank correlation";
	}

	/* (non-Javadoc)
	 * @see edu.wright.cs.birg.experiment.micdistribution.DependenceMeasure#dependence(edu.wright.cs.birg.experiment.micdistribution.Instance)
	 */
	@Override
	public float dependence(Instance inst) {
		Instance rankInst = new Instance(asRanks(inst.x), asRanks(inst.y));
		return PearsonDep.valueOf(rankInst);
	}

	/**
	 * Returns a such that a[i] == k if in[i] is the k'th largest value in in.
	 * The smallest value of in will get the value 0, the second smallest, the
	 * value 1, etc.
	 * 
	 * @param in
	 *            an array of floats (none can be NaN), in cannot be null
	 * @return a such that a[i] = k if in[i] is the k'th largest value in in.
	 */
	private static float[] asRanks(float[] in){
		if(in == null){ throw new IllegalArgumentException("null passed to asRanks(float[]) instead of an array"); }

		float[] out = new float[in.length];
		
		Map<Float,Float> rank = new HashMap<Float,Float>(in.length*5); //Ensure no reallocations and very few collisions
		
		float[] sorted = in.clone();
		Arrays.sort(sorted);
		
		for(int i = 0; i < sorted.length; ++i){ 
			if(Float.isNaN(sorted[i])){
				throw new IllegalArgumentException("The input to asRanks cannot contain any NaN values"); }
			Float f=new Float(sorted[i]);
			if(!rank.containsKey(f)){
				rank.put(f, new Float(rank.size()));
			}
		}
		
		for(int i = 0; i < in.length; ++i){
			Float f = new Float(in[i]);
			assert(rank.containsKey(f));
			out[i] = rank.get(f).floatValue();
		}
		
		return out;
	}

}
