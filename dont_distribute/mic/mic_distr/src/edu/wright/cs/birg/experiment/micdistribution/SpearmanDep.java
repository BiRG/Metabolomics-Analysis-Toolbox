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
	 * Returns an array a such that a[i] is the rank of the value in[i] among
	 * in's values. More specifically, sort in, and assign each element its
	 * 1-based index 1..N as a provisional rank. Next find groups of equal
	 * elements and assign them all the mean of their provisional rank. Finally,
	 * find those values in the original array and replace them with their
	 * ranks.
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
		
		{
			int i = 0;
			while(i < sorted.length){
				float val = sorted[i];
				if(Float.isNaN(sorted[i])){
					throw new IllegalArgumentException("The input to asRanks cannot contain any NaN values"); 
				}
				
				Float newRank;
				if(i + 1 >= sorted.length || val != sorted[i+1]){ //Not a tie
					newRank = new Float(i+1);
				}else{ //This is a tie with the next one, 
					//Advance i until we are at the last item that is a tie with val.
					
					++i; //Go to the next item in the array
					int runLength = 2; //The number of elements (at indices less than or equal to i) with a value val 
					int runSum = (i-1+1)+(i+1); //The sum of the ranks of the elements in the run
					while(i+1 < sorted.length && val == sorted[i+1]){ //While the current item is in a tie with the next one 
						++i; //Advance to the next item
						++runLength; //Increase the length of the run
						runSum += i+1; //Add the rank of the new (now current) item to the sum
					}
					// Here i is the last element in the run, so the runLength and
					// runSum include the whole run of identical elements. We can now
					// calculate the average rank and set that as the new rank.
					newRank = new Float(((float)runSum)/runLength); 
				}
				
				Float f = new Float(val);
				assert(!rank.containsKey(f));
				rank.put(f, newRank);
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
