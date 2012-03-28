/**
 * 
 */
package edu.wright.cs.birg.experiment.micdistribution.relations;

/**
 * Relations that have an arc-length. This is useful because these relations can
 * be combined using UnionRel and still have a uniform distribution of points.
 * 
 * @author Eric Moyer
 * 
 */
public abstract class ArcLengthRelation extends Relation {
	/**
	 * Acts just like {@link Relation#Relation(int, String, String)} except also
	 * sets the <code>arcLength</code> field.
	 * 
	 * @param id
	 *            A non-negative integer
	 * @param shortName
	 *            The short name of this relation (consists only of letters,
	 *            numbers and _)
	 * @param fullName
	 *            The full name of this relation (cannot contain tabs)
	 * @param arcLength
	 *            The arc length of this relation within the unit square
	 *            [0,1]x[0,1].
	 */
	public ArcLengthRelation(int id, String shortName, String fullName,
			double arcLength) {
		super(id, shortName, fullName);
		this.arcLength = arcLength;
	}

	/**
	 * The arc length of this relation within the unit square [0,1]x[0,1].
	 * 
	 * Note that this is a final variable. Relations' lengths should not change
	 * through their lifespan.
	 */
	final double arcLength;

}
