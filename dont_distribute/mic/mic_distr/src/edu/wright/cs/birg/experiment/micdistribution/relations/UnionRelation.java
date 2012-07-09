/**
 * 
 */
package edu.wright.cs.birg.experiment.micdistribution.relations;

import java.util.Random;

import edu.wright.cs.birg.experiment.micdistribution.Instance;

/**
 * The union of two relations.
 * @author Eric Moyer
 * 
 */
public class UnionRelation extends ArcLengthRelation {

	/**
	 * The first relation in the union
	 */
	private final ArcLengthRelation relation1;

	/**
	 * The second relation in the union
	 */
	private final ArcLengthRelation relation2;

	/**
	 * The probability of relation1 being chosen (proportional to relation1's
	 * arc length)
	 */
	private final double probRelation1;

	/**
	 * Create the union of two relations
	 * 
	 * @param id
	 *            A non-negative integer
	 * @param shortName
	 *            The short name of this relation (consists only of letters,
	 *            numbers and _)
	 * @param fullName
	 *            The full name of this relation (cannot contain tabs)
	 * @param r1
	 *            The first relation in the union
	 * @param r2
	 *            The second relation in the union
	 */
	public UnionRelation(int id, String shortName, String fullName,
			ArcLengthRelation r1, ArcLengthRelation r2) {
		super(id, shortName, fullName, r1.arcLength + r2.arcLength);
		this.relation1 = r1;
		this.relation2 = r2;
		this.probRelation1 = r1.arcLength / (r1.arcLength + r2.arcLength);
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
		// Figure out which samples come from which relation
		int numFromR1 = 0;
		boolean[] fromR1 = new boolean[numSamples];
		for (int i = 0; i < numSamples; ++i) {
			if (rng.nextDouble() < probRelation1) {
				fromR1[i] = true;
				++numFromR1;
			} else {
				fromR1[i] = false;
			}
		}

		// Generate the appropriate number of samples from each relation
		Instance r1I = relation1.samples(rng, numFromR1);
		Instance r2I = relation2.samples(rng, numSamples - numFromR1);

		// Copy the samples, in order, into their appropriate subsets of the
		// result relation
		Instance result = new Instance(numSamples);
		int firstUnusedR1 = 0; // First index in r1I that hasn't been
							   // transferred
		int firstUnusedR2 = 0; // First index in r2I that hasn't been
							   // transferred
		for (int i = 0; i < numSamples; ++i) {
			if (fromR1[i]) {
				result.x[i] = r1I.x[firstUnusedR1];
				result.y[i] = r1I.y[firstUnusedR1];
				++firstUnusedR1;
			} else {
				result.x[i] = r2I.x[firstUnusedR2];
				result.y[i] = r2I.y[firstUnusedR2];
				++firstUnusedR2;
			}
		}
		return result;
	}

}
