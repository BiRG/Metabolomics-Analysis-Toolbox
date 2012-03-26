/**
 * 
 */
package edu.wright.cs.birg.experiment.micdistribution;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

import org.sureassert.uc.annotation.Exemplar;
import org.sureassert.uc.annotation.Exemplars;

/**
 * Absolute value of the Spearman rank-correlation coefficient
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
		return "Absolute value of Spearman rank correlation";
	}

	/* (non-Javadoc)
	 * @see edu.wright.cs.birg.experiment.micdistribution.DependenceMeasure#dependence(edu.wright.cs.birg.experiment.micdistribution.Instance)
	 */
	@Override
	@Exemplars(set={
	@Exemplar(args={"null"}, ee="NullPointerException"),
	@Exemplar(args={"Instance/i0_0"}, ee="IllegalArgumentException"), 
	@Exemplar(args={"Instance/i01_10"}, e="1f"),
	@Exemplar(args={"Instance/i012_120"}, e="0.5f"),
	@Exemplar(args={"Instance/i0123_1032"}, e="0.6f"),
	@Exemplar(args={"Instance/i01234_34330"}, e="0.670820393f"),
	})
	public float dependence(Instance inst) {
		Instance rankInst = new Instance(asRanks(inst.x), asRanks(inst.y));
		return Math.abs(PearsonDep.valueOf(rankInst));
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
	@Exemplars(set={
	@Exemplar(args={"[pa:0f]"}, expect="java/util/Arrays.equals(retval,pa:1f)"),
	@Exemplar(args={"[pa:1f]"}, expect="java/util/Arrays.equals(retval,pa:1f)"),
	@Exemplar(args={"[pa:2.5f,2.5f]"}, expect="java/util/Arrays.equals(retval,[pa:1.5f,1.5f])"),
	@Exemplar(args={"[pa:1.0f,2.5f]"}, expect="java/util/Arrays.equals(retval,[pa:1.0f,2.0f])"),
	@Exemplar(args={"[pa:1f,-2.5f]"}, expect="java/util/Arrays.equals(retval,[pa:2f,1f])"),
	@Exemplar(args={"[pa:1f,-2.5f,56.21f]"}, expect="java/util/Arrays.equals(retval,[pa:2f,1f,3f])"),
	@Exemplar(args={"[pa:-1f,2.5f,-56.21f]"}, expect="java/util/Arrays.equals(retval,[pa:2f,3f,1f])"),
	@Exemplar(args={"[pa:-1f,2.5f,-1f]"}, expect="java/util/Arrays.equals(retval,[pa:1.5f,3f,1.5f])"),
	@Exemplar(args={"[pa:-1f,2.5f,2.5f]"}, expect="java/util/Arrays.equals(retval,[pa:1f,2.5f,2.5f])"),
	@Exemplar(args={"[pa:-1f,-1f,-1f]"}, expect="java/util/Arrays.equals(retval,[pa:2f,2f,2f])"),
	@Exemplar(args={"edu/wright/cs/birg/test/ArrayUtils.emptyFloat()"}, expect="java/util/Arrays.equals(retval,edu/wright/cs/birg/test/ArrayUtils.emptyFloat())"),
	@Exemplar(args={"pa:java/lang/Float.NaN"}, expectexception="java/lang/IllegalArgumentException"),
	@Exemplar(args={"pa:1f,java/lang/Float.NaN"}, 
		expectexception="java/lang/IllegalArgumentException"
		), //Note 9221120237041090560l is NaN, I'm working around a bug in SureAssert
	@Exemplar(args={"null"}, expectexception="java/lang/IllegalArgumentException"),
	})	
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
				++i;
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
