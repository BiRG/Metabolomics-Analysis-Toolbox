/**
 * 
 */
package edu.wright.cs.birg.experiment.micdistribution.relations;

import java.util.Random;

import org.sureassert.uc.annotation.Exemplar;
import org.sureassert.uc.annotation.Exemplars;

import edu.wright.cs.birg.experiment.micdistribution.Instance;

/**
 * A relation signifying the line y=a*x where a >= 0.
 * 
 * @author Eric Moyer
 * 
 */
public final class UpLineRel extends ArcLengthRelation {

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
	 *            The slope of the line. Must not be negative.
	 */
	@Exemplars(set={
	@Exemplar(args={"161","'lines1'","'1 Line'","-1.0"}, ee="IllegalArgumentException"),
	@Exemplar(n="lines1", args={"161","'lines1'","'1 Line'","1.0"}, e={
			"=(retval.id,161)", "=(retval.shortName,'lines1')",
			"=(retval.fullName,'1 Line')", "=(retval.arcLength,[d:1.4142135623730951])",
			"=(retval.slope,[d:1])" }),
	@Exemplar(n="linesqrt3",args={"0","'linesSqrt3'","'Line slope sqrt(3)'","1.7320508075688772935"}, e={
			"=(retval.id,0)", "=(retval.shortName,'linesSqrt3')",
			"=(retval.fullName,'Line slope sqrt(3)')", "=(retval.arcLength,[d:1.1547005383792517])",
			"=(retval.slope,[d:1.7320508075688772935])" }),
	@Exemplar(args={"0","'linesOneOverSqrt3'","'Line slope one over sqrt(3)'","0.577350269189626"}, e={
			"=(retval.id,0)", "=(retval.shortName,'linesOneOverSqrt3')",
			"=(retval.fullName,'Line slope one over sqrt(3)')", "=(retval.arcLength,[d:1.1547005383792517])",
			"=(retval.slope,[d:0.577350269189626])" }),
	})
	public UpLineRel(int id, String shortName, String fullName, double slope) {
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
	@Exemplar(args={"1.0"}, expect="1.4142135623730951"),
	@Exemplar(args={"1.7320508075688772935"}, expect="1.1547005383792517"),
	@Exemplar(args={"0.577350269189626"}, expect="1.1547005383792517")
	})
	private static double arcLengthFor(double slope) {
		if (slope < 0) {
			throw new IllegalArgumentException("The slope of an UpLineRel relation must be greater than 0.");
		} if (slope <= 1) {
			return Math.sqrt(1 + slope * slope);
		} else {
			return Math.sqrt(1 + 1 / (slope * slope));
		}
	}


	@Override
	@Exemplar(i="lines1",expect="'1.0*x'")
	public String toString(){
		return Double.toString(slope)+"*x";
	}
	
	@Override
	public Instance samples(Random rng, int numSamples) {
		Instance i = new Instance(numSamples);
		if(slope <= 1){
			for(int j = 0; j < numSamples; ++j){
				i.x[j]=rng.nextFloat();
				i.y[j]=(float) (slope*i.x[j]);
			}
		}else{
			for(int j = 0; j < numSamples; ++j){
				i.y[j]=rng.nextFloat();
				i.x[j]=(float) (i.y[j]/slope);
			}			
		}
		return i;
	}

}
