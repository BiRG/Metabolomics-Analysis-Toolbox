/**
 * 
 */
package edu.wright.cs.birg.experiment.micdistribution.relations;

/**
 * The sum of a line with the equation y=slope*x+offset and a sine wave with the
 * equation y=amplitude*sin(frequency*x+phase). It is up to the creator to
 * ensure that the resulting relation fits into the unit square and is
 * appropriately normalized. This is the same as the Linear+Periodic relation in
 * Reshef.
 * 
 * @author Eric Moyer
 * 
 */
public final class SlantSineRel extends FunctionalRelation {

	/**
	 * The amplitude of the sine term: y=amplitude*sin(frequency*x+phase)
	 */
	private final double amplitude;
	/**
	 * The frequency of the sine term: y=amplitude*sin(frequency*x+phase)
	 */
	private final double frequency;
	/**
	 * The phase of the sine term: y=amplitude*sin(frequency*x+phase)
	 */
	private final double phase;
	/**
	 * The slope of the linear term: y=slope*x+offset 
	 */
	private final double slope;
	/**
	 * The y-offset of the linear term: y=slope*x+offset 
	 */
	private final double offset;

	/**
	 * Create a slant-sine with the equation
	 * y=amplitude*sin(frequency*x+phase)+slope*x+offset
	 * 
	 * @param id
	 *            A non-negative integer
	 * @param shortName
	 *            The short name of this relation (consists only of letters,
	 *            numbers and _)
	 * @param fullName
	 *            The full name of this relation (cannot contain tabs)
	 * @param amplitude
	 *            The amplitude of the sine term.
	 * @param frequency
	 *            The frequency of the sine term.
	 * @param phase
	 *            The phase-shift of the sine term.
	 * @param slope
	 *            The slope of the linear term.
	 * @param offset
	 *            The y-offset of the linear term.
	 */
	public SlantSineRel(int id, String shortName, String fullName,
			double amplitude, double frequency, double phase, double slope,
			double offset) {
		super(id, shortName, fullName);
		this.amplitude = amplitude;
		this.frequency = frequency;
		this.phase = phase;
		this.slope = slope;
		this.offset = offset;
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
		return (float) (amplitude*Math.sin(frequency*x+phase)+slope*x+offset);	
	}

}
