package edu.wright.cs.birg.feature_selection.correlation;

import edu.wright.cs.birg.variable_dependence.Variable;

/**
 * The data for a supervised learning problem.  Consists of the feature variables and the 
 * label variable to be predicted from them. This is just a data-holder class for easier code organization.
 * 
 * @author Eric Moyer
 *
 */
class SupervisedData{
	/**
	 * The features in a supervised learning problem
	 */
	public Variable[] features;
	/**
	 * The label in a supervised learning problem
	 */
	public Variable label;
	
	/**
	 * Splits vars into features and the label
	 * @param vars The variables in the supervised problem (There must be at least 1 variable)
	 * @param labelIndex The zero-based index into the vars array of the variable to use as the label
	 */
	public SupervisedData(Variable[] vars, int labelIndex){
		if(vars.length < 1){
			throw new IllegalArgumentException("Too few variables to make SupervisedData object.  At least one variable is needed");
		}
		//Ensure valid labelIndex input
		if(labelIndex < 0 || labelIndex >= vars.length){
			throw new IllegalArgumentException("labelIndex out of bounds: labelIndex was "+labelIndex+" when there "+
					"were only "+vars.length+" variables.  Legal indices were 0.."+(vars.length-1));
		}
		label = vars[labelIndex];

		int numFeatures = vars.length - 1;
		features = new Variable[numFeatures];
		for(int feat = 0; feat < numFeatures; ++feat){
			if(feat < labelIndex){
				features[feat] = vars[feat];
			}else{ //Note that this skips the class variable
				assert(feat >= labelIndex);
				features[feat] = vars[feat+1];
			}
		}
	}
}