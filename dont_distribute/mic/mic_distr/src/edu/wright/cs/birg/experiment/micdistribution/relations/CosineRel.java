/**
 * 
 */
package edu.wright.cs.birg.experiment.micdistribution.relations;

import org.sureassert.uc.annotation.Exemplar;
import org.sureassert.uc.annotation.Exemplars;

/**
 * A sinusoidal relation of the form (cos(piFactor*PI*x)+1)/2
 * 
 * @author Eric Moyer
 * 
 */
public final class CosineRel extends FunctionalRelation {

	/**
	 * The multiplier piFactor*PI
	 */
	private final double mul;

	/**
	 * A sinusoidal relation of the form (cos(piFactor*PI*x)+1)/2
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
	@Exemplar(name = "cos01pi", args = { "0", "'cos01pi'", "'Cosine 1pi'", "1.0" }, e = {
			"=(retval.id,0)", "=(retval.shortName,'cos01pi')",
			"=(retval.fullName,'Cosine 1pi')",
			"=(retval.mul,[d:3.141592653589793])" })
	public CosineRel(int id, String shortName, String fullName, double piFactor) {
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
			@Exemplar(i = "cos01pi", args = { "0f" }, expect = "1f"),
			@Exemplar(i = "cos01pi", args = { "1f" }, expect = "0f"),
			@Exemplar(i = "cos01pi", args = { "0.5f" }, expect = "0.5f") })
	protected float val(float x) {
		return (float) ((Math.cos(mul * x) + 1.0) / 2);
	}

	@Override
	@Exemplar(expect = "'(cos(3.141592653589793x)+1)/2'")
	public String toString() {
		return "(cos(" + mul + "x)+1)/2";
	}
}
