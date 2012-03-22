/**
 * 
 */
package edu.wright.cs.birg.experiment.micdistribution;

import java.util.Random;

/**
 * A relation consisting of a finite set of points. Generic version of the categorical relation 
 * from Reshef's paper (table S2)
 * @author Eric Moyer
 *
 */
public final class CategoricalRel extends Relation {
	/**
	 * x[i] is the x value of the i'th point in this relation
	 */
	private final float[] x;
	
	/**
	 * y[i] is the y value of the i'th point in this relation
	 */
	private final float[] y;
	
	/* (non-Javadoc)
	 * @see edu.wright.cs.birg.experiment.micdistribution.Relation#samples(java.util.Random, int)
	 */
	@Override
	public Instance samples(Random rng, int numSamples) {
		Instance out = new Instance(numSamples);
		for(int i = 0; i < numSamples; ++i){
			int point = rng.nextInt(x.length);
			out.x[i] = x[point];
			out.y[i] = y[point];
		}
		return out;
	}

	/**
	 * Create a Categorical relation in which the coordinates of the i-th point
	 * in the relation are (x[i],y[i]).
	 * 
	 * @param id
	 *            the id of this Relation. Same as the corresponding parameter
	 *            in the Relation constructor.
	 * @param shortName
	 *            the short name of this Relation. Same as the corresponding
	 *            parameter in the Relation constructor.
	 * @param fullName
	 *            the full name of this relation. Same as the corresponding
	 *            parameter in the Relation constructor.
	 * @param x
	 *            x[i] is the x value of the i'th point in this relation. Cannot
	 *            be null. Must be the same length as y.
	 * @param y
	 *            y[i] is the y value of the i'th point in this relation. Cannot
	 *            be null. Must be the same length as x.
	 */
	CategoricalRel(int id, String shortName, String fullName, float[] x, float[] y){
		super(id, shortName, fullName);
		
		if (x == null) {
			throw new IllegalArgumentException(
					"The x parameter in creating a categorical relation cannot be null.");
		}
		if (y == null) {
			throw new IllegalArgumentException(
					"The y parameter in creating a categorical relation cannot be null.");
		}
		if (x.length != y.length) {
			throw new IllegalArgumentException(
					"The arrays passed to the CategoricalRel(...,float[],float[]) "+
					"constructor must be the same length");
		}

		this.x = x; this.y = y;
	}
}
