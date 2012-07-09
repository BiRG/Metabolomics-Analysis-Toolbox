/**
 * 
 */
package edu.wright.cs.birg.exactmic;

/**
 * Contains the name and values of a particular attribute of the original samples read in from the CSV file
 * 
 * @author Eric Moyer
 *
 */
public class SampleVariable {
	/** The name of this variable */
	private final String name;
	/** values[i] has the value of this variable on the i-th sample */
	private final double[] values;
	
	/**
	 * Create a variable named name with the given values for each sample.
	 * @param name The name of the variable to create
	 * @param values values[i] has the value of this variable in the i-th sample 
	 */
	public SampleVariable(String name, double[] values){
		this.name=name; this.values=values;
	}

	/**
	 * @return the name of this variable
	 */
	public String getName() {
		return name;
	}

	/**
	 * getValues()[i] is the value of this variable on the i-th sample
	 * @return the values taken by this variable on each sample.  
	 */
	public double[] getValues() {
		return values;
	}
	
}
