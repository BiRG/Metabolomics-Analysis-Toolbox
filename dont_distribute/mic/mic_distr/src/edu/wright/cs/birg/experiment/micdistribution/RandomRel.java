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


	/**
	 * Create a RandomRel object. There is only one random relation I am
	 * interested in, the uniform one, so this takes no arguments.
	 */
	public RandomRel(){
		super(0, "random", "Uniform Random Relation");
	}

	@Override
	public Instance samples(Random rng, int numSamples) {
		Instance i = new Instance(numSamples);
		for(int j = 0; j < numSamples; ++j){
			i.x[j]=rng.nextFloat();
			i.y[j]=rng.nextFloat();
		}
		return i;
	}
}
