/**
 * 
 */
package edu.wright.cs.birg.experiment.micdistribution;

/**
 * A data point from the dependence measures experiment. Corresponds to one
 * tuple from the schema listed in the implementation specification.
 * 
 * @author Eric Moyer
 * 
 */
public final class DataPoint {
	/**
	 * a primary key for the instance, that is the set of samples, that
	 * generated this tuple within the database.
	 */
	public final long instanceID;

	/**
	 * An integer giving the identifier of the base relation that generated this
	 * tuple. (See the experiment description or the output of the listrelations
	 * command for details)
	 */
	public final int relationID;

	/**
	 * The standard deviation of the noise added to the x coordinate. Noiseless
	 * will have a 0 standard deviation.
	 */
	public final float xNoiseStandardDeviation;

	/**
	 * The standard deviation of the noise added to the y coordinate. Noiseless
	 * will have a 0 standard deviation.
	 */
	public final float yNoiseStandardDeviation;

	/**
	 * The number of samples that was used in generating this dependence measure
	 */
	public final int numSamples;

	/**
	 * an integer giving the identifier of the dependence measure used to
	 * calculate the dependence. If it is 4 or more then the dependence measure
	 * is the MIC with that number of bins, otherwise it is another dependence
	 * measure (see the experiment description or the output of the listdeps
	 * command for details).
	 */
	public final int dependenceMeasureID;

	/**
	 * The value of the dependence measure calculated on the instance identified by instance ID
	 */
	public final float dependence;

	/**
	 * Create a DataPoint with the given values for its fields
	 * @param instanceID the value for the instanceID field
	 * @param relationID the value for the relationID field
	 * @param xNoiseStandardDeviation the value for the xNoiseStandardDeviation field
	 * @param yNoiseStandardDeviation the value for the yNoiseStandardDeviation field
	 * @param numSamples the value for the numSamples field
	 * @param dependenceMeasureID the value for the dependenceMeasureID field
	 * @param dependence the value for the dependence field
	 */
	public DataPoint(long instanceID, int relationID,
			float xNoiseStandardDeviation, float yNoiseStandardDeviation,
			int numSamples, int dependenceMeasureID, float dependence) {
		this.instanceID = instanceID;
		this.relationID = relationID;
		this.xNoiseStandardDeviation = xNoiseStandardDeviation;
		this.yNoiseStandardDeviation = yNoiseStandardDeviation;
		this.numSamples = numSamples;
		this.dependenceMeasureID = dependenceMeasureID;
		this.dependence = dependence;
	}
}
