/**
 * 
 */
package edu.wright.cs.birg.experiment.micdistribution;

import java.util.Arrays;

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
		return "Distance Covariance";
	}

	/* (non-Javadoc)
	 * @see edu.wright.cs.birg.experiment.micdistribution.DependenceMeasure#dependence(edu.wright.cs.birg.experiment.micdistribution.Instance)
	 */
	@Override
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
	private static double[][] capitalLetterMatrix(float[] a){
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
