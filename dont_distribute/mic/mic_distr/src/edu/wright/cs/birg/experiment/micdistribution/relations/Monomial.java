/**
 * 
 */
package edu.wright.cs.birg.experiment.micdistribution.relations;

/**
 * A monomial y=x^degree where degree is constant.
 * 
 * @author Eric Moyer
 * 
 */
public class Monomial extends FunctionalRelation {

	private final double degree;

	/**
	 * Create a monomial <code>y=x^degree</code>
	 * 
	 * @param id
	 *            A non-negative integer
	 * @param shortName
	 *            The short name of this relation (consists only of letters,
	 *            numbers and _)
	 * @param fullName
	 *            The full name of this relation (cannot contain tabs)
	 * @param degree
	 *            The degree of the monomial, the power to which x is raised
	 */
	public Monomial(int id, String shortName, String fullName, double degree) {
		super(id, shortName, fullName);
		this.degree = degree;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * edu.wright.cs.birg.experiment.micdistribution.relations.FunctionalRelation
	 * #val(float)
	 */
	@Override
	protected float val(float x) {
		return (float) Math.pow(x, degree);
	}

}
