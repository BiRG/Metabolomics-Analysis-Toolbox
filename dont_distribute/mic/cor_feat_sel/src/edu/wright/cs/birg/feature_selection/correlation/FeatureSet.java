/**
 * 
 */
package edu.wright.cs.birg.feature_selection.correlation;

import java.util.BitSet;

/**
 * A set of features.
 * 
 * This is an immutable object.
 * 
 * @author Eric Moyer
 *
 */
public final class FeatureSet{
	/**
	 * The number of features that can possibly be in a feature set (or, equivalently, the number of features in the domain from which this feature set is drawn). 
	 */
	private int maxFeatures;
	
	/**
	 * True if this feature set has the given feature, false otherwise
	 */
	private BitSet hasFeature;
	
	/**
	 * The value of cbfsScore calculated with cachedClassCor and cachedFaeatureCor - undefined if they are null
	 */
	private double cachedCBFS;
	
	/**
	 * The value of classCor used to calculate cachedCBFS - null iff cachedFeatureCor is null
	 */
	private double[] cachedClassCor; 

	/**
	 * The value of featureCor used to calculate cachedCBFS - null iff cachedClassCor is null
	 */
	private double[][] cachedFeatureCor;

	/**
	 * Create an empty feature set in a domain that has maxFeatures features
	 * @param maxFeatures the number of features in the domain from which this FeatureSet is drawn 
	 */
	public FeatureSet(int maxFeatures){
		this.maxFeatures = maxFeatures;
		hasFeature = new BitSet(maxFeatures);
		cachedCBFS = Double.NaN;
		cachedClassCor = null;
		cachedFeatureCor = null;
	}
	

	
	/**
	 * Return the cbfs score for this feature set, given the input correlations
	 * 
	 * The cbfs merit metric is:
	 * 
	 * (k * rcf)/sqrt(k+k(k-1)*rff)
	 * 
	 * Where k is the number of included features, rcf is the average correlation 
	 * between the features and the class variable and rff is the average correlation between pairs of different 
	 * features 
	 * 
	 * @param classCor classCor[i] = the correlation between the class variable and feature i
	 * @param featureCor featureCor[i][j] = the correlation between features i and j 
	 * @return The cbfs metric for this feature set, given the input correlations
	 */
	public double cbfsScore(double[] classCor, double[][] featureCor){
		if(cachedClassCor != classCor || cachedFeatureCor != featureCor){
			cachedClassCor = classCor; cachedFeatureCor = featureCor;

			int[] f = features();
			int k = f.length;
			
			if(k == 0){ 
				cachedCBFS = 0; 
			}else{
				
				double krcf = 0; //Average cor between class and the included features * k
				for(int i = 0; i < k; ++i){
					krcf += classCor[f[i]];
				}
				
				double krff = 0; //Average cor between different features * k(k-1)
				for(int i = 0; i < k; ++i){
					for(int j = 0; j < i; ++j){
						krff += featureCor[f[i]][f[j]];
					}
				}
				krff *= 2;
				
				cachedCBFS = krcf/Math.sqrt(k+krff);
				
				//System.err.println("Calculating "+ this + ". Score:" + cachedCBFS); //TODO:remove
				//System.err.println("            rcf:"+ (krcf/k)+" rff:"+(krff/(k*(k-1)))); //TODO:remove
			}
		}
		return cachedCBFS;
	}
	
	/**
	 * Return the list of features in this FeatureSet.  If this FeatureSet has
	 * feature i then i will be one of the integers in the returned array.
	 * @return The features in this FeatureSet
	 */
	public int[] features(){
		int[] ret = new int[hasFeature.cardinality()];
		int idx = 0;
		for (int i = hasFeature.nextSetBit(0); i >= 0; i = hasFeature.nextSetBit(i+1)) {
			 ret[idx++] = i;
		}
		return ret;
	}
	
	/**
	 * Create a FeatureSet with all the features in orig with the addition of 
	 * @param orig the feature set to start with
	 * @param featureToInclude the feature to include in the new feature set
	 */
	public FeatureSet(FeatureSet orig, int featureToInclude) {
		maxFeatures = orig.maxFeatures;
		hasFeature = (BitSet)orig.hasFeature.clone();
		hasFeature.set(featureToInclude);
	}

	/**
	 * Return an array containing all feature sets which contain one feature more than this one
	 * @return an array containing all feature sets which contain one feature more than this one
	 */
	public FeatureSet[] allSetsWithOneFeatureMore(){
		int numExcludedFeatures = maxFeatures - hasFeature.cardinality();
		FeatureSet[] ret = new FeatureSet[numExcludedFeatures];

		int idx = 0;
		for (int i = hasFeature.nextClearBit(0); i >= 0 && i < maxFeatures; i = hasFeature.nextClearBit(i+1)) {
			 ret[idx++] = new FeatureSet(this, i);
		}
		
		return ret;
	}

	/**
	 * Return true if and only if this feature set has the same features and the same number of features as o
	 * @param o The feature set being compared to this one
	 * @return true if and only if this feature set has the same features and the same number of features as o
	 */
	public boolean equals(FeatureSet o){
		return maxFeatures == o.maxFeatures && hasFeature.equals(o.hasFeature);
	}
	
	@Override
	public boolean equals(Object o){
		if(o == null){ return false; }
		if(! (o instanceof FeatureSet) ){ return false; }
		FeatureSet f = (FeatureSet)o;
		return equals(f);
	}
	
	@Override
	public int hashCode(){
		return maxFeatures ^ hasFeature.hashCode();
	}

	/**
	 * Return the number of features included in this feature set
	 * @return the number of features included in this feature set
	 */
	public int getNumFeatures() {
		return hasFeature.cardinality();
	}

	/**
	 * Return the number of features in the domain for this FeatureSet
	 * @return the number of features in the domain for this FeatureSet
	 */
	public int getMaxFeatures() {
		return maxFeatures;
	}
	
	@Override
	public String toString(){
		return "FeatureSet("+hasFeature+" of "+getMaxFeatures()+" features)";
	}
}
