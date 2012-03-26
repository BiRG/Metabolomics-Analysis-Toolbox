/**
 * 
 */
package edu.wright.cs.birg.experiment.micdistribution;

import java.util.Arrays;

import org.sureassert.uc.annotation.Exemplar;
import org.sureassert.uc.annotation.Exemplars;

/**
 * The sample distance correlation measure of dependence.
 * 
 * The measure is defined in: 
 * 
 * Brownian distance covariance by Gábor J. Székely and Maria L. Rizzo.
 * Published in Annals of Applied Statistics Volume 3, Number 4 (2009),
 * 1236-1265.
 * 
 * The formula for sample distance correlation is at the bottom of page 1242
 * 
 * @author Eric Moyer
 * 
 */
public class DistanceCorrelationDep implements DependenceMeasure {

	/* (non-Javadoc)
	 * @see edu.wright.cs.birg.experiment.micdistribution.DependenceMeasure#getID()
	 */
	@Override
	public int getID() {
		return 1;
	}

	/* (non-Javadoc)
	 * @see edu.wright.cs.birg.experiment.micdistribution.DependenceMeasure#getName()
	 */
	@Override
	public String getName() {
		return "Distance Correlation";
	}

	/* (non-Javadoc)
	 * @see edu.wright.cs.birg.experiment.micdistribution.DependenceMeasure#dependence(edu.wright.cs.birg.experiment.micdistribution.Instance)
	 */
	@Override
	@Exemplars(set={
	@Exemplar(args={"null"}, ee="NullPointerException"),
	@Exemplar(args={"Instance/i0_0"}, expect="0f"), 
	@Exemplar(args={"Instance/i01_10"}, expect="1f"),
	@Exemplar(args={"Instance/i012_120"}, expect="0.7f"),
	@Exemplar(args={"Instance/i0123_1032"}, expect="0.692307692f"),
	@Exemplar(args={"Instance/i01234_34330"}, expect="0.591232712f"),
	})
	public float dependence(Instance inst) {
		double[][] A = capitalLetterMatrix(inst.x);
		double[][] B = capitalLetterMatrix(inst.y);
		double vx = distanceCovariance(A, A);
		if(vx == 0){ return 0f; }
		double vy = distanceCovariance(B, B);
		if(vy == 0){ return 0f; }
		return (float)(distanceCovariance(A,B)/Math.sqrt(vx*vy));
	}

	/**
	 * Given that A and B are the capital letter matrices for two variables (see capitalLetterMatrix for the definition), this returns the distance covariance of the two samples.
	 * @param A the capital letter matrix for one sample. Cannot be null, must be square, and must have at least 1 entry.
	 * @param B the capital letter matrix for the other sample.  Cannot be null and must be the same size as A.
	 * @return the distance covariance for two variables that have capital letter matrices A and B
	 */
	@Exemplars(set={
	@Exemplar(a={"null","null"},ee="NullPointerException"),
	@Exemplar(a={"[a:[pa:12d]]","null"},ee="NullPointerException"),
	@Exemplar(a={"[edu/wright/cs/birg/test/ArrayUtils.emptyDoubleMatrix()]","[edu/wright/cs/birg/test/ArrayUtils.emptyDoubleMatrix()]"},ee="IllegalArgumentException"),
	@Exemplar(a={"[a:[pa:0d],[pa:1d]]","[a:[pa:0d]]"},ee="IllegalArgumentException"),
	@Exemplar(a={"[a:[pa:0d,1d]]","[a:[pa:0d]]"},ee="IllegalArgumentException"),
	@Exemplar(a={"[a:[edu/wright/cs/birg/test/ArrayUtils.nullDouble()],[pa:0d]]","[a:[pa:0d],[pa:0d]]"},ee="NullPointerException"),
	@Exemplar(a={"[pa:[pa:-0.5,0.5],[pa:0.5,-0.5]]","[pa:[pa:-0.5,0.5],[pa:0.5,-0.5]]"},e="0.25"),
	@Exemplar(a={
			"[pa:[pa:-1.1111111111111111, 0.22222222222222222,  0.88888888888888889], " +
			"[pa:0.22222222222222222, -0.44444444444444444,  0.22222222222222222]," +
			"[pa:0.88888888888888889,  0.22222222222222222, -1.1111111111111111]]",
			"[pa:[pa:-0.44444444444444444,0.22222222222222222,  0.22222222222222222]," +
			"[pa:0.22222222222222222, -1.1111111111111111,   0.88888888888888889]," +
			"[pa:0.22222222222222222,0.88888888888888889,-1.1111111111111111]]"
			},e="0.34567901234567901"),
	})
	private static double distanceCovariance(double[][] A, double[][] B){
		if(A == null || B==null){
			throw new NullPointerException("The matrix arguments to distanceCovariance cannot be null");
		}
		int n = A.length;
		if(n < 1){
			throw new IllegalArgumentException("The matrix arguments to distanceCovariance must have at least one element");
		}
		if(A.length != B.length){
			throw new IllegalArgumentException("The matrix arguments to distanceCovariance must be the same size");
		}
		if(A[0]==null || B[0]==null){
			throw new NullPointerException("None of the rows in the matrix arguments passed to distanceCovariance can be null");
		}
		if(A[0].length != n || B[0].length != n){
			throw new IllegalArgumentException("The matrix arguments to distanceCovariance must be square");
		}
		
		double sum = 0;
		for(int i = 0; i < n; ++i){
			for(int j = 0; j < n ; ++j){
				sum += A[i][j]*B[i][j];
			}
		}
		
		return sum/(n*n);
	}
	
	/**
	 * Return the A matrix (as defined in SZÉKELY AND RIZZO p. 1242) given a
	 * list of points a. If n = a.length A is an n by n matrix.
	 * 
	 * Let b[k][l] = abs(a[k]-a[l]).
	 * 
	 * Let rowMean[k] = sum(b[k][l],l=0..n-1)/n
	 * 
	 * Let colMean[l] = sum(b[k][l],k=0..n-1)/n
	 * 
	 * Let mean = sum(b[k][l],k=0..n-1,l=0..n-1)/(n*n)
	 * 
	 * A[k][l] = b[k][l]-rowMean[k]-colMean[l]+mean
	 * 
	 * @param a
	 *            The input list of values from which the matrix will be formed.
	 *            a must not be null and have at least one element
	 * 
	 * @return Return the A matrix (as defined in SZÉKELY AND RIZZO p. 1242)
	 *         given a list of points a.
	 */
	@Exemplars(set={
			@Exemplar(a="null",ee="NullPointerException"),	
			@Exemplar(a="edu/wright/cs/birg/test/ArrayUtils.emptyFloat()",ee="IllegalArgumentException"),
			@Exemplar(a="pa:7f",e="#=(retval,[a:[pa:0d]])"),
			@Exemplar(a="pa:0f,1f",e="#=(retval,[a:[pa:-0.5d,0.5d],[pa:0.5d,-0.5d]])"),
			@Exemplar(a="pa:0f,1f,2f",
					e="#=(retval,[a:" +
					"[pa:-1.1111111111111111d, 0.22222222222222222d, 0.88888888888888889]," +
					"[pa:0.22222222222222222d,-0.44444444444444444d, 0.22222222222222222]," +
					"[pa:0.88888888888888889d, 0.22222222222222222d, -1.1111111111111111]])"),
			@Exemplar(a="pa:0f,1f,2f,3f",e="#=(retval,[a:" +
					"[pa:-1.75,-0.25, 0.75, 1.25]," +
					"[pa:-0.25,-0.75, 0.25, 0.75]," +
					"[pa: 0.75, 0.25,-0.75,-0.25]," +
					"[pa: 1.25, 0.75,-0.25,-1.75]])"),
			@Exemplar(a="pa:0f,1f,2f,3f,4f",e="#=(retval,[a:" +
					"[pa:-2.40,               -0.7999999999999998,     0.40000000000000013,    1.2000000000000002,    1.60]," +
					"[pa:-0.7999999999999998, -1.1999999999999997,     2.220446049250313E-16,  0.8000000000000003d,    1.2000000000000002]," +
					"[pa: 0.40000000000000013, 2.220446049250313E-16d,-0.7999999999999998,     2.220446049250313E-16d,0.40000000000000013]," +
					"[pa: 1.2000000000000002,  0.8000000000000003d,     2.220446049250313E-16d,-1.1999999999999997,   -0.7999999999999998]," +
					"[pa: 1.60,                1.2000000000000002,     0.40000000000000013,   -0.7999999999999998,   -2.40]])"),
			@Exemplar(a="pa:1f,0f",e="#=(retval,[a:[pa:-0.5d,0.5d],[pa:0.5d,-0.5d]])"),
			@Exemplar(a="pa:1f,2f,0f",e="#=(retval,[a:" +
					"[pa:-0.44444444444444444d, 0.22222222222222222d, 0.22222222222222222]," +
					"[pa: 0.22222222222222222d,-1.1111111111111111d,  0.88888888888888889]," +
					"[pa: 0.22222222222222222d, 0.88888888888888889d,-1.1111111111111111]])"),
	})
	public static double[][] capitalLetterMatrix(float[] a){
		if(a == null){
			throw new NullPointerException("The input to capitalLetterMatrix must have at least 1 element");
		}
		int n = a.length;
		if(n < 1){
			throw new IllegalArgumentException("The input to capitalLetterMatrix must have at least 1 element");
		}
		//Allocate the temporary variables
		double[][] b = new double[n][n];
		double[] rowMean = new double[n];
		double[] colMean = new double[n];
		double mean = 0;
		
		//Initialize the means to 0 and b to its final values
		Arrays.fill(rowMean, 0);
		Arrays.fill(colMean, 0);		
		for(int i = 0; i < n; ++i){
			for(int j = 0; j < n ; ++j){
				b[i][j]=Math.abs(a[i]-a[j]);
			}
		}
		
		//Calculate the sums
		for(int i = 0; i < n; ++i){
			for(int j = 0; j < n ; ++j){
				rowMean[i]+=b[i][j];
				colMean[j]+=b[i][j];
				mean += b[i][j];
			}
		}
		
		//Normalize sums to make means
		for(int i = 0; i < n; ++i){
			rowMean[i] /= n;
			colMean[i] /= n;
		}
		mean /= n; mean /= n;
		
		//Allocate and calculate A matrix
		double[][] A = new double[n][n];
		for(int i = 0; i < n; ++i){
			for(int j = 0; j < n ; ++j){
				A[i][j]=b[i][j]-rowMean[i]-colMean[j]+mean;
			}
		}
		
		return A;
	}
}
