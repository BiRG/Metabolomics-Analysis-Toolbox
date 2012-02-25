/**
 * 
 */
package edu.wright.cs.birg.mic;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

import org.sureassert.uc.annotation.Exemplar;
import org.sureassert.uc.annotation.Exemplars;

/**
 * Static class containing methods for calculating MIC (Maximal Information Coefficient) score
 * @author Eric Moyer
 *
 */
public final class MIC {
	/**
	 * Private 0-argument constructor to keep unsuspecting people from implementing
	 */
	@Exemplar(expect="")
	private MIC(){}
	
	/**
	 * Return a zero-length array of doubles.
	 * 
	 * No need to warn about it being unused - it is for test code
	 * @return a zero-length array of doubles
	 */
	@SuppressWarnings("unused")
	@Exemplar(expect="")
	private static double[] emptyDoubleArray(){ return new double[0]; }

	/**
	 * Return a zero-length array of ints
	 * 
	 * No need to warn about it being unused - it is for test code
	 * @return a zero-length array of ints
	 */
	@SuppressWarnings("unused")
	@Exemplar(expect="")
	private static int[] emptyIntArray(){ return new int[0]; }
	
	/**
	 * Returns a such that a[i] = k if in[i] is the k'th largest value in in. The smallest value of in will get the
	 * value 0, the second smallest, the value 1, etc.
	 * @param in an array of doubles (none can be NaN), in cannot be null
	 * @return a such that a[i] = k if in[i] is the k'th largest value in in.
	 */
	@Exemplars(set={
	@Exemplar(args={"pa:d:0.0"}, expect="java/util/Arrays.equals(retval,pa:0)"),
	@Exemplar(args={"pa:d:1.0"}, expect="java/util/Arrays.equals(retval,pa:0)"),
	@Exemplar(args={"pa:[d:1.0],[d:2.5]"}, expect="java/util/Arrays.equals(retval,[pa:0,1])"),
	@Exemplar(args={"pa:[d:1.0],[d:-2.5]"}, expect="java/util/Arrays.equals(retval,[pa:1,0])"),
	@Exemplar(args={"pa:[d:1.0],[d:-2.5],[d:56.21]"}, expect="java/util/Arrays.equals(retval,[pa:1,0,2])"),
	@Exemplar(args={"pa:[d:-1.0],[d:2.5],[d:-56.21]"}, expect="java/util/Arrays.equals(retval,[pa:1,2,0])"),
	@Exemplar(args={"emptyDoubleArray()"}, expect="java/util/Arrays.equals(retval,emptyIntArray())"),
	@Exemplar(args={"pa:java/lang/Double.NaN"}, expectexception="java/lang/IllegalArgumentException"),
	@Exemplar(args={"pa:Double.longBitsToDouble(1l),java/lang/Double.longBitsToDouble(9221120237041090560l)"}, 
		expectexception="java/lang/IllegalArgumentException"
		), //Note 9221120237041090560l is NaN, I'm working around a bug in SureAssert
	@Exemplar(args={"null"}, expectexception="java/lang/IllegalArgumentException")
	})
	private int[] asRanks(double[] in){
		if(in == null){ throw new IllegalArgumentException("null passed to asRanks(double[]) instead of an array"); }

		int[] out = new int[in.length];
		
		Map<Double,Integer> rank = new HashMap<Double,Integer>(in.length*5); //Ensure no reallocations and very few collisions
		
		double[] sorted = in.clone();
		Arrays.sort(sorted);
		
		for(int i = 0; i < sorted.length; ++i){ 
			if(Double.isNaN(sorted[i])){
				throw new IllegalArgumentException("The input to asRanks cannot contain any NaN values"); }
			Double d=new Double(sorted[i]);
			if(!rank.containsKey(d)){
				rank.put(d, rank.size());
			}
		}
		
		for(int i = 0; i < in.length; ++i){
			Double d = new Double(in[i]);
			assert(rank.containsKey(d));
			out[i] = rank.get(d).intValue();
		}
		
		return out;
	}
	
	/**
	 * Return an approximation to the MINE characteristic matrix for the input points M as defined in 
	 * "Detecting novel associations in large data sets" by Reshef et. al. published in Science, Dec 2011
	 *  
	 * @param x x[i] is the x coordinate of the ith point
	 * @param y y[i] is the y coordinate of the ith point
	 * @param maxBins The maximum number of bins to use in the bivariate binning must be 1 or more
	 * @param maxClumpColumnRatio The maximum numberOfClumps/x_bins to use when calling optimizeXAxis. must be greater than 0
	 * @return heuristic approximations to the entries of the MINE characteristic matrix 
	 */
	public double[][] ApproxMINECharacteristicMatrix(double[] x, double[] y, int maxBins, double maxClumpColumnRatio){
		return ApproxMINECharacteristicMatrix(asRanks(x), asRanks(y), maxBins, maxClumpColumnRatio);
	}

	/**
	 * Return an approximation to the MINE characteristic matrix for the input points M as defined in 
	 * "Detecting novel associations in large data sets" by Reshef et. al. published in Science, Dec 2011
	 *  
	 * @param x x[i] is the x coordinate of the ith point
	 * @param y y[i] is the y coordinate of the ith point
	 * @param maxBins The maximum number of bins to use in the bivariate binning must be 1 or more
	 * @param maxClumpColumnRatio The maximum numberOfClumps/x_bins to use when calling optimizeXAxis. must be greater than 0
	 * @return heuristic approximations to the entries of the MINE characteristic matrix 
	 */
	public double[][] ApproxMINECharacteristicMatrix(int[] x, int[] y, int maxBins, double maxClumpColumnRatio){
		return null; //TODO: remove
	}

}
