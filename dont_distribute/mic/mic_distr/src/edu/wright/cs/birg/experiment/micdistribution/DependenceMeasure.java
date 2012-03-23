/**
 * 
 */
package edu.wright.cs.birg.experiment.micdistribution;

/**
 * A dependence measure that computes a dependence for an instance of data drawn
 * from some relation.
 * 
 * @author Eric Moyer
 * 
 */
interface DependenceMeasure {

	/**
	 * Return the id for this dependence measure. The id must be strictly less
	 * than 4, but it can be negative.
	 * 
	 * @return the id for this dependence measure. The id must be strictly less
	 *         than 4, but it can be negative.
	 */
	public int getID();

	/**
	 * Return a human-readable name for this dependence measure. The name cannot
	 * contain tab characters.
	 * 
	 * @return a human-readable name for this dependence measure. The name
	 *         cannot contain tab characters.
	 */
	public String getName();

	/**
	 * Return the dependence measured for the two variables in the given
	 * instance.
	 * 
	 * @param inst
	 *            The instance whose dependence is to be measured
	 * @return the dependence measured for the two variables in the given
	 *         instance.
	 */
	public float dependence(Instance inst);

}
