/**
 * 
 */
package edu.wright.cs.birg.experiment.micdistribution.relations;

import java.util.Random;

import edu.wright.cs.birg.experiment.micdistribution.Instance;

/**
 * A unit circle centered around 0.5, 0.5 
 * @author Eric Moyer
 *
 */
public final class CircleRel extends ArcLengthRelation {

	/**
	 * Create a circle relation
	 */
	public CircleRel() {
		super(190, "circle", "Circle", Math.PI);
	}

	/* (non-Javadoc)
	 * @see edu.wright.cs.birg.experiment.micdistribution.relations.Relation#samples(java.util.Random, int)
	 */
	@Override
	public Instance samples(Random rng, int numSamples) {
		Instance i = new Instance(numSamples);
		for (int j = 0; j < numSamples; ++j) {
			double theta = rng.nextDouble()*2*Math.PI; 
			i.x[j] = (float) ((1+Math.cos(theta))/2);
			i.y[j] = (float) ((1+Math.sin(theta))/2);
		}
		return i;
	}

}
