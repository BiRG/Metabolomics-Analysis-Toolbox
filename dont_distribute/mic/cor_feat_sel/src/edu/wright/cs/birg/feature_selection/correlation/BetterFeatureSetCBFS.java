/**
 * 
 */
package edu.wright.cs.birg.feature_selection.correlation;

import java.util.Comparator;

/**
 * Order FeatureSets according to cbfs score ties are broken by number of features.  a comes before b if a has a
 * better cbfs score.  If two have the same score, then a comes before b if a has fewer features.  If they have 
 * the same score and the same number of features then they are equal
 * 
 * @author Eric Moyer
 */
public class BetterFeatureSetCBFS implements Comparator<FeatureSet> {
	/**
	 * classCor[i] is the correlation between the class and the i-th feature
	 */
	private double[] classCor;
	/**
	 * featureCor[i][j] is the correlation between the i-th feature and the j-th feature
	 */
	private double[][] featureCor;
	
	/**
	 * Create a Correlation-Based Feature Selection (CBFS) feature-set comparator that uses the given correlations as the basis of its scores.
	 * 
	 * If n is the number of features, then classCor.length=n, featureCor.length=n. Also, for all i, 0 <= i < n
	 * featureCor.length = n
	 * 
	 * @param classCor classCor[i] is the correlation between the class and the i-th feature
	 * @param featureCor featureCor[i][j] is the correlation between the i-th feature and the j-th feature
	 */
	public BetterFeatureSetCBFS(double[] classCor, double[][] featureCor) {
		if(classCor.length != featureCor.length ||
				classCor.length > 0 && classCor.length != featureCor[0].length){ 
			throw new IllegalArgumentException("featureCor must have dimensions of classCor.length x classCor.length");
		}
		this.classCor = classCor;
		this.featureCor = featureCor;
	}

	@Override
	public int compare(FeatureSet a, FeatureSet b) {
		double aScore = a.cbfsScore(classCor, featureCor);
		double bScore = b.cbfsScore(classCor, featureCor);
		double diff = bScore-aScore;
		if(diff != 0){ return (int)Math.signum(diff); }
		return a.getNumFeatures()-b.getNumFeatures();
	}

}
