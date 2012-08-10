/**
 * 
 */
package edu.wright.cs.birg.experiment.micdistribution.relations;

/**
 * Lopsided L-shaped from Table S3 of Reshef paper
 * @author Eric Moyer
 *
 */
public final class ReshefLopLRel extends FunctionalRelation {

	/**
	 * Create a Lopsided L-shaped relation
	 */
	public ReshefLopLRel(){
		super(351,"L_lop","Lopsided L-shaped");
	}

	/* (non-Javadoc)
	 * @see edu.wright.cs.birg.experiment.micdistribution.relations.FunctionalRelation#val(float)
	 */
	@Override
	protected float val(float x) {
		if(x < 0.005){
			return 200*x;
		}else if(x < 0.01){
			return 1.99f-198*x;
		}else{
			return (1-x)/99;
		}
	}

}
