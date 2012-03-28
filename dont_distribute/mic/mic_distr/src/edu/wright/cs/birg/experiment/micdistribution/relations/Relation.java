/**
 * 
 */
package edu.wright.cs.birg.experiment.micdistribution.relations;

import java.util.Random;

import edu.wright.cs.birg.experiment.micdistribution.Instance;

/**
 * A relation between two variables on the unit square from which samples can be
 * taken. Since this is the only type of relation one cares about in calculating
 * the distribution of MICs, it gets the simple name of Relation.
 * 
 * @author Eric Moyer
 */
public abstract class Relation {
	/**
	 * The full, human readable name of this Relation. Should not have tabs or
	 * be blank.
	 */
	private final String fullName;
	
	/**
	 * The id of this relation. Any two relation objects with the same ID must
	 * have identical behavior.
	 */
	private final int id;
	
	/**
	 * The short, safe name of the relation. May only consist of letters,
	 * numbers, and _ and must not be blank. Two objects have the same shortName
	 * if and only if they have the same id.
	 */
	private final String shortName;
	
	/**
	 * Return true iff s is a valid full name for a relation, that is, it does
	 * not have tab characters and is not blank.
	 * 
	 * @param s
	 *            The string to be tested.
	 * @return true iff s is a valid full name for a relation, that is, it does
	 *         not have tab characters.
	 */
	private static boolean isValidFullName(String s) {
		return s.length() > 0 && !s.contains("\t");
	}
	
	/**
	 * Return true iff s is a valid short name for a relation, that is, it
	 * contains only _ and alphanumeric characters and is not blank.
	 * 
	 * @param s
	 *            The string to be tested.
	 * @return true iff s is a valid short name for a relation, that is, it
	 *         contains only _ and alphanumeric characters.
	 */
	private static boolean isValidShortName(String s) {
		return s.matches("\\w+");
	}

	/**
	 * Return the full name of this relation
	 * 
	 * @return the full name of this relation
	 */
	public final String getFullName(){
		return fullName;
	}

	/**
	 * Return the id of this Relation
	 * 
	 * @return the id of this Relation
	 */
	public final int getId() {
		return id;
	}

	/**
	 * Return the shortName of this Relation
	 * 
	 * @return the shortName of this Relation
	 */
	public final String getShortName() {
		return shortName;
	}
	
	/**
	 * Initialize this Relation
	 * 
	 * @param id
	 *            A non-negative integer
	 * @param shortName
	 *            The short name of this relation (consists only of letters,
	 *            numbers and _)
	 * @param fullName
	 *            The full name of this relation (cannot contain tabs)
	 */
	public Relation(int id, String shortName, String fullName){
		if(!isValidFullName(fullName)){
			throw new IllegalArgumentException("The string \""+fullName+"\" is not a valid full name for a"+
					" relation because it contains tab characters or is blank.");
		}
		if(!isValidShortName(shortName)){
			throw new IllegalArgumentException("The string \""+shortName+"\" is not a valid short name for a"+
					" relation because it is blank or contains characters other than letters, numbers and _.");
		}
		this.fullName = fullName;
		this.shortName = shortName;
		this.id = id;
	}
	
	/**
	 * <p>Return an instance composed of numSamples independent, identically
	 * distributed samples from the points in this relation.</p><p>
	 *
	 *  <p>Copy the following exemplars into implementations:</p><pre><code>
	 * 	@Exemplars(set={
	 *	@Exemplar(args={"null","1"}, ee="NullPointerException"),
	 *	@Exemplar(args={"new Random(1l)","0"}, expect={"Instance","=(retval.getNumSamples(),0)"})
	 *	})
	 *	</pre></code>
	 * 
	 * @param rng
	 *            The random number generator used in creating the sample. Cannot be null.
	 * @param numSamples
	 *            The number of samples in the list that will be returned. Cannot be negative.
	 * @return an Instance composed of numSamples independent, identically
	 *         distributed samples from the points in this relation.
	 */
	public abstract Instance samples(Random rng, int numSamples);
}
