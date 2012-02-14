/**
 * 
 */
package edu.wright.cs.birg.exactmic;

import java.text.MessageFormat;

import choco.Choco;
import choco.cp.model.CPModel;
import choco.cp.solver.CPSolver;
import choco.kernel.model.variables.integer.IntegerVariable;

/**
 * @author eric
 *
 */
public class ExactMIC {

	/**
	 * @param args The command line arguments
	 */
	public static void main(String[] args) {
		// To start with, I 'll do the magic square exercise from the documentation
		
		// Constant declarations
		final int n = 4; // Order of the magic square
		final int magicSum = n * (n * n + 1) / 2; // Magic sum
		

		// Define the variables
		IntegerVariable[][] cells=new IntegerVariable[n][n];
		for(int i=0; i <n; ++i){
			for(int j=0; j < n; ++j){
				cells[i][j]=Choco.makeIntVar("cell["+i+"]["+j+"]", 1, n*n);
			}
		}

		// Add the variables to the model
		CPModel m=new CPModel();
		for(IntegerVariable[] cellRow:cells){
			for(IntegerVariable cell:cellRow){
				m.addVariable(cell);
			}
		}
		
		// Add the all different constraint (pairwise for all pairs)
		for(int i1=0; i1 <n; ++i1){
			for(int j1=0; j1 < n; ++j1){
				for(int i2=0; i2 <n; ++i2){
					for(int j2=0; j2 < n; ++j2){
						if(!(j2==j1 && i2 == i1){
							m.addConstraint(Choco.neq(cells[i1][j1], cells[i2][j2]));
						}
					}
				}
			}
		}
		
		

		// Add the row sum constraint
		for(IntegerVariable[] cellRow:cells){
			m.addConstraint(Choco.eq(Choco.sum(cellRow), magicSum));
		}
		
		// Add the column sum constraint
		for(int c=0; c < n; ++c){
			IntegerVariable[] col = new IntegerVariable[n];
			for(int r=0; r <n; ++r){
				col[r]=cells[r][c];
			}
			m.addConstraint(Choco.eq(Choco.sum(col),magicSum));
		}
		
		// Add the diagonal constraints
		IntegerVariable[] diag = new IntegerVariable[n];
		for(int i=0; i < n; ++i){
			diag[i]=cells[i][i];
		}
		m.addConstraint(Choco.eq(Choco.sum(diag),magicSum));
		
		for(int i=0; i < n; ++i){
			diag[i]=cells[i][n-1-i];
		}
		m.addConstraint(Choco.eq(Choco.sum(diag),magicSum));
		
		//Read and solve the model
		CPSolver s = new CPSolver();
		s.read(m);
		s.solve();
		
		// Print the solution
		for (int i = 0; i < n; i++) {
			for (int j = 0; j < n; j++) {
				System.out.print(MessageFormat.format("{0} ", s.getVar(cells[i][j]).getVal()));
			}
			System.out.println();
		}
		
	}

}
