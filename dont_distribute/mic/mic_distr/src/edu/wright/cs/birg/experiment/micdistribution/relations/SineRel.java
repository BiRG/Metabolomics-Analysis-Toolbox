/**
 * 
 */
package edu.wright.cs.birg.experiment.micdistribution.relations;

import org.sureassert.uc.annotation.Exemplar;
import org.sureassert.uc.annotation.Exemplars;

/**
 * A sinusoidal relation of the form (sin(piFactor*PI*x)+1)/2
 * 
 * @author Eric Moyer
 * 
 */
public final class SineRel extends FunctionalRelation {

	/**
	 * The multiplier piFactor*PI
	 */
	private final double mul;

	/**
	 * A sinusoidal relation of the form (sin(piFactor*PI*x)+1)/2
	 * 
	 * @param id
	 *            A non-negative integer
	 * @param shortName
	 *            The short name of this relation (consists only of letters,
	 *            numbers and _)
	 * @param fullName
	 *            The full name of this relation (cannot contain tabs)
	 * @param piFactor
	 *            the factor by which pi is multiplied to give the frequency of
	 *            this sine
	 */
	@Exemplar(name = "sin01pi", args = { "31", "'sin01pi'", "'Sine 1pi'", "1.0" }, e = {
			"=(retval.id,31)", "=(retval.shortName,'sin01pi')",
			"=(retval.fullName,'Sine 1pi')",
			"=(retval.mul,[d:3.141592653589793])" })
	public SineRel(int id, String shortName, String fullName, double piFactor) {
		super(id, shortName, fullName);
		this.mul = piFactor * Math.PI;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * edu.wright.cs.birg.experiment.micdistribution.relations.FunctionalRelation
	 * #val(float)
	 */
	@Override
	@Exemplars(set = {
			@Exemplar(i = "sin01pi", args = { "0f" }, expect = "0.5f"),
			@Exemplar(i = "sin01pi", args = { "0.5f" }, expect = "1f") })
	protected float val(float x) {
		return (float) ((Math.sin(mul * x) + 1.0) / 2);
	}

	@Override
	@Exemplar(expect = "'(sin(3.141592653589793x)+1)/2'")
	public String toString() {
		return "(sin(" + mul + "x)+1)/2";
	}
}
