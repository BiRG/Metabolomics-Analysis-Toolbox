/**
 * 
 */
package edu.wright.cs.birg.experiment.micdistribution.relations;

/**
 * @author Eric Moyer
 *
 */
public final class AlmostFlatRel extends FunctionalRelation {
	private final double d=1e-7;
	
	/**
	 */
	public AlmostFlatRel() {
		super(10001, "almostflat", "Almost flat");
	}

	/* (non-Javadoc)
	 * @see edu.wright.cs.birg.experiment.micdistribution.relations.FunctionalRelation#val(float)
	 */
	@Override
	protected float val(float x) {
		if(x < 1-d){
			return (float) (x*d);
		}else{
			return (float) (1+d*(x-1));
		}
	}

}
