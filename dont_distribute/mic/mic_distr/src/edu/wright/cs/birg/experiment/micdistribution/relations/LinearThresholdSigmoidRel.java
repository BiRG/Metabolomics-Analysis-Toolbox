/**
 * 
 */
package edu.wright.cs.birg.experiment.micdistribution.relations;

/**
 * The linear-threshold sigmoid from Reshef table S3
 * @author Eric Moyer
 *
 */
public final class LinearThresholdSigmoidRel extends FunctionalRelation {

	/**
	 * Create a linear threshold sigmoid
	 */
	public LinearThresholdSigmoidRel() {
		super(300, "sigmoid", "Linear threshold sigmoid from Reshef");
	}

	/* (non-Javadoc)
	 * @see edu.wright.cs.birg.experiment.micdistribution.relations.FunctionalRelation#val(float)
	 */
	@Override
	protected float val(float x) {
		if(x < 0.49){
			return 0;
		}else if(x > 0.51){
			return 1;
		}else{
			return (float) (50*(x-0.5)+0.5);
		}
	}

}
