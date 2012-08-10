/**
 * 
 */
package edu.wright.cs.birg.experiment.micdistribution.relations;

import org.sureassert.uc.annotation.Exemplar;
import org.sureassert.uc.annotation.Exemplars;

/**
 * A sinusoidal relation of the form (sin(piFactor*PI*x(1+x))+1)/2
 * 
 * @author Eric Moyer
 * 
 */
public final class VaryingSineRel extends FunctionalRelation {

	/**
	 * The multiplier piFactor*PI
	 */
	private final double mul;

	/**
	 * A sinusoidal relation of the form (sin(piFactor*PI*x(1+x))+1)/2
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
	@Exemplar(name = "varfr6s", args = { "86", "'varfr6s'", "'Varying Freq 6 pi Sine'", "6d" }, e = {
			"=(retval.id,86)", "=(retval.shortName,'varfr6s')",
			"=(retval.fullName,'Varying Freq 6 pi Sine')",
			"=(retval.mul,[d:18.849555921538760])" })
	public VaryingSineRel(int id, String shortName, String fullName, double piFactor) {
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
			@Exemplar(i = "varfr6s", args = { "0f" }, expect = "0.5f"),
			@Exemplar(i = "varfr6s", args = { "0.75f" }, expect = "0.308658283817455f"),
			@Exemplar(i = "varfr6s", args = { "0.5f" }, expect = "1f") })
	protected float val(float x) {
		double d = x;
		return (float) ((Math.sin(mul * d*(1+d)) + 1.0) / 2);
	}

	@Override
	@Exemplar(expect = "'(sin(18.84955592153876x(1+x))+1)/2'")
	public String toString() {
		return "(sin(" + mul + "x(1+x))+1)/2";
	}
}
