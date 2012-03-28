/**
 * 
 */
package edu.wright.cs.birg.experiment.micdistribution;

import java.io.Serializable;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.NoSuchElementException;

/**
 * The database recording the dependence measure experiment
 * 
 * @author Eric Moyer
 * 
 */
public final class Database implements Serializable, Iterable<DataPoint>{
	/**
	 * The version ID: if it is the same then the class can be deserialized 
	 */
	private static final long serialVersionUID = 1L;
	
	/**
	 * The experimental instances in this database 
	 */
	private List<DBInstance> instances;
	
	/**
	 * Create an empty database
	 */
	public Database(){
		this.instances = new LinkedList<DBInstance>();
	}

	/**
	 * Add an instance record to the database
	 * @param inst the instance record to add 
	 */
	public void add(DBInstance inst){
		instances.add(inst);
	}
	
	/**
	 * Return the instances field of this Database
	 * @return the instances field of this Database
	 */
	public List<DBInstance> getInstances() {
		return instances;
	}
	
	/**
	 * Remove all the instances from db and add them to the end of this Database
	 * @param db the database to splice onto this one
	 */
	public void splice(Database db){
		while(db.instances.size() > 0){
			add(db.instances.remove(0));
		}
	}
	
	/**
	 * Return true if and only if there are no instances in this
	 * <code>Database</code>
	 * 
	 * @return true if and only if there are no instances in this
	 *         <code>Database</code>
	 */
	public boolean isEmpty(){
		return instances.isEmpty();
	}
	
	/**
	 * Removes and returns the first instance in the database. If the database is empty, returns null.
	 * @return the first instance or null if there are no instances.
	 */
	public DBInstance popInstance(){
		if(isEmpty()){
			return null;
		}else{
			return instances.remove(0);
		}
	}
	
	/**
	 * Return a read-only iterator that iterates over the contents of this database viewed as DataPoint objects
	 * @return a read-only iterator that iterates over the contents of this database viewed as DataPoint objects
	 */
	public Iterator<DataPoint> iterator(){
		return this.new DataPointIterator();
	}
	
	/**
	 * Return the number of {@link DataPoint} objects in this database
	 * @return the number of <code>DataPoint</code> objects in this database
	 */
	public int getNumDatapoints(){
		int sum = 0;
		for(DBInstance inst:instances){
			sum += inst.getNumDatapoints();
		}
		return sum;
	}
	
	/**
	 * A read-only iterator that iterates through its enclosing Database as sequence of DataPoint 
	 * 
	 * @author Eric Moyer
	 *
	 */
	private class DataPointIterator implements Iterator<DataPoint>{
		/**
		 * The underlying iterator for updating the current instance
		 */
		Iterator<DBInstance> iter;
		
		/**
		 * The index of in the list of indices of the instance pointed to by cur
		 */
		int instanceID;
		
		/**
		 * The index of the next dependence method in the current instance 
		 */
		int dependenceIndex;
		
		/**
		 * The current instance
		 */
		DBInstance cur;
		
		DataPointIterator(){
			iter = instances.iterator();
			if(iter.hasNext()){
				cur = iter.next();
			}else{
				cur = null;
			}
			dependenceIndex = 0;
			instanceID = 0;
		}
		
		@Override
		public boolean hasNext() {
			return iter.hasNext() || (cur != null && dependenceIndex < cur.getNumDependenceMeasures()); 
		}

		@Override
		public DataPoint next() {
			if(!hasNext()){
				throw new NoSuchElementException("Attempt to iterate past the end of a Database");
			}
			//Go to the next instance if we've run out of dependence measures in the current one
			if(dependenceIndex >= cur.getNumDependenceMeasures()){
				dependenceIndex = 0;
				cur = iter.next();
				++instanceID;
			}
			DataPoint dp = new DataPoint(instanceID, cur.relationID, 
					cur.xNoiseStandardDeviation, cur.yNoiseStandardDeviation, cur.numSamples, 
					cur.dependenceMeasureIds[dependenceIndex], 
					cur.dependences[dependenceIndex]);
			++dependenceIndex;
			return dp;
		}

		@Override
		public void remove() {
			throw new UnsupportedOperationException("DataPointIterator objects can't remove their underlying points.");
		}
		
	}
}
