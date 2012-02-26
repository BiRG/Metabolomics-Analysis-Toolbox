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
	 * Return the length of an array. Work-around for SecureAssert's having trouble with  
	 * the length field of primitive arrays.
	 * @param a The array whose length will be returned. If it is null, throws NullPointerException
	 * @return Return the length of an array.
	 */
	@Exemplars(set={
	@Exemplar(args={"null"}, ee="NullPointerException"),
	@Exemplar(args={"[pa:1.0]"}, e="1"),
	@Exemplar(args={"[pa: 1.0,2.0]"}, expect="2")
	})
	public static int len(double[] a){ 
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

	/**
	 * Return an empty array of double
	 * @return an empty array of double
	 */
	@Exemplar(expect="=(len(retval),0)")
	public static double[] emptyDouble(){
		return new double[0];
	}
	
	/**
	 * Return a string representation of an array suitable for Sureassert test code.
	 * 
	 * Returns a representation of a that when interpreted by the SIN interpreter for an @@Exemplar
	 * annotation, will produce the input array.
	 * 
	 * 
	 * @param a the array to be represented as a Sureassert UC string.  May be null, but must not be empty 
	 * (Sureassert has no way to represent empty arrays.)
	 * @return a string representation of an array suitable for Sureassert test code.
	 */
	@Exemplars(set={
	@Exemplar(args={"null"}, expect="+('nul','l')"), //Note the Sureassert workaround
	@Exemplar(a={"emptyDouble()"},ee="IllegalArgumentException",e="retval.getMessage().contains('empty')"),
	@Exemplar(a={"[pa:1.0]"}, expect="'[pa:1.0]'"),
	@Exemplar(a={"[pa:1.0,2.5555557]"}, expect="'[pa:1.0,2.5555557]'"), 
	})
	public static String exemplarString(double[] a){
		if(a == null){ return "null"; }
		if(a.length == 0){
			throw new IllegalArgumentException("Sureassert has no way of representing empty primitive arrays");
		}
		StringBuilder b = new StringBuilder("[pa:");
		for(int i = 0; i < a.length; ++i){
			if(i > 0){ 
				b.append(','); }
			b.append(a[i]);
		}
		b.append(']');
		return b.toString();
	}
	
}
