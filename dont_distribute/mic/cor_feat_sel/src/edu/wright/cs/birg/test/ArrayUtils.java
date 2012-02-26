/**
 * 
 */
package edu.wright.cs.birg.test;

import org.sureassert.uc.annotation.Exemplar;
import org.sureassert.uc.annotation.Exemplars;

/**
 * Static methods for dealing with arrays in a testing context
 * @author Eric Moyer
 *
 */
public final class ArrayUtils {
	/**
	 * Return the length of an array. Work-around for SecureAssert's having trouble with  
	 * the length field of primitive arrays.
	 * @param a The array whose length will be returned. If it is null, throws NullPointerException
	 * @return Return the length of an array.
	 */
	
	@Exemplars(set={
	@Exemplar(args={"null"}, ee="NullPointerException"),
	@Exemplar(args={"[a:'str']"}, e="1"),
	@Exemplar(args={"[a: 's1','s2']"}, expect="2")
	})
	public static int len(Object[] a){ 
		return a.length; 
	}
	
	/**
	 * Return an empty array of the given type
	 * @param a an object of the given type
	 * @return an empty array of the given type
	 */
	@Exemplar(args={"'foo'"}, expect="=(len(retval),0)")
	public static <E> E[] empty(E a){
		@SuppressWarnings("unchecked")
		E[] out = (E[]) java.lang.reflect.Array.newInstance(a.getClass(), 0);
		return out;
	}
}
