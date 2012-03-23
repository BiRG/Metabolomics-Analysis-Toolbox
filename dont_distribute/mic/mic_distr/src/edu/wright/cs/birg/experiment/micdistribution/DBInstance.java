/**
 * 
 */
package edu.wright.cs.birg.experiment.micdistribution;

import java.io.Serializable;

/**
 * The database record of an instance after it has been generated and run
 * through dependence measures
 * 
 * @author Eric Moyer
 * 
 */
public final class DBInstance implements Serializable {
	/**
	 * The serial version id used by Serializable to decide whether this version
	 * can load a saved class
	 */
	private static final long serialVersionUID = 1L;
	
	/**
	 * The id of the relation that generated this instance
	 */
	public int relationID;

	/**
	 * The noise standard deviation for the x coordinate when this instance was
	 * generated. 0 means noiseless.
	 */
	public float xNoiseStandardDeviation;

	/**
	 * The noise standard deviation for the y coordinate when this instance was
	 * generated. 0 means noiseless.
	 */
	public float yNoiseStandardDeviation;

	/**
	 * The number of samples that were generated for this instance
	 */
	public int numSamples;

	/**
	 * dependenceMeasureId[i] is the id for the i'th dependence measure that was
	 * run on this instance. Must have at least 1 entry and be non-null.
	 * Must be the same size as dependences.
	 */
	public int[] dependenceMeasureIds;

	/**
	 * dependences[i] is the dependence value calculated by the i'th dependence
	 * measure that was run on this instance. Must have at least 1 entry and be non-null. 
	 * Must be the same size as dependenceMeasureIds.
	 */
	public float[] dependences;

	/**
	 * Do-nothing no argument constructor. Here to support serialization.
	 */
	protected DBInstance() {
	}

	/**
	 * Create a DBInstance with its fields initialized to the identically named
	 * values and dependenceMeasureIDs and dependences created with
	 * numDependenceMeasures uninitialized entries each.
	 * 
	 * @param relationID
	 *            The id of the relation that generated this instance
	 * @param xNoiseStandardDeviation
	 *            The noise standard deviation for the x coordinate when this
	 *            instance was generated. 0 means noiseless.
	 * @param yNoiseStandardDeviation
	 *            The noise standard deviation for the y coordinate when this
	 *            instance was generated. 0 means noiseless.
	 * @param numSamples
	 *            The number of samples that were generated for this instance
	 * @param numDependenceMeasures
	 *            The number of dependence measures to record for this instance. Must be at least 1
	 */
	public DBInstance(int relationID, float xNoiseStandardDeviation,
			float yNoiseStandardDeviation, int numSamples,
			int numDependenceMeasures) {
		this.relationID = relationID;
		this.xNoiseStandardDeviation = xNoiseStandardDeviation;
		this.yNoiseStandardDeviation = yNoiseStandardDeviation;
		this.numSamples = numSamples;
		this.dependenceMeasureIds = new int[numDependenceMeasures];
		this.dependences = new float[numDependenceMeasures];
	}

	/**
	 * Return the number of dependence measures whose values were recorded for this instance. 
	 * @return the number of dependence measures whose values were recorded for this instance.
	 */
	public int getNumDependenceMeasures() {
		return dependenceMeasureIds.length;
	}

}
