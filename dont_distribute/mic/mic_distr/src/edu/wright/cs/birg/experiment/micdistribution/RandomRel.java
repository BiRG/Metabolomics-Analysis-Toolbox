/**
 * 
 */
package edu.wright.cs.birg.experiment.micdistribution;

import java.util.Random;

/**
 * A uniform random relation between two variables
 * 
 * @author Eric Moyer
 * 
 */
public final class RandomRel extends Relation {

	/* (non-Javadoc)
	 * @see edu.wright.cs.birg.experiment.micdistribution.Relation#sample(java.util.Random)
	 */
	@Override
	public final Sample sample(Random rng) {
		return new Sample(rng.nextFloat(),rng.nextFloat());
	}

	/**
	 * Create a RandomRel object. There is only one random relation I am
	 * interested in, the uniform one, so this takes no arguments.
	 */
	public RandomRel(){
		super(0, "random", "Uniform Random Relation");
	}
}
