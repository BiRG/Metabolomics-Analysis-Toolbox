/**
 * 
 */
package edu.wright.cs.birg.experiment.micdistribution.relations;

/**
 * The parabola 4(x-0.5)^2
 * @author Eric Moyer
 *
 */
public final class ParabolicRel extends FunctionalArcLengthRelation{

	/**
	 * Create a new Parabolic relation 
	 */
	public ParabolicRel() {
		super(1, "parabolic", "Parabolic", 2.3233918812164679367);
	}

	@Override
	protected float val(float x) {
		return (float) (4*(x-0.5)*(x-0.5));
	}

}
