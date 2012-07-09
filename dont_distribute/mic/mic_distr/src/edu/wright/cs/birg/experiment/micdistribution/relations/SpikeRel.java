/**
 * 
 */
package edu.wright.cs.birg.experiment.micdistribution.relations;


/**
 * Spike relation from table S3 of Reshef paper
 * @author Eric Moyer
 *
 */
public final class SpikeRel extends FunctionalRelation {

	/**
	 * Create a spike relation object
	 */
	public SpikeRel() {
		super(250, "spike", "Spike");
	}

	/* (non-Javadoc)
	 * @see edu.wright.cs.birg.experiment.micdistribution.relations.FunctionalRelation#val(float)
	 */
	@Override
	protected float val(float x) {
		if(x < 0.05){
			return 20*x;
		}else if(0.05 <= x && x < 0.1){
			return 1.9f-18*x;
		}else{
			return (1-x)/9;
		}
	}

}
