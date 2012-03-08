/**
 * 
 */
package edu.wright.cs.birg.variable_dependence;

import org.sureassert.uc.annotation.Exemplars;
import org.sureassert.uc.annotation.Exemplar;


/**
 * A dependence measure can calculate dependencies between two variables.  Note that this does not 
 * need to be a metric or a measure in the mathematical sense. As long as the same pair of variables in 
 * the same order gives the same result, everything is good.
 * 
 * Since I've forgotten at this moment how CBFS handles things that do not have values in [0,1], it would
 * be wise to keep to dependence measures that have outputs within the interval [0,1] until I can reread that
 * section of Dr. Hall's dissertation.
 * 
 * For use with CBFS, you MUST keep the dependences >= 0 (there is a square root in the denominator, 
 * so negative numbers will cause problems). I still haven't reread things for the numerator.
 *  
 * @author Eric Moyer
 *
 */
public interface DependenceMeasure {
	/**
	 * Return a number indicating the degree of dependence of y upon x.
	 * @param x the first variable (cannot be null)
	 * @param y the second variable (cannot be null)
	 * @return a number indicating the degree of dependence of y upon x.
	 */
	
	@Exemplars(set={
	@Exemplar(args={"null","null"}, ee="NullPointerException"),
	@Exemplar(args={"Variable/MyVar1_0","null"}, ee="NullPointerException") })
	public double dependence(Variable x, Variable y);
	
	/**
	 * Return the human-readable name of this dependence measure
	 * @return the human-readable name of this dependence measure
	 */
	public String name();
}
