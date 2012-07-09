/**
 * 
 */
package edu.wright.cs.birg.variable_dependence;

import org.sureassert.uc.annotation.Exemplars;
import org.sureassert.uc.annotation.Exemplar;


/**
 * A dependence that is the absolute value of the pearson correlation between two variables
 * @author Eric Moyer
 *
 */
public class PearsonCorrelationMeasure implements SymmetricDependenceMeasure {

	/**
	 * Return the mean value of the data for the variable x
	 * @param x The variable whose mean will be taken.  Cannot be null or 0 length.
	 * @return the mean value of the data for the variable x
	 */
	@Exemplars(set={
	@Exemplar(args={"null"}, ee="NullPointerException"),
	@Exemplar(args={"Variable/Empty"}, ee="IllegalArgumentException"),
	@Exemplar(args={"Variable/MyVar1_0"}, e="1.0"),
	@Exemplar(args={"Variable/OneTwo"}, e="1.5"),
	})
	private static double mean(Variable x){
		double[] d = x.getData();
		if(d.length < 1){
			throw new IllegalArgumentException("You cannot take the mean of a variable with no samples.");
		}
		double sum = 0;
		for(int i = 0; i < d.length; ++i){
			sum += d[i];
		}
		return sum / d.length;
	}
		
	/* (non-Javadoc)
	 * @see edu.wright.cs.birg.variable_dependence.DependenceMeasure#dependence(edu.wright.cs.birg.variable_dependence.Variable, edu.wright.cs.birg.variable_dependence.Variable)
	 */
	@Override
	@Exemplars(set={
	@Exemplar(args={"Variable/TwentyInLine","Variable/TwentyInLine"}, expect="1.0"),
	@Exemplar(args={"Variable/TwentyInLine","Variable/TwentySquares"}, expect="0.9713482021963808"),
	@Exemplar(args={"Variable/TwentyInLine","Variable/UShape"}, expect="0.0"), 
	})
	public double dependence(Variable x, Variable y) {
		double[] dx = x.getData();
		double[] dy = y.getData();
		double mx = mean(x);
		double my = mean(y);
		double cross = 0; double xssq = 0; double yssq = 0;
		for(int i = 0; i < dx.length; ++i){
			cross += (dx[i]-mx)*(dy[i]-my); //Product across variables - centered x * centered y
			xssq += (dx[i]-mx)*(dx[i]-mx);  //sum of the squares of the centered x variables
			yssq += (dy[i]-my)*(dy[i]-my);  //sum of the squares of the centered y variables
		}
		
		return Math.abs(cross/(Math.sqrt(xssq)*Math.sqrt(yssq)));
	}

	/* (non-Javadoc)
	 * @see edu.wright.cs.birg.variable_dependence.DependenceMeasure#name()
	 */
	@Override
	public String name() {
		return "Pearson correlation coefficient (r)";
	}

}
