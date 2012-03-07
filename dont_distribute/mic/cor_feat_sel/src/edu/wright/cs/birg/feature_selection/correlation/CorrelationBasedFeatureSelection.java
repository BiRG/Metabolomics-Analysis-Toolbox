/**
 * 
 */
package edu.wright.cs.birg.feature_selection.correlation;

import java.util.Arrays;

import org.sureassert.uc.annotation.Exemplars;
import org.sureassert.uc.annotation.Exemplar;


/**
 * @author Eric Moyer
 *
 */
public class CorrelationBasedFeatureSelection {

	/**
	 * Print the usage message followed by msg on its own line. If msg is null, it is not printed, 
	 * but the usage is still printed.
	 * @param msg The message to print after the usage message. not printed if null.
	 */	
	@Exemplars(set={
	@Exemplar(args={"'foo'"}, expect=""),
	@Exemplar(args={"null"}, expect=""), 
	})
	public static void printUsage(String msg){
		System.err.println("Usage: java -jar cbfs.jar -dependences method < input_data.csv > dependences.ser");		
		System.err.println(" or:   java -jar cbfs.jar -features labelIndex -bestFirst numFailures < dependences.ser > features.txt");
		System.err.println(" or:   java -jar cbfs.jar -features labelIndex -beam numFailures beamSize < dependences.ser > features.txt");
		System.err.println(" or:   java -jar cbfs.jar -maxBeamSize < dependences.ser > maxBeamSize.txt");		
		System.err.println(" or:   java -jar cbfs.jar -testData < input_data.csv > test_data.txt");
		System.err.println("");
		System.err.println("-dependences reads in a csv and ouputs the dependences between the ");
		System.err.println("                 different attributes to a binary file.");
		System.err.println("");
		System.err.println("-features: reads in a binary file giving the dependences between ");
		System.err.println("              attributes. writes the selected list of features to ");
		System.err.println("              stdout: 1 per line.");
		System.err.println("");
		System.err.println("-testData: reads in a csv. Then prints test lines to stdout.");
		System.err.println("");
		System.err.println("-maxBeamSize: reads in the dependences and outputs a number that is the ");
		System.err.println("              beam size one lower than one which causes an out of memory exception");
		System.err.println("              Divide this by 3 to get a guess for the largest beam one can");
		System.err.println("              use in \"-features ... beam\" without running out of memory.");
		System.err.println("");
		System.err.println("-beam: an argument to -features that generates the features using a beam ");
		System.err.println("       search that terminates when numFailures expansions have failed to ");
		System.err.println("       improve the best item in the beam");
		System.err.println("");
		System.err.println("method: the method used to calculate the dependence between features.");
		System.err.println("        it can be one of: mic, pearson");
		System.err.println("");
		System.err.println("labelIndex: the column index of the class feature. First column is 0.");
		System.err.println("");
		System.err.println("input_data.csv the columns of the csv are features and the rows are samples.");
		System.err.println("");
		System.err.println("The first line of the csv may be a header (if it is, it must ");
		System.err.println("contain a letter).  All other lines must be the same length and must ");
		System.err.println("have the decimal representation of a real number. The columns of the ");
		System.err.println("csv are features and the rows are samples.");
		if(msg != null){
			System.err.println("");			
			System.err.println(msg);
		}
	}

	/**
	 * @param args name of input file or (if empty) reads from stdin
	 * 
	 */
	public static void main(String[] args) {
		if(args.length < 1){
			printUsage("ERROR: Wrong number of arguments - missing main operation argument");
			return;
		}
		Operation operation;
		String[] restOfArgs = Arrays.copyOfRange(args, Math.min(1, args.length), args.length);
		if("testData".equals(args[0])){
			operation = new TestDataOperation(restOfArgs);			
		}else if("features".equals(args[0])){
			operation = new FeatureSelectionOperation(restOfArgs);
		}else if("dependences".equals(args[0])){
			operation = new DependenceCalculationOperation(restOfArgs);
		}else if("maxBeamSize".equals(args[0])){
			operation = new MaxBeamSizeOperation(restOfArgs);
		}else{
			printUsage("ERROR: Unknown operation \""+args[0]+"\"");
			return;
		}
		operation.run();
	}
	

}
