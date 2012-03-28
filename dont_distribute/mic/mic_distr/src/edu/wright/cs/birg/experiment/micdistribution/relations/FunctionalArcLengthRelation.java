/**
 * 
 */
package edu.wright.cs.birg.experiment.micdistribution.relations;

import java.util.Random;

import edu.wright.cs.birg.experiment.micdistribution.Instance;

/**
 * A relation with an arc-length that calculates its samples by uniformly
 * sampling the x axis and then using a function named <code>val</code> for the
 * y axis.
 * 
 * @author Eric Moyer
 * 
 */
public abstract class FunctionalArcLengthRelation extends ArcLengthRelation {

	/**
	 * Just calls
	 * {@link ArcLengthRelation#ArcLengthRelation(int, String, String, double)}
	 * 
	 * @param id
	 *            A non-negative integer
	 * @param shortName
	 *            The short name of this relation (consists only of letters,
	 *            numbers and _)
	 * @param fullName
	 *            The full name of this relation (cannot contain tabs)
	 * @param arcLength
	 *            The arc length of this relation within the unit square
	 *            [0,1]x[0,1].
	 */
	public FunctionalArcLengthRelation(int id, String shortName,
			String fullName, double arcLength) {
		super(id, shortName, fullName, arcLength);
	}

	/**
	 * The function that calculates the y value of this relation given an x
	 * value.
	 * 
	 * @param x The x value whose y-value should be returned
	 */
	protected abstract float val(float x);
	
	@Override
	public Instance samples(Random rng, int numSamples) {
		Instance i = new Instance(numSamples);
		for(int j = 0; j < numSamples; ++j){
			i.x[j]=rng.nextFloat();
			i.y[j]=val(i.x[j]);
		}
		return i;
	}

}
