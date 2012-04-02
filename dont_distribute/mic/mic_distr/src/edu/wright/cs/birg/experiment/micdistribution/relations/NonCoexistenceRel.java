/**
 * 
 */
package edu.wright.cs.birg.experiment.micdistribution.relations;

import java.util.Random;

import org.sureassert.uc.annotation.Exemplar;
import org.sureassert.uc.annotation.Exemplars;

import edu.wright.cs.birg.experiment.micdistribution.Instance;
import edu.wright.cs.birg.experiment.micdistribution.relations.ArcLengthRelation;

/**
 * The union of a vertical and horizontal line passing through the origin
 * 
 * @author Eric Moyer
 * 
 */
public final class NonCoexistenceRel extends ArcLengthRelation {

	/**
	 * Create a non-coexistence relation
	 */
	public NonCoexistenceRel() {
		super(162, "lines2", "2 Lines (non-coexistence)", 2);
	}

	@Override
	@Exemplars(set={
	@Exemplar(args={"new java/util/Random(1l)","0"}, expect="=(retval.getNumSamples(), 0)"),
	@Exemplar(a={"new java/util/Random(1l)","2"}, e={
			"java/util/Arrays.equals([pa:0.100473166f,0f], retval.x)",
			"java/util/Arrays.equals([pa:0f,0.40743977f], retval.y)"
	})
	})
	public Instance samples(Random rng, int numSamples) {
		Instance i = new Instance(numSamples);
		for (int j = 0; j < numSamples; ++j) {
			if (rng.nextBoolean()) {
				i.x[j] = rng.nextFloat();
				i.y[j] = 0;
			} else {
				i.y[j] = rng.nextFloat();
				i.x[j] = 0;
			}
		}
		return i;
	}

}
