/**
 * 
 */
package edu.wright.cs.birg.experiment.micdistribution.relations;

import org.sureassert.uc.annotation.Exemplar;
import org.sureassert.uc.annotation.Exemplars;

/**
 * A sinusoidal relation of the form (cos(piFactor*PI*x(1+x))+1)/2
 * 
 * @author Eric Moyer
 * 
 */
public final class VaryingCosineRel extends FunctionalRelation {

	/**
	 * The multiplier piFactor*PI
	 */
	private final double mul;

	/**
	 * A sinusoidal relation of the form (cos(piFactor*PI*x(1+x))+1)/2
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
	 *            this cosine
	 */
	@Exemplar(name = "varfr5c", args = { "85", "'varfr5c'", "'Varying Freq 5 pi Cosine'", "5d" }, e = {
			"=(retval.id,85)", "=(retval.shortName,'varfr5c')",
			"=(retval.fullName,'Varying Freq 5 pi Cosine')",
			"=(retval.mul,[d:15.707963267948966])" })
	public VaryingCosineRel(int id, String shortName, String fullName, double piFactor) {
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
			@Exemplar(i = "varfr5c", args = { "0f" }, expect = "1f"),
			@Exemplar(i = "varfr5c", args = { "0.75f" }, expect = "0.402454838991936f"),
			@Exemplar(i = "varfr5c", args = { "0.5f" }, expect = "0.853553390593274f") })
	protected float val(float x) {
		double d = x;
		return (float) ((Math.cos(mul * d*(1+d)) + 1.0) / 2);
	}

	@Override
	@Exemplar(expect = "'(cos(15.707963267948966x(1+x))+1)/2'")
	public String toString() {
		return "(cos(" + mul + "x(1+x))+1)/2";
	}
}
