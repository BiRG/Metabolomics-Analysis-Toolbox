/**
 * 
 */
package edu.wright.cs.birg.feature_selection.correlation;

import org.sureassert.uc.annotation.Exemplar;
import org.sureassert.uc.annotation.Exemplars;

/**
 * Thrown to indicate that Best First Search ran out of memory
 * @author Eric Moyer
 *
 */
@SuppressWarnings("serial") //At the moment, I won't be sending this class to any streams.
                            //I don't define serialVersionUID so that the default UID will catch any
                            //problems and someone can implement it correctly later.
public class BestFirstSearchRanOutOfMemoryException extends Exception {
	/**
	 * The size the queue had reached when the search ran out of memory. Can be considered the maximum size 
	 * queue later algorithms should use 
	 */
	private int maxQueueSize;
	
	
	@Exemplars(set={
	@Exemplar(name="zeroSize",args={"0"}, expect="=( 0,retval.maxQueueSize)"),
	@Exemplar(name="tenSize",args={"10"}, expect="=(10,retval.maxQueueSize)") 
	})
	public BestFirstSearchRanOutOfMemoryException(int maxQueueSize) {
		this.maxQueueSize = maxQueueSize;
	}

	/**
	 * Return the maxQueueSize field of this BestFirstSearchRanOutOfMemoryException
	 * @return the maxQueueSize field
	 */
	@Exemplars(set={
	@Exemplar(i="zeroSize",expect="0"),
	@Exemplar(i="tenSize",expect="10") 
	})
	public int getMaxQueueSize() {
		return maxQueueSize;
	}

}
