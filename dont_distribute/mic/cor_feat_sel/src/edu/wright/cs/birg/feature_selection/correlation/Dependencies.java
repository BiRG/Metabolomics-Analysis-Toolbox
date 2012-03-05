package edu.wright.cs.birg.feature_selection.correlation;

/**
 * The dependencies among some variables, one of which is designated the class. 
 * @author Eric Moyer
 *
 */
class Dependencies{
	/**
	 * featureFeature[i][j] is the degree of dependence between feature index i and feature index j
	 */
	double[][] featureFeature;
	/**
	 * classFeature[i] is the degree of dependence between feature index i and the class
	 */
	double[] classFeature;
	
	/**
	 * Create a dependency object with the given dependencies
	 * @param featureFeature featureFeature[i][j] is the degree of dependence between feature index i and feature index j
	 * @param classFeature classFeature[i] is the degree of dependence between feature index i and the class
	 */
	public Dependencies(double[][] featureFeature, double[] classFeature){
		this.featureFeature = featureFeature;
		this.classFeature = classFeature;
	}
	
	public int numFeatures(){ return classFeature.length; }
}