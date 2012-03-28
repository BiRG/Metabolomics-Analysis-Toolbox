/**
 * 
 */
package edu.wright.cs.birg.experiment.micdistribution.relations;

import org.sureassert.uc.annotation.Exemplar;
import org.sureassert.uc.annotation.Exemplars;

/**
 * @author Eric Moyer
 * 
 */
public class ArcLengthSine extends FunctionalArcLengthRelation {
	/**
	 * The angular frequency of this sine wave (result = (1+sin(xMultiple*x))/2)
	 */
	private double xMultiple;

	/**
	 * Return the arc length of a sine wave with a known pi factor, throws an
	 * exception if the factor passed is not in the list of known factors.
	 * 
	 * @param piFactor
	 *            the multiple of pi that is the frequency of this sine wave.
	 * @return the arc length of a sine wave with frequency
	 *         <code>piFactor</code>*pi
	 * @throws RuntimeException
	 *             If <code>piFactor</code> is not in the list of known factors
	 */
	@Exemplars(set={
	@Exemplar(args={"0.0"}, ee="RuntimeException"),
	@Exemplar(args={"2.0"}, expect="2.3048926613536912000"),
	@Exemplar(args={"3.0"}, expect="3.2313069278203268128"),
	@Exemplar(args={"4.0"}, expect="4.1882752036984339214"),
	@Exemplar(args={"10.0"}, expect="10.094000666202479279") })
	private static double arcLengthForPiFactor(double piFactor)
			throws RuntimeException {
		if (piFactor == 2) {
			return 2.3048926613536912000;
		} else if (piFactor == 3) {
			return 3.2313069278203268128;
		} else if (piFactor == 4) {
			return 4.1882752036984339214;
		} else if (piFactor == 10) {
			return 10.094000666202479279;
		} else {
			throw new RuntimeException(
					"The pi factor "
							+ piFactor
							+ " is not in the list of factors with a pre-calculated arc-length");
		}
	}

	/**
	 * Create a sine wave relation <code>y=(1+sin(piFactor*x))/2</code> that can
	 * calculate its arc length. PiFactor Must be one of a list of numbers known to
	 * {@link #arcLengthForPiFactor(double)}. This list includes 2,3,4, and 10.
	 * 
	 * @param id
	 *            A non-negative integer
	 * @param shortName
	 *            The short name of this relation (consists only of letters,
	 *            numbers and _)
	 * @param fullName
	 *            The full name of this relation (cannot contain tabs)
	 * @param piFactor
	 *            The relation's sine wave has a frequency of pi*
	 *            <code>piFactor</code>. Must be one of a list of numbers known
	 *            to {@link #arcLengthForPiFactor(double)}. This list includes
	 *            2,3,4, and 10
	 */
	public ArcLengthSine(int id, String shortName, String fullName, double piFactor) {
		super(id, shortName, fullName, arcLengthForPiFactor(piFactor));
		xMultiple = piFactor * Math.PI;
	}

	@Override
	protected float val(float x) {
		return (float) (1 + Math.sin(xMultiple * x)) / 2;
	}

}
