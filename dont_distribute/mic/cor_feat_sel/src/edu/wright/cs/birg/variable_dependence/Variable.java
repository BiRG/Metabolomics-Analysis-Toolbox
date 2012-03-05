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
	@Exemplar(name="Empty",args={"'Empty'","ArrayUtils.emptyDouble()","1"}, 
	expect={"=(ArrayUtils.len(retval.data),0)","=(retval.name,'Empty')","=(retval.index,1)"}), 
	@Exemplar(name="OneTwo",args={"'OneAndTwo'","[pa:1.0,2.0]","5"}, 
	expect={"=(ArrayUtils.len(retval.data),2)","=(retval.name,'OneAndTwo')","=(retval.index,5)"}), 
	@Exemplar(name="TwentyInLine",args={"'TwentyInLine'","[pa:1.0,2.0,3.0,4.0,5.0,6.0,7.0,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0,16.0,17.0,18.0,19.0,20.0]","20"}, 
	expect={"=(ArrayUtils.len(retval.data),20)","=(retval.name,'TwentyInLine')","=(retval.index,20)"}), 
	@Exemplar(name="TwentySquares",args={"'TwentySquares'","[pa:1.0,4.0,9.0,16.0,25.0,36.0,49.0,64.0,81.0,100.0,121.0,144.0,169.0,196.0,225.0,256.0,289.0,324.0,361.0,400.0]","21"}, 
	expect={"=(ArrayUtils.len(retval.data),20)","=(retval.name,'TwentySquares')","=(retval.index,21)"}), 
	@Exemplar(name="UShape",args={"'UShape'","[pa:81.0,64.0,49.0,36.0,25.0,16.0,9.0,4.0,1.0,0.0,0.0,1.0,4.0,9.0,16.0,25.0,36.0,49.0,64.0,81.0]","22"}, 
	expect={"=(ArrayUtils.len(retval.data),20)","=(retval.name,'UShape')","=(retval.index,22)"}), 
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