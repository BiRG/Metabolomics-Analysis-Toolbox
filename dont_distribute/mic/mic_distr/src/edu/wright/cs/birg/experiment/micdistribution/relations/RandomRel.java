/**
 * 
 */
package edu.wright.cs.birg.experiment.micdistribution.relations;

import java.util.Random;

import org.sureassert.uc.annotation.Exemplar;
import org.sureassert.uc.annotation.Exemplars;

import edu.wright.cs.birg.experiment.micdistribution.Instance;

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

	@Exemplars(set={
	@Exemplar(args={"null","1"}, ee="NullPointerException"),
	@Exemplar(args={"new java/util/Random(1l)","0"}, expect="=(retval.getNumSamples(),0)"),
	@Exemplar(args={"new java/util/Random(1l)","2"}, expect={
	"java/util/Arrays.equals(retval.x,[pa:0.7308782f, 0.4100808f])",
	"java/util/Arrays.equals(retval.y,[pa:0.100473166f, 0.40743977f])"}),
	@Exemplar(args={"new java/util/Random(1l)","4"}, expect={
	"java/util/Arrays.equals(retval.x,[pa:0.7308782f, 0.4100808f, 0.2077148f, 0.332717f])",
	"java/util/Arrays.equals(retval.y,[pa:0.100473166f, 0.40743977f, 0.036235332f, 0.6588672f])"})
	})
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
