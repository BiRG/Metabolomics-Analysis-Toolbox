/**
 * 
 */
package edu.wright.cs.birg.variable_dependence;

/**
 * Same as the dependence measure, but now guarantees that dependence(x,y) == dependence(y,x)
 * @author Eric Moyer
 *
 */
public interface SymmetricDependenceMeasure extends DependenceMeasure {

}
