/**
 * 
 */
package edu.wright.cs.birg.variable_dependence;

import edu.wright.cs.birg.mic.MIC;

/**
 * A DependenceMeasure representing the Maximal Information Coefficient
 * @author Eric Moyer
 *
 */
public class MaximalInformationCoefficientMeasure implements
		SymmetricDependenceMeasure {

	/* (non-Javadoc)
	 * @see edu.wright.cs.birg.feature_selection.correlation.DependenceMeasure#dependence(edu.wright.cs.birg.feature_selection.correlation.Variable, edu.wright.cs.birg.feature_selection.correlation.Variable)
	 */
	@Override
	public double dependence(Variable x, Variable y) {
		return MIC.mic(x.getData(), y.getData());
	}

	/* (non-Javadoc)
	 * @see edu.wright.cs.birg.feature_selection.correlation.DependenceMeasure#name()
	 */
	@Override
	public String name() {
		return "Maximal information coefficient dependence";
	}

}
