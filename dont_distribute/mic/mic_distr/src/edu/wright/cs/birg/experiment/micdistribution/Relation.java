/**
 * 
 */
package edu.wright.cs.birg.experiment.micdistribution;

import java.util.Arrays;
import java.util.List;
import java.util.Random;

/**
 * A relation between two variables on the unit square from which samples can be
 * taken. Since this is the only type of relation one cares about in calculating
 * the distribution of MICs, it gets the simple name of Relation.
 * 
 * @author Eric Moyer
 */
public abstract class Relation {
	/**
	 * The full, human readable name of this Relation. Should not have tabs.
	 */
	private final String fullName;
	
	/**
	 * The id of this relation. Any two relation objects with the same ID must
	 * have identical behavior.
	 */
	private final int id;
	
	/**
	 * The short, safe name of the relation. May only consist of letters,
	 * numbers, and _. Two objects have the same shortName if and only if they
	 * have the same id.
	 */
	private final String shortName;
	
	/**
	 * Return true iff s is a valid full name for a relation, that is, it does
	 * not have tab characters.
	 * 
	 * @param s
	 *            The string to be tested.
	 * @return true iff s is a valid full name for a relation, that is, it does
	 *         not have tab characters.
	 */
	private static boolean isValidFullName(String s){
		return !s.contains("\t");
	}
	
	/**
	 * Return true iff s is a valid short name for a relation, that is, it
	 * contains only _ and alphanumeric characters.
	 * 
	 * @param s
	 *            The string to be tested.
	 * @return true iff s is a valid short name for a relation, that is, it
	 *         contains only _ and alphanumeric characters.
	 */
	private static boolean isValidShortName(String shortName2) {
		// TODO Auto-generated method stub
		return false;
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
					" relation because it contains tab characters.");
		}
		if(!isValidShortName(shortName)){
			throw new IllegalArgumentException("The string \""+shortName+"\" is not a valid short name for a"+
					" relation because it contains characters other than letters, numbers and _.");
		}
		this.fullName = fullName;
		this.shortName = shortName;
		this.id = id;
	}
	
	/**
	 * Return a sample from the points in this relation
	 * 
	 * @param rng
	 *            The random number generator used in creating the sample
	 * @return a sample from the points in this relation
	 */
	public abstract Sample sample(Random rng);

	/**
	 * Return a list of numSamples independent, identically distributed samples
	 * from the points in this relation. Should return a list distributed the
	 * same way one would get by calling sample(rng) numSamples times. Does not
	 * have to be implemented that way, however (though the default implementation is).
	 * 
	 * @param rng
	 *            The random number generator used in creating the sample
	 * @param numSamples
	 *            The number of samples in the list that will be returned
	 * @return a list of numSamples independent, identically distributed samples
	 *         from the points in this relation.
	 */	
	public List<Sample> samples(Random rng, int numSamples){
		Sample[] samps = new Sample[numSamples];
		for(int i = 0; i < samps.length; ++i){
			samps[i]=this.sample(rng);
		}
		return Arrays.asList(samps);
	}
}
