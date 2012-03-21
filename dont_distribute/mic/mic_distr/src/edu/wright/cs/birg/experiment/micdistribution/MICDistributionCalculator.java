/**
 * 
 */
package edu.wright.cs.birg.experiment.micdistribution;

import java.io.PrintStream;
import java.util.Arrays;
import java.util.List;

/**
 * @author Eric Moyer
 *
 */
public final class MICDistributionCalculator {
	private static enum Command{
		help, generate, listrelations, dbdump, dbmerge, dbtomat
	}
	
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
		
		out.print("Valid commands are: ");
		int linePos = "Valid commands are: ".length();
		
		//Assemble the strings to be printed in listing the commands
		Command[] cmds = Command.values();		
		String[] strs = new String[cmds.length];
		for(int i = 0; i+1 < cmds.length; ++i){
			strs[i] = cmds[i].toString()+", ";
		}
		strs[cmds.length-1]="and "+cmds[cmds.length-1]+".";
		
		// Print the list of commands, word wrapping at the 75'th column (for
		// simplicity, I ignore that spaces on the end shouldn't send you to the
		// next row, so I'm really word-wrapping on the 74th column
		for(String s:strs){
			if(linePos + s.length() > 75){
				System.out.println();
				linePos = 0;
			}
			out.print(s);
			linePos += s.length();
		}
		out.println(""); //End the line after the last command.
		
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
		}
		Command c;
		try{
			c = Command.valueOf(args[0]);
		}catch (IllegalArgumentException e){
			printUsage(args[0]+" is an unknown command. Help must be called with a known command.", System.err);
			return;
		}
			
		switch(c){
		case generate: 
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
			break;
		case listrelations:
			System.out.println("listrelations");
			System.out.println("The listrelations command takes no arguments and prints the available ");
			System.out.println("base relations along with their names and ids as a tab-separated list ");
			System.out.println("to stdout. Each row is one relation. The first column is the id, the ");
			System.out.println("second, the relation's short name, and the third, the full name");
			break;
		case dbdump:
			System.out.println("dbdump [relationids|relationnames] < input_file.ser > output_file.tsv");
			System.out.println("dumps the java serialized database to a tab-separated value file.");
			System.out.println("The input database is read from standard input and the tab-separated");
			System.out.println("file is written to standard output.");
			System.out.println("");
			System.out.println("The dbdump command takes one parameter which can be either \"relationids\"");
			System.out.println("or \"relationames\". If the parameter is relationids, then the relation");
			System.out.println("field is dumped as an ID number. If the parameter is relationnames");
			System.out.println("then relation field is dumped as a string.");
			break;
		case dbmerge:
			System.out.println("dbmerge db1.ser db2.ser db3.ser ... > outputdb.ser");
			System.out.println("Merges all database files listed as arguments into one database and");
			System.out.println("prints that to stdout.");
			break;
		case dbtomat:
			System.out.println("dbtomat < inputdb.ser > outputdb.mat");
			System.out.println("Reads a database from stdin and writes it to stdout as a mat file.");
			System.out.println("Right now, the mat file will contain the relation id for each entry");			
			break;
		case help:
			help(new String[0]);
			break;
		}
	}
	
	/**
	 * Return true if and only if there are fewer than two distinct values for the entries of x
	 * @param x The array whose contents are examined.  Cannot be null
	 * @return true if and only if there are fewer than two distinct values for the entries of x
	 */
	private static boolean hasLessThanTwoValues(float[] x) {
		for(int i = 1; i < x.length; ++i){
			if(x[i] != x[0]){
				return false;
			}
		}
		return true;
	}

	
	/**
	 * Wrapper around Reshef's code to generate the MINE characteristic matrix. The returned matrix will have
	 * its first two rows as null. It will have entries for number of bins up to the sample size
	 * 
	 * @param x x[i] is the x coordinate of the ith point
	 * @param y y[i] is the y coordinate of the ith point
	 * @param maxClumpColumnRatio The maximum numberOfClumps/x_bins to use when calling optimizeXAxis. must be greater than 0
	 * @return heuristic approximations to the entries of the MINE characteristic matrix 
	 */
	public static float[][] reshefMINEWrapper(float[] x, float[] y, double maxClumpColumnRatio){
		if(x == null){
			throw new NullPointerException("x passed to reshefMINEWrapper was null");
		}
		if(y == null){
			throw new NullPointerException("y passed to reshefMINEWrapper was null");
		}
		if(x.length != y.length){
			throw new IllegalArgumentException("x and y must have the same length");
		}
		if(maxClumpColumnRatio <= 0){
			throw new IllegalArgumentException("maxClumpColumnRatio must be greater than 0, not "+maxClumpColumnRatio);
		}

		
		int maxNumBins = x.length;
		//Check for only input variables with no information content and return a 0 MINE matrix
		if(hasLessThanTwoValues(x) || hasLessThanTwoValues(y)){
			float[][] out = new float[maxNumBins][maxNumBins];
			out[0]=out[1]=null;
			for(int i = 2; i < maxNumBins; ++i){
				Arrays.fill(out[i], 0);
			}
			return out;
		}
		
		data.VarPairData d = new data.VarPairData(x,y);
		float exponent = 1;
		
		//Call Reshef's code to do the calculation
		mine.core.MineParameters mp = new mine.core.MineParameters(
				exponent, (float)maxClumpColumnRatio, 0, null);
		mine.core.Manifold man = new mine.core.Manifold(d, mp);
		
		//Return the result
		assert(man.scores != null);
		return man.scores;
	}

	/**
	 * Return the list of all relations that can be tested by this calculator
	 * @return the list of all relations that can be tested by this calculator
	 */
	public static List<Relation> allRelations(){
		List<Relation> rels = new java.util.LinkedList<Relation>();
		rels.add(new RandomRel());
		return rels;
	}

	
	/**
	 * Execute the listrelations command. Currently ignores all arguments.
	 * @param args The command-line arguments to the listrelations command
	 */
	public static void listrelations(@SuppressWarnings("unused") String[] args){
		List<Relation> rels = allRelations();
		System.out.println("ID\tShort Name\tFull Name");
		for(Relation r:rels){
			System.out.print(r.getId());
			System.out.print("\t");
			System.out.print(r.getShortName());
			System.out.print("\t");
			System.out.println(r.getFullName());
		}
	}
	
	/**
	 * Calculate the distribution of the MIC over samples
	 * @param args The command-line arguments
	 */
	public static void main(String[] args) {
		//Print an error if there were no arguments
		if(args.length < 1){
			printUsage("Error: must have at least one argument",System.err); 
			return;
		}
		assert(args.length >= 1);
		
		//Convert the first argument to a Command object
		Command c;
		try{
			c = Command.valueOf(args[0]);
		}catch (IllegalArgumentException e){
			printUsage("Error: "+args[0]+" is not a known command.", System.err);
			return;
		}

		//Execute the appropriate command
		String[] rest = Arrays.copyOfRange(args, 1, args.length);
		switch(c){
		case help:
			help(rest);
			return;
		case generate:
			System.err.println("Sorry, the "+c+" command is not implemented yet.");
			//TODO: implement generate command
			return;
		case listrelations:
			listrelations(rest);
			return;
		case dbdump:
			System.err.println("Sorry, the "+c+" command is not implemented yet.");
			//TODO: implement dbdump command
			return;
		case dbmerge:
			System.err.println("Sorry, the "+c+" command is not implemented yet.");
			//TODO: implement dbmerge command
			return;
		case dbtomat:
			System.err.println("Sorry, the "+c+" command is not implemented yet.");
			//TODO: implement dbtomat command
			return;
		}
	}

}
