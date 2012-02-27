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
	@Exemplar(expect="isa(retval,MIC)")
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
	 * A test version of ApproxMINECharacteristicMatrix that works by calling the code in the MINE.jar file
	 * NOTE: some of the rows of the matrix will be null and some of the columns will
	 * either not exist or have bad values
	 * 
	 * @param x x[i] is the x coordinate of the ith point
	 * @param y y[i] is the y coordinate of the ith point
	 * @param maxBins The maximum number of bins to use in the bivariate binning must be 1 or more
	 * @param maxClumpColumnRatio The maximum numberOfClumps/x_bins to use when calling optimizeXAxis. must be greater than 0
	 * @return heuristic approximations to the entries of the MINE characteristic matrix 
	 */
	@Exemplars(set={
	@Exemplar(args={"[pa:1.0,2.0,3.0,4.0]","[pa:1.0,2.0,3.0,4.0]","4","45.0"}, expect=""),
	@Exemplar(args={"[pa:1.0]","[pa:1.0]","4","45.0"}, expect=""),
	@Exemplar(a={"[pa:1.0,2.0,3.0,4.0,5.0,6.0,7.0,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0,16.0]","[pa:1.0,2.0,3.0,4.0,5.0,6.0,7.0,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0,16.0]","8","15.0"},e={"#=(retval,[a:null,null,[pa:0.0,0.0,1.0,1.0,1.0],[pa:0.0,0.0,1.0],[pa:0.0,0.0,1.0]])"}),
	})	
	public static double[][] testApproxMatrix(double[] x, double[] y, int maxBins, double maxClumpColumnRatio){
		//Convert my parameters to Reshef's input format
		float[] xf = new float[x.length];
		float[] yf = new float[y.length];
		for(int i = 0; i < x.length;++i){
			xf[i]=(float)x[i];
			yf[i]=(float)y[i];
		}
		data.VarPairData d = new data.VarPairData(xf,yf);
		float exponent = (float)(Math.log((double)maxBins)/Math.log((double)x.length));
		
		//Call Reshef's code to do the calculation
		mine.core.MineParameters mp = new mine.core.MineParameters(
				exponent, (float)maxClumpColumnRatio, 0, null);
		mine.core.Manifold man = new mine.core.Manifold(d, mp);
		
		//Convert the output scores to a double array and return it
		double[][] out;
		
		assert(man.scores != null);
		out = new double[man.scores.length][];
		
		for(int i = 0; i < out.length; ++i){
			if(man.scores[i] == null){
				out[i] = null;
			}else{
				out[i] = new double[man.scores[i].length];
				for(int j = 0; j < out[i].length; ++j){
					out[i][j] = man.scores[i][j];
				}
			}
		}
		
		return out;
	}
	
	
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
