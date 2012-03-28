/**
 * 
 */
package edu.wright.cs.birg.experiment.micdistribution;

import java.util.Random;

import org.sureassert.uc.annotation.Exemplar;
import org.sureassert.uc.annotation.Exemplars;

/**
 * A relation consisting of a finite set of points. Generic version of the categorical relation 
 * from Reshef's paper (table S2)
 * @author Eric Moyer
 *
 */
public final class CategoricalRel extends Relation {
	/**
	 * x[i] is the x value of the i'th point in this relation
	 */
	private final float[] x;
	
	/**
	 * y[i] is the y value of the i'th point in this relation
	 */
	private final float[] y;
	
	/* (non-Javadoc)
	 * @see edu.wright.cs.birg.experiment.micdistribution.Relation#samples(java.util.Random, int)
	 */
	@Exemplars(set={
	@Exemplar(i="cat01",args={"null","1"}, ee="NullPointerException"),
	@Exemplar(i="cat01",args={"new java/util/Random(1l)","0"}, expect="=(retval.getNumSamples(),0)"),
	@Exemplar(i="cat01",args={"new java/util/Random(1l)","2"}, expect={
	"java/util/Arrays.equals(retval.x,[pa:0f, 0f])",
	"java/util/Arrays.equals(retval.y,[pa:0f, 0f])"}),
	@Exemplar(i="cat02",args={"new java/util/Random(1l)","3"}, expect={
	"java/util/Arrays.equals(retval.x,[pa:1f, 0f, 0f])",
	"java/util/Arrays.equals(retval.y,[pa:1f, 0f, 0f])"}),
	})
	@Override
	public Instance samples(Random rng, int numSamples) {
		Instance out = new Instance(numSamples);
		for(int i = 0; i < numSamples; ++i){
			int point = rng.nextInt(x.length);
			out.x[i] = x[point];
			out.y[i] = y[point];
		}
		return out;
	}

	/**
	 * Create a Categorical relation in which the coordinates of the i-th point
	 * in the relation are (x[i],y[i]).
	 * 
	 * @param id
	 *            the id of this Relation. Same as the corresponding parameter
	 *            in the Relation constructor.
	 * @param shortName
	 *            the short name of this Relation. Same as the corresponding
	 *            parameter in the Relation constructor.
	 * @param fullName
	 *            the full name of this relation. Same as the corresponding
	 *            parameter in the Relation constructor.
	 * @param x
	 *            x[i] is the x value of the i'th point in this relation. Cannot
	 *            be null. Must be the same length as y.
	 * @param y
	 *            y[i] is the y value of the i'th point in this relation. Cannot
	 *            be null. Must be the same length as x.
	 */
	@Exemplars(set={
	@Exemplar(n="cat01",a={"150", "'categorical01'", "'Categorical 1'",	"[pa:0f]", "[pa:0f]"}, 
		expect={
		"=(retval.id,150)","=(retval.shortName,'categorical01')",
		"=(retval.fullName,'Categorical 1')","java/util/Arrays.equals(retval.x,[pa:0f])",
		"java/util/Arrays.equals(retval.y,[pa:0f])"}),
	@Exemplar(n="cat02",a={"151", "'categorical02'", "'Categorical 2'",	"[pa:0f,1f]", "[pa:0f,1f]"}, 
		expect={
		"=(retval.id,151)","=(retval.shortName,'categorical02')",
		"=(retval.fullName,'Categorical 2')","java/util/Arrays.equals(retval.x,[pa:0f,1f])",
		"java/util/Arrays.equals(retval.y,[pa:0f,1f])"}),
	@Exemplar(args={"150", "'categorical01'", "'Categorical 1'","null","null"}, ee="IllegalArgumentException"), 
	@Exemplar(args={"150", "'categorical01'", "'Categorical 1'","[pa:0f]", "null"}, ee="IllegalArgumentException"), 
	@Exemplar(args={"150", "'categorical01'", "'Categorical 1'","[pa:0f]","[pa:0f,1f]"}, ee="IllegalArgumentException"), 
	@Exemplar(args={"0","null","null","null","null"}, ee="NullPointerException") 
	})
	CategoricalRel(int id, String shortName, String fullName, float[] x, float[] y){
		super(id, shortName, fullName);
		
		if (x == null) {
			throw new IllegalArgumentException(
					"The x parameter in creating a categorical relation cannot be null.");
		}
		if (y == null) {
			throw new IllegalArgumentException(
					"The y parameter in creating a categorical relation cannot be null.");
		}
		if (x.length != y.length) {
			throw new IllegalArgumentException(
					"The arrays passed to the CategoricalRel(...,float[],float[]) "+
					"constructor must be the same length");
		}

		this.x = x; this.y = y;
	}
}
