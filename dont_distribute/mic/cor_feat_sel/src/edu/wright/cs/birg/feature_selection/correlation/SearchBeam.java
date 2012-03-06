/**
 * 
 */
package edu.wright.cs.birg.feature_selection.correlation;

import java.util.Collection;
import java.util.Comparator;
import java.util.Iterator;
import java.util.TreeSet;

/**
 * The beam for a beam search. Very like a set, but it has a maximum size. To add an element when there
 * are maxSize elements in the SearchBeam, the element is added as usual, but then the last element in
 * the beam is deleted. Thus the comparator should rank elements by "cost" with the lowest cost being 
 * the best element.
 * @author Eric Moyer
 *
 */
public class SearchBeam<E> implements Collection<E>, Iterable<E>{
	/**
	 * The maximum number of elements that can be in this beam
	 */
	private int maxSize;
	
	/**
	 * The underlying set containing the elements in the beam
	 */
	private TreeSet<E> set;
	
	/**
	 * Return a new SearchBeam with the same maximum size in which all of the elements are the same objects as this one.
	 * Adding an element to the new beam will not affect this beam  
	 * @return a new SearchBeam with the same maximum size in which all of the elements are the same objects as this one.
	 */
	public SearchBeam<E> shallowCopy(){
		TreeSet<E> s = new TreeSet<E>(set.comparator());
		s.addAll(set);
		SearchBeam<E> out = new SearchBeam<E>(maxSize, s);
		return out;
	}
	
	/**
	 * Create a SearchBeam with its fields initialized to the parameters to this method. Used for implementing
	 * shallowCopy
	 * @param maxSize The maxSize of the new SearchBeam
	 * @param set The underlying set for the new SearchBeam
	 */
	private SearchBeam(int maxSize, TreeSet<E> set){
		this.maxSize = maxSize; this.set = set;
	}
	
	
	/**
	 * Create an empty SearchBeam limited to containing maxSize elements which uses the comparator to order its elements.
	 * @param maxSize The maximum number of elements that can be in the beam 
	 * @param comparator Orders elements by cost. "smaller" elements by this comparator are better.
	 */
	public SearchBeam(int maxSize, Comparator<? super E> comparator){
		this.maxSize = maxSize;
		set = new TreeSet<E>(comparator);
	}
	
	/**
	 * Return the number of elements in this beam.
	 * @return the number of elements in this beam.
	 */
	public int size() {	return set.size();	}

	/**
	 * Attempt to add e to the beam. If after adding, the beam is too large, the worst element in the beam
	 * is removed.  That element may be e.
	 * @param e The element to attempt to add.
	 * @return true if e was not already present in the beam
	 */
	public boolean add(E e) {
		if(set.add(e)){
			if(size() > maxSize){
				remove(worst());
				assert(size() <= maxSize);
			}
			return true;
		}else{
			return false;
		}
	}
	/**
	 * Attempts to add all of the elements in the specified collection to this beam. 
	 * @param c the collection to add
	 * @return true if some elements were not already in the beam
	 */
	public boolean addAll(Collection<? extends E> c){
		boolean ret = false;
		for(E e:c){
			ret = add(e) || ret;
		}
		return ret;
	}
	

	/**
	 * Remove all elements from this beam
	 */
	public void clear() { set.clear(); }

	/**
	 * Return the best element in the beam
	 * @return the best element in the beam
	 */
	public E best() { return set.first(); }

	/**
	 * Return the worst element in the beam
	 * @return the worst element in the beam
	 */
	public E worst() { return set.last(); }

	@Override
	public boolean remove(Object e) { return set.remove(e); }

	@Override
	public Iterator<E> iterator() {	return set.iterator();	}

	@Override
	public boolean isEmpty() {	return set.isEmpty();	}

	@Override
	public boolean contains(Object o) {	return set.contains(o);	}

	@Override
	public Object[] toArray() {	return set.toArray(); }

	@Override
	public <T> T[] toArray(T[] a) { return set.toArray(a); }

	@Override
	public boolean containsAll(Collection<?> c) { return set.containsAll(c); }

	@Override
	public boolean removeAll(Collection<?> c) { return set.removeAll(c); }

	@Override
	public boolean retainAll(Collection<?> c) { return set.retainAll(c); }
	
	@Override
	public String toString(){
		return "SearchBeam["+maxSize+","+set+"]";
	}
}
