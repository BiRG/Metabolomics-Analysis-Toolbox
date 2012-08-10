/**
 * 
 */
package edu.wright.cs.birg.feature_selection.correlation;

import java.io.IOException;
import java.io.ObjectOutputStream;

import edu.wright.cs.birg.variable_dependence.MaximalInformationCoefficientMeasure;
import edu.wright.cs.birg.variable_dependence.PearsonCorrelationMeasure;
import edu.wright.cs.birg.variable_dependence.SymmetricDependenceMeasure;
import edu.wright.cs.birg.variable_dependence.Variable;

/**
 * Calculate the dependences between variables read from a CSV on stdin
 * @author Eric Moyer
 *
 */
public class DependenceCalculationOperation extends Operation {
	/**
	 * The measure used in calculating the dependence
	 */
	private SymmetricDependenceMeasure measure;
	
	/**
	 * Parses the command line arguments args to create a DependenceCalculationOperation.
	 * Exits the JVM if args is incorrect syntax.
	 * @param args The command line arguments passed to this operation
	 */
	public DependenceCalculationOperation(String[] args) {
		if(args.length != 1){
			printUsage("Error: The dependence calculation operation takes exactly 1 argument, the dependence calculation method.");
			System.exit(-1); return;
		}
		if("mic".equals(args[0])){
			measure = new MaximalInformationCoefficientMeasure();
		}else if("pearson".equals(args[0])){
			measure = new PearsonCorrelationMeasure();
		}else{
			printUsage("Error: unknown dependence measure \""+args[0]+"\" valid measures are pearson and mic");
			System.exit(-1); return;
		}
	}

	/* (non-Javadoc)
	 * @see java.lang.Runnable#run()
	 */
	@Override
	public void run() {
		//Read in the variables
		Variable[] vars = readVariables(stdinAsCSV());

		//Create the dependences structure from the variables
		Dependences deps = new Dependences(vars, measure);
		
		//Write the dependences to stdout
		try{
			ObjectOutputStream out = new ObjectOutputStream(System.out);
			out.writeObject(deps);
			out.close();
		}catch (IOException e){
			System.err.println("Error: writing dependences to stdout");
			System.exit(-1); return;
		}
	}

}
