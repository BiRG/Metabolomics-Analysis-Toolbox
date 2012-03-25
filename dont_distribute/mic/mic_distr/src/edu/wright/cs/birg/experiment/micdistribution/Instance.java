/**
 * 
 */
package edu.wright.cs.birg.experiment.micdistribution;

import org.sureassert.uc.annotation.Exemplar;
import org.sureassert.uc.annotation.Exemplars;

/**
 * An instance of a bivariate dataset which can be assigned a dependence score.
 * Envisioned to result from sampling a Relation object.
 * 
 * @author Eric Moyer
 * 
 */
public class Instance {
	/**
	 * x[i] is the x value of the i'th sample in this Instance
	 */
	public final float[] x;
	/**
	 * y[i] is the y value of the i'th sample in this Instance
	 */
	public final float[] y; 
	
	/**
	 * Create an instance where the i'th sample has x[i] as its x value and y[i]
	 * as its y value.
	 * 
	 * @param x
	 *            x[i] is the x value of the i'th sample in this Instance.
	 *            Cannot be null. Must be the same length as y.
	 * @param y
	 *            y[i] is the y value of the i'th sample in this Instance.
	 *            Cannot be null. Must be the same length as x.
	 */
	@Exemplars(set={
	@Exemplar(args={"null","null"}, ee="IllegalArgumentException"),
	@Exemplar(args={"pa:[0.0f]","null"}, ee="IllegalArgumentException"),
	@Exemplar(args={"pa:[0.0f]","pa:[0.0f,1.1f]"}, ee="IllegalArgumentException"), 
	@Exemplar(name="i0_0",
		args={"pa:[0.0f]","pa:[0.0f]"},e={
			"java/util/Arrays.equals(retval.x,pa:0f)",
			"java/util/Arrays.equals(retval.y,pa:0f)"}
	), 
	@Exemplar(name="i01_10",
		args={"pa:[0.0f,1f]","pa:[1f,0.0f]"},e={
			"java/util/Arrays.equals(retval.x,[pa:0f,1f])",
			"java/util/Arrays.equals(retval.y,[pa:1f,0f])"}
	), 
	@Exemplar(name="i012_120",
		args={"pa:[0f,1f,2f]","pa:[1f,2f,0f]"},e={
		"java/util/Arrays.equals(retval.x,[pa:0f,1f,2f])",
		"java/util/Arrays.equals(retval.y,[pa:1f,2f,0f])"}
	), 
	})
	Instance(float[] x, float[] y){
		java.util.Arrays.equals(x, y);
		if (x == null) {
			throw new IllegalArgumentException(
					"The x parameter in creating an instance cannot be null.");
		}
		if (y == null) {
			throw new IllegalArgumentException(
					"The y parameter in creating an instance cannot be null.");
		}
		if (x.length != y.length) {
			throw new IllegalArgumentException(
					"The arrays passed to the Instance(float[],float[]) "+
					"constructor must be the same length");
		}
		this.x = x;
		this.y = y;
	}

	/**
	 * Create an instance for numSamples samples with uninitialized values 
	 * @param numSamples the number of samples in the resulting instance
	 */
	public Instance(int numSamples) {
		this(new float[numSamples], new float[numSamples]);
	}

	/**
	 * Return the number of samples in this instance. The x and y arrays both have getNumSamples() entries.
	 * @return the number of samples in this instance. 
	 */
	public int getNumSamples() {
		return x.length;
	}
}
