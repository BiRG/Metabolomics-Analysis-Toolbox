/**
 * 
 */
package edu.wright.cs.birg.experiment.micdistribution.relations;

import org.sureassert.uc.annotation.Exemplar;
import org.sureassert.uc.annotation.Exemplars;

/**
 * A relation signifying the line y=a*x where a <= 0.
 * 
 * @author Eric Moyer
 * 
 */
public final class DownLineRel extends FunctionalArcLengthRelation {

	/**
	 * The slope of the line
	 */
	private final double slope;

	/**
	 * @param id
	 *            A non-negative integer
	 * @param shortName
	 *            The short name of this relation (consists only of letters,
	 *            numbers and _)
	 * @param fullName
	 *            The full name of this relation (cannot contain tabs)
	 * @param slope
	 *            The slope of the line. Must be negative.
	 */
	@Exemplars(set={
	@Exemplar(args={"161","'lines1'","'1 Line'","1.0"}, ee="IllegalArgumentException"),
	@Exemplar(n="dline1", args={"0","'dline1'","'1 Line Down'","-1.0"}, e={
			"=(retval.id,0)", "=(retval.shortName,'dline1')",
			"=(retval.fullName,'1 Line Down')", "=(retval.arcLength,[d:1.4142135623730951])",
			"=(retval.slope,[d:-1])" }),
	@Exemplar(n="dlinesqrt3",args={"0","'dlinesqrt3'","'Line slope -sqrt(3)'","-1.7320508075688772935"}, e={
			"=(retval.id,0)", "=(retval.shortName,'dlinesqrt3')",
			"=(retval.fullName,'Line slope -sqrt(3)')", "=(retval.arcLength,[d:1.1547005383792517])",
			"=(retval.slope,[d:-1.7320508075688772935])" }),
	@Exemplar(args={"0","'dlineOneOverSqrt3'","'Line slope -one over sqrt(3)'","-0.577350269189626"}, e={
			"=(retval.id,0)", "=(retval.shortName,'dlineOneOverSqrt3')",
			"=(retval.fullName,'Line slope -one over sqrt(3)')", "=(retval.arcLength,[d:1.1547005383792517])",
			"=(retval.slope,[d:-0.577350269189626])" }),
	})
	public DownLineRel(int id, String shortName, String fullName, double slope) {
		super(id, shortName, fullName, arcLengthFor(slope));
		this.slope = slope;
	}

	/**
	 * Return the arc length of a line with the given positive slope cropped to
	 * fit in the unit square
	 * 
	 * @param slope
	 *            The slope of the line - must be more than 0
	 * @return the arc length of a line with the given positive slope cropped to
	 *         fit in the unit square
	 */
	@Exemplars(set={
	@Exemplar(args={"0.0"}, expect="1d"),
	@Exemplar(args={"-1.0"}, expect="1.4142135623730951"),
	@Exemplar(args={"-1.7320508075688772935"}, expect="1.1547005383792517"),
	@Exemplar(args={"-0.577350269189626"}, expect="1.1547005383792517")
	})
	private static double arcLengthFor(double slope) {
		if (slope > 0) {
			throw new IllegalArgumentException("The slope of an UpLineRel relation must be greater than 0.");
		} if (slope > -1) {
			return Math.sqrt(1 + slope * slope);
		} else {
			return Math.sqrt(1 + 1 / (slope * slope));
		}
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see edu.wright.cs.birg.experiment.micdistribution.relations.
	 * FunctionalArcLengthRelation#val(float)
	 */
	@Override
	@Exemplars(set={
	@Exemplar(i="dline1",args={"0f"}, expect="1f"),
	@Exemplar(i="dline1",args={"0.5f"}, expect="0.5f"),
	@Exemplar(i="dlinesqrt3",args={"0.25f"}, expect="0.5669872981f"),
	})
	protected float val(float x) {
		return (float) (1.0+slope*x);
	}

	@Override
	@Exemplar(i="dline1",expect="'-1.0*x'")
	public String toString(){
		return Double.toString(slope)+"*x";
	}
}
