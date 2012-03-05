package edu.wright.cs.birg.variable_dependence;

import org.sureassert.uc.annotation.Exemplar;
import org.sureassert.uc.annotation.Exemplars;

/**
 * A variable read from the input file with all of its data.
 * @author Eric Moyer
 *
 */
public class Variable{
	/**
	 * The name given to this variable in the header
	 */
	private String name;
	
	/**
	 * data[i] is the value of this variable in the i'th sample
	 */
	private double[] data;
	
	/**
	 * The zero-based index of this variable in the input file
	 */
	private int index;

	/**
	 * Return the name field of this CorrelationBasedFeatureSelection.Variable
	 * @return the name field
	 */
	@Exemplar(i="MyVar1_0",e={"=(retval, 'MyVar')"})
	public String getName() {
		return name;
	}

	/**
	 * Return the data field of this CorrelationBasedFeatureSelection.Variable
	 * @return the data field
	 */
	@Exemplar(i="MyVar1_0",e={"=(ArrayUtils.len(retval),1)"})
	public double[] getData() {
		return data;
	}

	/**
	 * Return the index field of this CorrelationBasedFeatureSelection.Variable
	 * @return the index field
	 */
	@Exemplar(i="MyVar1_0",e="0")
	public int getIndex() {
		return index;
	}
	
	/**
	 * Create a variable with the given name, data, and original index
	 * @param name The name of the Variable in the original file.  Cannot be null.
	 * @param data The data for this variable in the original file.  data[i] is the value assigned 
	 *             to this data item in the i-th sample.  Cannot be null.
	 * @param index The zero-based index of the variable in the original file. Must be 0 or greater.
	 */
	@Exemplars(set={
	@Exemplar(args={"null","null","0"}, ee="NullPointerException", expect={"retval.getMessage().contains('name field')"}),
	@Exemplar(args={"'My variable'","null","0"}, ee="NullPointerException", expect={"retval.getMessage().contains('data field')"}), 
	@Exemplar(args={"'My variable'","[pa:1.0]","-1"}, ee="IllegalArgumentException", expect={"retval.getMessage().contains('non-negative')"}), 
	@Exemplar(name="MyVar1_0",args={"'MyVar'","[pa:1.0]","0"}, 
		expect={"=(ArrayUtils.len(retval.data),1)","=(retval.name,'MyVar')","=(retval.index,0)"}), 
	})
	public Variable(String name, double[] data, int index){
		if(name == null){
			throw new NullPointerException("The name field of a Variable cannot be null");
		}
		if(data == null){
			throw new NullPointerException("The data field of a Variable cannot be null");
		}
		if(index < 0){
			throw new IllegalArgumentException("The index of a variable must be a non-negative number");
		}
		this.name = name; this.data = data; this.index = index;
	}
}