/**
 * 
 */
package edu.wright.cs.birg.experiment.micdistribution.relations;

import org.sureassert.uc.annotation.Exemplar;
import org.sureassert.uc.annotation.Exemplars;

/**
 * An exponential relation with a given base scaled to fit in the unit square.
 * Fits the general formula (base^x-1)/(base-1)
 * 
 * @author Eric Moyer
 * 
 */
public final class ExponentialRel extends FunctionalRelation {

	/**
	 * The denominator of the formula (base^x-1)/(base-1)  
	 */
	private final double denom;
	
	/**
	 * The base of the exponential function (base^x-1)/(base-1)
	 */
	private final double base;

	/**
	 * Create an exponential relation with the formula (base^x-1)/(base-1)
	 * 
	 * @param id
	 *            A non-negative integer
	 * @param shortName
	 *            The short name of this relation (consists only of letters,
	 *            numbers and _)
	 * @param fullName
	 *            The full name of this relation (cannot contain tabs)
	 * @param base The base of the exponential relation. Must not be negative.
	 */
	@Exemplars(set={
	@Exemplar(args={"20","'exp2'","'Exponential base 2'","-1.0"}, ee="IllegalArgumentException"),
	@Exemplar(n="exp2",args={"20","'exp2'","'Exponential base 2'","2d"}, 			
	e={"=(retval.id,20)","=(retval.shortName,'exp2')","=(retval.fullName,'Exponential base 2')",
		"=(retval.base,[d:2.0])","=(retval.denom,[d:1.0])"}),
	@Exemplar(n="exp10",args={"21","'exp10'","'Exponential base 10'","10.0"}, 			
	e={"=(retval.id,21)","=(retval.shortName,'exp10')","=(retval.fullName,'Exponential base 10')",
		"=(retval.base,[d:10.0])","=(retval.denom,[d:9.0])"})
	})
	public ExponentialRel(int id, String shortName, String fullName, double base) {
		super(id, shortName, fullName);
		if(base < 0){
			throw new IllegalArgumentException("The base of the exponential function cannot be negative.");
		}
		this.base = base;
		this.denom = base-1;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * edu.wright.cs.birg.experiment.micdistribution.relations.FunctionalRelation
	 * #val(float)
	 */
	@Override
	@Exemplars(set={
	@Exemplar(i="exp10",args={"1f"}, expect="1f"),
	@Exemplar(i="exp10",args={"0f"}, expect="0f"),
	@Exemplar(i="exp10",args={"0.5f"}, expect="0.240253073f"),
	@Exemplar(i="exp2",args={"0.5f"}, expect="0.414213562f"),
	@Exemplar(i="exp2",args={"1f"}, expect="1f"),
	@Exemplar(i="exp2",args={"0f"}, expect="0f")
	})
	protected float val(float x) {
		return (float) ((Math.pow(base, x)-1)/denom);
	}

}
