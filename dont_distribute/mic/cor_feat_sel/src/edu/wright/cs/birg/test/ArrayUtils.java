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
	 * Return a string representation of an array suitable for Sureassert test code.</p><p>
	 * 
	 * Returns a representation of a that when interpreted by the SIN interpreter for an @@Exemplar
	 * annotation, will produce the input array.</p><p>
	 * 
	 * The array cannot be empty.
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

	/**
	 * Return a string representation of an 2D array suitable for Sureassert test code.</p><p>
	 * 
	 * Returns a representation of a that when interpreted by the SIN interpreter for an @@Exemplar
	 * annotation, will produce the input array.</p><p>
	 * 
	 * Neither the array nor any of its component arrays can be empty. 
	 * 
	 * @param a the array to be represented as a Sureassert UC string.  May be null, but must not be empty 
	 * (Sureassert has no way to represent empty arrays.)
	 * @return a string representation of an array suitable for Sureassert test code.
	 */
	@Exemplars(set={
	@Exemplar(args={"null"}, expect="+('nul','l')"), //Note the Sureassert workaround
	@Exemplar(a={"empty([pa:1.0])"},ee="IllegalArgumentException",e="retval.getMessage().contains('empty')"),
	@Exemplar(a={"[a:[pa:1.0]]"}, expect="'[a:[pa:1.0]]'"),
	@Exemplar(a={"[a:[pa:1.0,2.5555557]]"}, expect="'[a:[pa:1.0,2.5555557]]'"), 
	@Exemplar(a={"[a:[pa:3.1415],[pa:0.0]]"}, expect="'[a:[pa:3.1415],[pa:0.0]]'"),
	@Exemplar(a={"[a:[pa:1.0,2.5555557],[pa:-0.1]]"}, expect="'[a:[pa:1.0,2.5555557],[pa:-0.1]]'"), 
	})
	public static String exemplarString(double[][] a){
		if(a == null){ return "null"; }
		if(a.length == 0){
			throw new IllegalArgumentException("Sureassert has no way of representing empty arrays");
		}
		StringBuilder b = new StringBuilder("[a:");
		for(int i = 0; i < a.length; ++i){
			if(i > 0){ 
				b.append(','); }
			b.append(exemplarString(a[i]));
		}
		b.append(']');
		return b.toString();
	}
	
	/**
	 * Return a string representation of an array suitable for Sureassert test code, surrounded by quotes.</p><p>
	 * 
	 * Returns the exact same thing as exemplarString(double[]) except surrounded by  
	 * double quotes. This makes it ideal for including in strings that will later become @Exemplar 
	 * instances themselves.</p><p>
	 * 
	 * For example: </p><p>
	 * 
	 * <tt>String s="a={"+qExemplar(foo)+","+qExemplar(bar)+"}"; </tt></p><p>
	 * 
	 * @param a the array to be represented as a Sureassert UC string.  May be null, but must not be empty 
	 * (Sureassert has no way to represent empty arrays.)
	 * @return a string representation of an array suitable for Sureassert test code.
	 * @see #exemplarString(double[])
	 */
	@Exemplars(set={
	@Exemplar(args={"null"}, expect="+('\"nul','l\"')"), //Note the Sureassert workaround
	@Exemplar(a={"emptyDouble()"},ee="IllegalArgumentException",e="retval.getMessage().contains('empty')"),
	@Exemplar(a={"[pa:1.0]"}, expect="'\"[pa:1.0]\"'"),
	@Exemplar(a={"[pa:1.0,2.5555557]"}, expect="'\"[pa:1.0,2.5555557]\"'"), 
	})	
	public static String qExemplar(double[] a){
		return "\""+exemplarString(a)+"\"";
	}

	/**
	 * Return a string representation of an 2D array suitable for Sureassert test code.</p><p>
	 * 
	 * Returns a representation of a that when interpreted by the SIN interpreter for an @@Exemplar
	 * annotation, will produce the input array.</p><p>
	 * 
	 * Neither the array nor any of its component arrays can be empty. 
	 * 
	 * @param a the array to be represented as a Sureassert UC string.  May be null, but must not be empty 
	 * (Sureassert has no way to represent empty arrays.)
	 * @return a string representation of an array suitable for Sureassert test code.
	 */
	@Exemplars(set={
	@Exemplar(args={"null"}, expect="+('\"nul','l\"')"), //Note the Sureassert workaround
	@Exemplar(a={"empty([pa:1.0])"},ee="IllegalArgumentException",e="retval.getMessage().contains('empty')"),
	@Exemplar(a={"[a:[pa:1.0]]"}, expect="'\"[a:[pa:1.0]]\"'"),
	@Exemplar(a={"[a:[pa:1.0,2.5555557]]"}, expect="'\"[a:[pa:1.0,2.5555557]]\"'"), 
	@Exemplar(a={"[a:[pa:3.1415],[pa:0.0]]"}, expect="'\"[a:[pa:3.1415],[pa:0.0]]\"'"),
	@Exemplar(a={"[a:[pa:1.0,2.5555557],[pa:-0.1]]"}, expect="'\"[a:[pa:1.0,2.5555557],[pa:-0.1]]\"'"), 
	})
	public static String qExemplar(double[][] a){
		return "\""+exemplarString(a)+"\"";
	}
	
	/**
	 * Return true if and only if a is a matrix. a is a matrix if and only if a is not null and all of the 
	 * rows have the same number of columns
	 * @param a 2D array of double (or null)
	 * @return true if and only if a is a matrix.
	 */
	@Exemplars(set={
	@Exemplar(args={"null"}, expect="false"),
	@Exemplar(args={"empty([pa:1.0])"}, expect="true"),
	@Exemplar(args={"[a:[pa:1.0]]"}, expect="true"),
	@Exemplar(args={"[a:[pa:1.0],[pa:2.0]]"}, expect="true"),
	@Exemplar(args={"[a:[pa:1.0,2.0]]"}, expect="true"),
	@Exemplar(args={"[a:[pa:1.0,2.0],[pa:2.0]]"}, expect="false"),
	@Exemplar(args={"[a:[pa:2.0],[pa:1.0,2.0]]"}, expect="false"),
	@Exemplar(args={"[a:[pa:2.0],null]"}, expect="false"),
	@Exemplar(args={"[a:null,[pa:2.0]]"}, expect="false"),
	@Exemplar(args={"[a:[pa:1.0,2.0],[pa:1.0,1.0]]"}, expect="true"),
	})
	public static boolean isMatrix(double[][] a){
		if(a == null){ 
			return false;
		}else if (a.length == 0){
			return true;
		}else{
			if(a[0] == null){ 
				return false; 
			}
			int len = a[0].length;
			for(int i = 0; i < a.length; ++i){
				if(a[i] == null){ 
					return false;
				}else if(a[i].length != len){ 
					return false;
				}else{
					//Do nothing
				}
			}
			return true;
		}
	}

}
