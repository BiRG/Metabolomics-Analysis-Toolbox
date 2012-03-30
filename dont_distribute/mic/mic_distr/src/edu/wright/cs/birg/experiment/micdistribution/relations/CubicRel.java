/**
 * 
 */
package edu.wright.cs.birg.experiment.micdistribution.relations;

import org.sureassert.uc.annotation.Exemplar;
import org.sureassert.uc.annotation.Exemplars;

/**
 * Represents a relation defined by a cubic function
 * 
 * @author Eric Moyer
 * 
 */
public final class CubicRel extends FunctionalRelation {
	/**
	 * The coefficient on the constant term. a the formula for a general cubic: a+x*(b+x*(c+d*x)). 
	 */
	double a;
	/**
	 * The coefficient on the linear term. b the formula for a general cubic: a+x*(b+x*(c+d*x)). 
	 */
	double b;
	/**
	 * The coefficient on the quadratic term. c the formula for a general cubic: a+x*(b+x*(c+d*x)). 
	 */
	double c;
	/**
	 * The coefficient on the cubic term. d the formula for a general cubic: a+x*(b+x*(c+d*x)). 
	 */
	double d;

	/**
	 * Create a cubic relation defined by x*(q+r*x*(s*+t*x))/denom .
	 * 
	 * @param id
	 *            A non-negative integer
	 * @param shortName
	 *            The short name of this relation (consists only of letters,
	 *            numbers and _)
	 * @param fullName
	 *            The full name of this relation (cannot contain tabs)
	 * @param denom
	 *            denominator for cubic relation. Cannot be 0
	 * @param q
	 *            see main description
	 * @param r
	 *            see main description
	 * @param s
	 *            see main description
	 * @param t
	 *            see main description
	 */
	@Exemplar(n="cubic1",a={"10","'cubic1'","'Cubic 1'","11d","47d","12d","-11d","8d"}, 
			e={"=(retval.id,10)","=(retval.shortName,'cubic1')","=(retval.fullName,'Cubic 1')",
			"=(retval.a,0d)","=(retval.b,[d:4.2727272727272725])","=(retval.c,-12d)",
			"=(retval.d,[d:8.727272727272727])"})
	public CubicRel(int id, String shortName, String fullName, double denom,
			double q, double r, double s, double t) {
		super(id, shortName, fullName);
		a=0;
		b=q/denom;
		c=(r*s)/denom;
		d=(r*t)/denom;
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
	@Exemplar(i="cubic1", args={"0f"}, expect="0f"),
	@Exemplar(i="cubic1", args={"1f"}, expect="1f")
	})
	protected float val(float x) {
		return (float) (a+x*(b+x*(c+d*x)));	
	}

	@Override
	@Exemplar(i="cubic1",e="'0.0+x(4.2727272727272725+x(-12.0+8.727272727272727x))'")
	public String toString(){
		StringBuilder sb = new StringBuilder();
		sb.append(a);
		sb.append("+x(");
		sb.append(b);
		sb.append("+x(");
		sb.append(c);
		sb.append("+");
		sb.append(d);
		sb.append("x))");
		return sb.toString();
	}
}
