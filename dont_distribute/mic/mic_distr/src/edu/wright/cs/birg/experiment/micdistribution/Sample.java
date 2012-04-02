/**
 * 
 */
package edu.wright.cs.birg.experiment.micdistribution;

/**
 * A sample from a 2 dimensional distribution
 * @author Eric Moyer
 */
public final class Sample {
	/**
	 * The x coordinate of this sample
	 */
	public final float x;
	/**
	 * The y coordinate of this sample
	 */
	public final float y;
	
	/**
	 * Create a Sample with the given coordinates 
	 * @param x The x coordinate of the new Sample
	 * @param y The y coordinate of the new Sample
	 */
	Sample(float x, float y){
		this.x = x; this.y = y;
	}
	
	/**
	 * Return a Sample resulting from adding this sample's coordinates to the other one
	 * @param other The sample whose coordinates are to be added to this one.
	 * @return a Sample resulting from adding this sample's coordinates to the other one
	 */
	Sample add(Sample other){
		return new Sample(x+other.x, y+other.y);
	}
}
