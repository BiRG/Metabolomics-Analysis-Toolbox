/**
 * 
 */
package edu.wright.cs.birg.experiment.micdistribution;

import java.io.PrintStream;
import java.util.Arrays;

/**
 * @author Eric Moyer
 *
 */
public final class MICDistributionCalculator {
	/**
	 * Print the usage message followed by msg on its own line. If msg is null, it is not printed, 
	 * but the usage is still printed.
	 * @param msg The message to print after the usage message. not printed if null.
	 * @param out The stream on which to print the message, can't be null
	 */	
	public static void printUsage(String msg, PrintStream out){
		out.println("Usage: java -jar distr.jar command [command options] > output");
		out.println("Executes command with its options and sends the result to standard output");
		out.println("");
		out.println("Valid commands are help, generate, and listrelations");
		out.println("The command \"help [command name]\" will print the usage information for that");
		out.println("command.");
		if(msg != null){
			out.println("");			
			out.println(msg);
		}
	}
	
	/**
	 * Print the help message given that args are the command-line arguments
	 * that followed the help command on the command-line
	 * @param args The command-line arguments occurring after "help" on the command line
	 */
	public static void help(String[] args){
		if(args.length < 1){
			printUsage(null, System.out);
			return;
		}else if(args[0].equals("generate")){
			System.out.println("generate -xstd num -ystd num -rel shortname -smin minsamp -smax maxsamp ");
			System.out.println("         -inst numinst -c num -seed num > database_file");
			System.out.println("The generate command generates a database of measurements of the MIC");
			System.out.println("using numinst instances of data representing a particular relation");
			System.out.println("sampled a certain number of times with a particular noise distribution.");
			System.out.println("It generates tuples for all sample sizes in the range [minsamp,maxsamp].");
			System.out.println("The command takes key-value pair arguments that can be listed in any");
			System.out.println("order. All of the arguments must be present however. The meaning of each");
			System.out.println("argument is:");
			System.out.println("-xstd The standard deviation of the noise added to the x coordinate. If");
			System.out.println("      0, then the x coordinate is sampled noise-free.");
			System.out.println("-ystd The standard deviation of the noise added to the y coordinate. If");
			System.out.println("      0, then the y coordinate is sampled noise-free.");
			System.out.println("-rel  The short name of the base relation from which the samples are drawn");
			System.out.println("-smin The inclusive lower bound on the range of number of samples to be");
			System.out.println("      drawn for each instance.");
			System.out.println("-smax The inclusive upper bound on the range of number of samples to be");
			System.out.println("      drawn for each instance.");
			System.out.println("-inst The number of instances which will be binned and their mics added");
			System.out.println("      to the database");
			System.out.println("-c    by what factor clumps may outnumber columns when OptimizeXAxis is ");
			System.out.println("      called. When trying to partition the x-axis into x columns, ");
			System.out.println("      the algorithm will start with at most cx clumps. This is the same as ");
			System.out.println("      the c option to MINE.jar.");
			System.out.println("-seed The seed to use in starting the pseudorandom number generator.");
		}else if(args[0].equals("listrelations")){
			System.out.println("listrelations");
			System.out.println("The listrelations command takes no arguments and prints the available ");
			System.out.println("base relations along with their names and ids as a tab-separated list ");
			System.out.println("to stdout. Each row is one relation. The first column is the id, the ");
			System.out.println("second, the relation's short name, and the third, the full name");
		}else{
			printUsage(args[0]+" is an unknown command. Help must be called with a known command.", System.err);
			return;
		}
	}

	/**
	 * Calculate the distribution of the MIC over samples
	 * @param args The command-line arguments
	 */
	public static void main(String[] args) {
		if(args.length < 1){
			printUsage("Error: must have at least one argument",System.err); 
			return;
		}
		assert(args.length >= 1);
		String[] rest = Arrays.copyOfRange(args, 1, args.length);
		if(args[0].equals("help")){
			help(rest);
			return;
		}else if(args[0].equals("generate")){
			System.err.println("Sorry, the generate command is not implemented yet.");
			return;
		}else if(args[0].equals("listrelations")){
			System.err.println("Sorry, the listrelations command is not implemented yet.");
			return;
		}else{
			printUsage("Error: "+args[0]+" is not a known command.", System.err);
			return;
		}
	}

}
