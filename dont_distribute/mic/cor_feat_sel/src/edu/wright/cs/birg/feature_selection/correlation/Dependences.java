package edu.wright.cs.birg.feature_selection.correlation;

import java.io.Serializable;

import edu.wright.cs.birg.status.Status;
import edu.wright.cs.birg.variable_dependence.SymmetricDependenceMeasure;
import edu.wright.cs.birg.variable_dependence.Variable;

/**
 * The dependences among some variables, one of which is designated the class. 
 * @author Eric Moyer
 *
 */
class Dependences implements Serializable{
	/**
	 * Version id - must be changed when incompatible changes are made to the class 
	 */
	private static final long serialVersionUID = 2L;

	/**
	 * dep[i][j] is the degree of dependence between feature index i and feature index j
	 */
	private double[][] dep;
	
	/**
	 * name[i] is the name of feature i
	 */
	private String[] name;
	
	/**
	 * index[i] is the index attribute (an id) for feature i
	 */
	private int[] index;
	
	/**
	 * Calculate the dependences between vars using measure 
	 * @param vars The variables whose dependences are calculated 
	 * @param measure The dependence measure to use
	 */
	public Dependences(Variable[] vars, SymmetricDependenceMeasure measure) {
		int num = vars.length;

		//Preserve the variables' metadata
		name = new String[num];
		index = new int[num];
		for(int i = 0; i < num; ++i){
			name[i] = vars[i].getName();
			index[i] = vars[i].getIndex();
		}
		
		//Calculate the dependences
		dep = new double[num][num];
		int stepsCompleted = 0;
		for(int f1 = 0; f1 < num; ++f1){
			Variable v1 = vars[f1];
			System.err.print(" "+v1.getIndex());
			for(int f2 = 0; f2 <= f1; ++f2){
				Variable v2 = vars[f2];
				dep[f2][f1]=dep[f1][f2]=measure.dependence(v1, v2);
				++stepsCompleted;
				Status.update("Calculating dependences", num*(num+1)/2, stepsCompleted, 
						"Method:",measure.name(), "Features: (", f1, ",", f2,")");
			}
		}
	}
	
	/**
	 * Return the name for feature i
	 * @param i the number of the feature whose name is returned
	 * @return the name for feature i
	 * @throws ArrayIndexOutOfBoundsException when i is not a valid feature number
	 */
	public String getName(int i) throws ArrayIndexOutOfBoundsException{
		return name[i];
	}

	/**
	 * Return the original index for feature i
	 * @param i the number of the feature whose original index is returned
	 * @return the original index for feature i
	 * @throws ArrayIndexOutOfBoundsException when i is not a valid feature number
	 */
	public int getOriginalIndex(int i) throws ArrayIndexOutOfBoundsException{
		return index[i];
	}

	/**
	 * Return the dependence of feature j upon feature i
	 * @param i the number of the first feature in the pair whose dependence is returned
	 * @param j the number of the first feature in the pair whose dependence is returned
	 * @return the dependence of feature j upon feature i
	 * @throws ArrayIndexOutOfBoundsException when i or j is not a valid feature number
	 */
	public double getDep(int i, int j) throws ArrayIndexOutOfBoundsException{
		return dep[i][j];
	}
	

	/**
	 * Return the number of features whose mutual dependence strengths are calculated 
	 * @return the number of features whose mutual dependence strengths are calculated
	 */
	public int getNumFeatures(){ return name.length; }
}