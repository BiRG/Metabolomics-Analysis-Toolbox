/**
 * 
 */
package edu.wright.cs.birg.feature_selection.correlation;

/**
 * A method used to search for the best feature subset given a description of
 * the dependence relation between the features.
 * 
 * @author Eric Moyer
 * 
 */
public abstract class FeatureSelectionSearchMethod {
	/**
	 * Create a feature selection search method using the given arguments. This
	 * method is here mainly to provide a template for eclipse to use in the
	 * subclasses.
	 * 
	 * @param args
	 *            the command line arguments needed to initialize this method
	 */
	protected FeatureSelectionSearchMethod(String[] args) {
	}

	/**
	 * Return the best feature set found for predicting the feature at
	 * labelIndex.
	 * 
	 * @param deps
	 *            The intra-feature dependences
	 * @param labelIndex
	 *            The index of the feature to use as the label
	 * @return the best feature set found for predicting the feature at
	 *         labelIndex.
	 * @throws OutOfMemoryError when there is not enough memory for the given search
	 */
	public abstract FeatureSet bestFeatures(Dependences deps, int labelIndex)
			throws OutOfMemoryError;
	
	/**
	 * Return the index into deps that featureIndex comes from if the label
	 * feature has an index of labelIndex in deps.
	 * 
	 * This is a suporting method to depsToArrays and by featureIndex I mean the
	 * index of that feature in the arrays filled by depsToArrays
	 * 
	 * @param featureIndex
	 *            The index of the feature in the arrays returned by
	 *            depsToArrays
	 * @param labelIndex
	 *            The index of the label in deps
	 * @return the index into deps that featureIndex comes from if the label
	 *         feature has an index of labelIndex in deps.
	 */
	private static int depsIdx(int featureIndex, int labelIndex){
		if(featureIndex < labelIndex){
			return featureIndex;
		}else{
			return featureIndex + 1;
		}
	}

	/**
	 * Convert the dependencies object to a set of arrays so I can use my
	 * earlier code for the feature set selection.
	 * 
	 * In the parameter descriptions, numF = the deps.getNumFeatures()-1, which
	 * is the number of features that are not class features
	 * 
	 * @param deps
	 *            The dependencies object (not null)
	 * @param labelIndex
	 *            The index of the class variable in the deps object
	 * @param labelDeps
	 *            (Output parameter) must be passed as an array double[numF]
	 *            that will be filled so classDeps[i] the dependence of the
	 *            label on the i-th non-label feature (not null)
	 * @param featureDeps
	 *            (Output parameter) must be passed as an array
	 *            double[numF][numF] that will be filled so featureDeps[i][j]
	 *            the dependence of the j-th non-label feature on the i-th
	 *            non-label feature (not null)
	 */
	protected void depsToArrays(Dependences deps, int labelIndex,
			double[] labelDeps, double[][] featureDeps) {
		// Check for valid arguments
		if (labelIndex >= deps.getNumFeatures() || labelIndex < 0) {
			throw new IllegalArgumentException("Bad label index (" + labelIndex
					+ ") when there are only " + deps.getNumFeatures()
					+ " original features.");
		}
		int numFeatures = deps.getNumFeatures() - 1;
		if (labelDeps.length != numFeatures) {
			throw new IllegalArgumentException(
					"classDeps.length should have been " + numFeatures
							+ " not " + labelDeps.length);
		}
		if (featureDeps.length != numFeatures) {
			throw new IllegalArgumentException(
					"featureDeps.length should have been " + numFeatures
							+ " not " + featureDeps.length);
		}
		for (int i = 0; i < featureDeps.length; ++i) {
			if (featureDeps[i].length != numFeatures) {
				throw new IllegalArgumentException("featureDeps[" + i
						+ "].length should have been " + numFeatures + " not "
						+ featureDeps[i].length);
			}
		}

		// Fill classDeps and originalIndex
		for (int i = 0; i < numFeatures; ++i) {
			int dIdx = depsIdx(i, labelIndex);
			labelDeps[i] = deps.getDep(labelIndex, dIdx);
		}

		// Fill featureDeps
		for (int f1 = 0; f1 < numFeatures; ++f1) {
			int d1 = depsIdx(f1, labelIndex);
			for (int f2 = 0; f2 < numFeatures; ++f2) {
				int d2 = depsIdx(f2, labelIndex);
				featureDeps[f1][f2] = deps.getDep(d1, d2);
			}
		}
	}

	/**
	 * Return an array originalIndex such that originalIndex[i] is set to
	 * deps.getIndex(k) where k is the index in deps of the i-th non-label
	 * feature
	 * 
	 * @param deps
	 *            The dependencies object (not null)
	 * @param labelIndex
	 *            The index of the class variable in the deps object
	 * @return an array originalIndex such that originalIndex[i] is set to
	 *         deps.getIndex(k) where k is the index in deps of the i-th
	 *         non-label feature
	 */
	public static int[] originalIndices(Dependences deps, int labelIndex){
		int numFeatures = deps.getNumFeatures()-1;
		int[] originalIndex = new int[numFeatures];
		for (int i = 0; i < numFeatures; ++i) {
			int dIdx = depsIdx(i, labelIndex);
			originalIndex[i] = deps.getOriginalIndex(dIdx);
		}
		return originalIndex;
	}
	
	/**
	 * Print the usage message follwed by msg on its own line. If msg is null, it is not printed, 
	 * but the usage is still printed.
	 * @param msg The message to print after the usage message. not printed if null.
	 */
	public static void printUsage(String msg){
		CorrelationBasedFeatureSelection.printUsage(msg);
	}

}
