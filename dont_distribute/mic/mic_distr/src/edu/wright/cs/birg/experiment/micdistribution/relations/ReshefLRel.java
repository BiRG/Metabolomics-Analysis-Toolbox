/**
 * 
 */
package edu.wright.cs.birg.experiment.micdistribution.relations;

/**
 * L-shaped relation from table S3 of the Reshef paper
 * 
 * @author Eric Moyer
 *
 */
public final class ReshefLRel extends FunctionalRelation {

	/**
	 * Create an L-shaped relation
	 */
	public ReshefLRel(){
		super(350, "L","L-shaped");
	}

	/* (non-Javadoc)
	 * @see edu.wright.cs.birg.experiment.micdistribution.relations.FunctionalRelation#val(float)
	 */
	@Override
	protected float val(float x) {
		if(x < 0.99){
			return x/99;
		}else{
			return 1;
		}
	}

}
