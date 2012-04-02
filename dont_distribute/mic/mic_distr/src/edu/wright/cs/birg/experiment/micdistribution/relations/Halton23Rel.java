/**
 * 
 */
package edu.wright.cs.birg.experiment.micdistribution.relations;

import java.util.Random;

import org.sureassert.uc.annotation.Exemplar;
import org.sureassert.uc.annotation.Exemplars;

import edu.wright.cs.birg.experiment.micdistribution.Instance;

/**
 * This relation contains the elements of the 2,3-Halton sequence. Samples
 * return an x that is from the 2-Halton sequence and a y that is the
 * corresponding member of the 3-Halton sequence
 * 
 * @author Eric Moyer
 * 
 */
public final class Halton23Rel extends Relation {

	/**
	 * Create a 2,3-Halton relation
	 */
	public Halton23Rel() {
		super(10002, "23halton", "2,3-Halton");
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * edu.wright.cs.birg.experiment.micdistribution.relations.Relation#samples
	 * (java.util.Random, int)
	 */
	@Override
	public Instance samples(Random rng, int numSamples) {
		Instance i = new Instance(numSamples);
		for (int j = 0; j < numSamples; ++j) {
			do{
				long l;
				do {
					l = rng.nextLong() >> (64 - 53); // Keep upper 53 bits,
				} while (l == 0); // ensure that not 0
				i.x[j] = haltonNumber(l, 2);
				i.y[j] = haltonNumber(l, 3);
			}while(i.x[j]==0 || i.y[j]==0); //Ensure that no underflow in halton number
		}
		return i;
	}

	/**
	 * Return the <code>index</code>'th Halton number in the base
	 * <code>base</base> sequence.
	 * 
	 * Note that inputs are not checked in the interest of speed.
	 * 
	 * This code is almost identical to the code in the Wikipedia article: http://en.wikipedia.org/wiki/Halton_sequences
	 * 
	 * @param index
	 *            The index of the entry in the halton sequence to return. The
	 *            first entry is 1. Must be 1 or more.
	 * @param base
	 *            The prime to use as a base of the halton number sequence. Must
	 *            be a prime.
	 * @return the <code>index</code>'th Halton number in the base
	 *         <code>base</base> sequence.
	 */
	@Exemplars(set={
	@Exemplar(args={"1l","2"}, expect="0.5f"),
	@Exemplar(args={"2l","2"}, expect="0.25f"),
	@Exemplar(args={"3l","2"}, expect="0.75f"),
	@Exemplar(args={"4l","2"}, expect="0.125f"),
	@Exemplar(args={"5l","2"}, expect="0.625f"), 
	@Exemplar(args={"1l","3"}, expect="0.333333333333f"),
	@Exemplar(args={"2l","3"}, expect="0.666666666667f")
	})
	private static float haltonNumber(final long index, final int base) {
		double result = 0;
		double f = 1.0 / base;
		long i = index;
		while (i > 0) {
			result = result + f * (i % base);
			i = i / base;
			f = f / base;
		}
		return (float) result;
	}

}
