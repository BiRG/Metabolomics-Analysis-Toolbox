/**
 * 
 */
package edu.wright.cs.birg.experiment.micdistribution;

import java.io.PrintStream;
import java.util.Arrays;
import java.util.LinkedList;
import java.util.List;

/**
 * @author Eric Moyer
 *
 */
public final class MICDistributionCalculator {
	private static enum Command{
		help, generate, listrelations, listdeps, dbdump, dbmerge, dbtomat
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
			System.out.println("generate -xstd num -ystd num -rel shortname -nsamp n1,n2,n3...nm ");
			System.out.println("         -inst numinst -c num -seed num > database_file");
			System.out.println("The generate command generates a database of measurements of the MIC");
			System.out.println("and other dependence measures using numinst instances of data representing ");
			System.out.println("a particular relation sampled a certain number of times with a particular ");
			System.out.println("noise distribution. It generates tuples for each listed sample size.");
			System.out.println("");
			System.out.println("The command takes key-value pair arguments that can be listed in any");
			System.out.println("order. All of the arguments must be present however. The meaning of each");
			System.out.println("argument is:");
			System.out.println("-xstd  The standard deviation of the noise added to the x coordinate. If");
			System.out.println("       0, then the x coordinate is sampled noise-free.");
			System.out.println("-ystd  The standard deviation of the noise added to the y coordinate. If");
			System.out.println("       0, then the y coordinate is sampled noise-free.");
			System.out.println("-rel   The short name of the base relation from which the samples are drawn");
			System.out.println("-nsamp a comma separated list of the sample sizes that will be used for");
			System.out.println("       generating the instances. You must have at least 4 samples so that");
			System.out.println("       MIC may be used. Note: do not include spaces or the shell will break");
			System.out.println("       the list up into two options and you will get an error.");
			System.out.println("-inst  The number of instances whose dependences will be added to the ");
			System.out.println("       database");
			System.out.println("-c     by what factor clumps may outnumber columns when OptimizeXAxis is ");
			System.out.println("       called. When trying to partition the x-axis into x columns, ");
			System.out.println("       the algorithm will start with at most cx clumps. This option only");
			System.out.println("       affects the calculation of the MIC dependence and is the same as ");
			System.out.println("       the c option to MINE.jar.");
			System.out.println("-seed  The seed to use in starting the pseudorandom number generator.");
			System.out.println("       Cannot be 0.");
			break;
		case listrelations:
			System.out.println("listrelations");
			System.out.println("The listrelations command takes no arguments and prints the available ");
			System.out.println("base relations including their names and ids as a tab-separated list ");
			System.out.println("to stdout. Each row is one relation. The first column is the id, the ");
			System.out.println("second, the relation's short name, and the third, the full name");
			break;
		case listdeps:
			System.out.println("listdeps");
			System.out.println("The listdeps command takes no arguments and prints the available ");
			System.out.println("dependence measures along with their names and ids as a tab-separated list ");
			System.out.println("to stdout. Each row is one measure. The first column is the id and the ");
			System.out.println("second, the measure's name");
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
		//Random relationship
		rels.add(new RandomRel());
		
		
		//Categorical relationships
		rels.add(new CategoricalRel(150, "categorical01", "Categorical 1", 
				new float[]{0}, 
				new float[]{0}
		));
		rels.add(new CategoricalRel(151, "categorical02", "Categorical 2", 
				new float[]{0,1}, 
				new float[]{0,1}
		));
		rels.add(new CategoricalRel(152, "categorical05", "Categorical 5", 
				new float[]{0.f,0.25f,0.5f,0.75f,1.f}, 
				new float[]{0.f,0.799f,0.036f,1.f,0.675f}
		));
		rels.add(new CategoricalRel(153, "categorical11", "Categorical 11", 
				new float[] { 0.f, 0.1f, 0.2f, 0.3f, 0.4f, 0.5f, 0.6f, 0.7f,
						0.8f, 0.9f, 1.f }, 
				new float[] { 1.f, 0.235f, 0.033f,
						0.817f, 0.589f, 0.262f, 0.923f, 0.963f, 0.f, 0.727f,
						0.179f }
		));
		rels.add(new CategoricalRel(154, "categorical23", "Categorical 23", 
				new float[] { 0.f, 0.045f, 0.091f, 0.136f, 0.182f, 0.227f,
						0.273f, 0.318f, 0.364f, 0.409f, 0.455f, 0.5f, 0.545f,
						0.591f, 0.636f, 0.682f, 0.727f, 0.773f, 0.818f, 0.864f,
						0.909f, 0.955f, 1.f }, 
				new float[] { 0.089f, 1.f,
						0.917f, 0.235f, 0.408f, 0.033f, 0.77f, 0.817f, 0.983f,
						0.589f, 0.339f, 0.262f, 0.731f, 0.923f, 0.181f, 0.963f,
						0.978f, 0.f, 0.049f, 0.727f, 0.335f, 0.179f, 0.706f }
		));
		rels.add(new CategoricalRel(155, "categorical47", "Categorical 47", 
				new float[] { 0.f, 0.022f, 0.043f, 0.065f, 0.087f, 0.109f,
						0.13f, 0.152f, 0.174f, 0.196f, 0.217f, 0.239f, 0.261f,
						0.283f, 0.304f, 0.326f, 0.348f, 0.37f, 0.391f, 0.413f,
						0.435f, 0.457f, 0.478f, 0.5f, 0.522f, 0.543f, 0.565f,
						0.587f, 0.609f, 0.63f, 0.652f, 0.674f, 0.696f, 0.717f,
						0.739f, 0.761f, 0.783f, 0.804f, 0.826f, 0.848f, 0.87f,
						0.891f, 0.913f, 0.935f, 0.957f, 0.978f, 1.f },
				new float[] { 0.554f, 0.146f, 0.91f, 0.972f,
						0.396f, 0.896f, 0.498f, 0.279f, 0.f, 0.435f, 0.421f,
						0.095f, 0.069f, 0.764f, 0.073f, 0.806f, 0.892f, 0.956f,
						0.809f, 0.599f, 0.974f, 0.373f, 0.127f, 0.303f, 0.706f,
						0.728f, 0.943f, 0.903f, 0.813f, 0.229f, 1.f, 0.939f,
						0.829f, 0.952f, 0.479f, 0.065f, 0.118f, 0.11f, 0.674f,
						0.724f, 0.446f, 0.369f, 0.772f, 0.228f, 0.284f, 0.706f,
						0.812f }		
		));
		rels.add(new CategoricalRel(156, "categorical95", "Categorical 95", 
				new float[] { 0.f, 0.011f, 0.021f, 0.032f, 0.043f, 0.053f,
						0.064f, 0.074f, 0.085f, 0.096f, 0.106f, 0.117f, 0.128f,
						0.138f, 0.149f, 0.16f, 0.17f, 0.181f, 0.191f, 0.202f,
						0.213f, 0.223f, 0.234f, 0.245f, 0.255f, 0.266f, 0.277f,
						0.287f, 0.298f, 0.309f, 0.319f, 0.33f, 0.34f, 0.351f,
						0.362f, 0.372f, 0.383f, 0.394f, 0.404f, 0.415f, 0.426f,
						0.436f, 0.447f, 0.457f, 0.468f, 0.479f, 0.489f, 0.5f,
						0.511f, 0.521f, 0.532f, 0.543f, 0.553f, 0.564f, 0.574f,
						0.585f, 0.596f, 0.606f, 0.617f, 0.628f, 0.638f, 0.649f,
						0.66f, 0.67f, 0.681f, 0.691f, 0.702f, 0.713f, 0.723f,
						0.734f, 0.745f, 0.755f, 0.766f, 0.777f, 0.787f, 0.798f,
						0.809f, 0.819f, 0.83f, 0.84f, 0.851f, 0.862f, 0.872f,
						0.883f, 0.894f, 0.904f, 0.915f, 0.926f, 0.936f, 0.947f,
						0.957f, 0.968f, 0.979f, 0.989f, 1.f },
				new float[] { 0.514f, 0.563f, 0.543f,
						0.162f, 0.63f, 0.911f, 0.528f, 0.973f, 0.226f, 0.407f,
						0.118f, 0.898f, 0.915f, 0.508f, 0.943f, 0.292f, 0.495f,
						0.018f, 0.228f, 0.446f, 0.703f, 0.431f, 0.177f, 0.112f,
						0.325f, 0.086f, 0.725f, 0.768f, 0.316f, 0.09f, 0.357f,
						0.81f, 0.f, 0.894f, 0.576f, 0.957f, 0.836f, 0.813f,
						0.942f, 0.606f, 0.071f, 0.975f, 0.879f, 0.385f, 0.081f,
						0.143f, 0.208f, 0.315f, 0.078f, 0.711f, 0.964f, 0.733f,
						0.092f, 0.944f, 0.437f, 0.904f, 0.657f, 0.817f, 0.277f,
						0.243f, 0.33f, 1.f, 0.191f, 0.94f, 0.183f, 0.832f,
						0.378f, 0.953f, 0.063f, 0.488f, 0.942f, 0.082f, 0.156f,
						0.134f, 0.009f, 0.126f, 0.609f, 0.68f, 0.602f, 0.729f,
						0.163f, 0.456f, 0.405f, 0.38f, 0.285f, 0.776f, 0.843f,
						0.242f, 0.838f, 0.297f, 0.028f, 0.711f, 0.298f, 0.816f,
						0.881f }		
		));
		
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
			generate(rest);
			return;
		case listrelations:
			listrelations(rest);
			return;
		case listdeps:
			listdeps(rest);
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
	
	/**
	 * Class to encapsulate the parsing of command line arguments for the generate command
	 * @author Eric Moyer
	 */
	private static class ArgsForGenerate{
		/**
		 * The value of the -xstd argument
		 */
		double xStd; 
		/**
		 * The value of the -ystd argument
		 */
		double yStd; 
		/**
		 * The value of the -rel argument
		 */
		Relation relation;
		/**
		 * The value of the -nsamp argument 
		 */
		List<Integer> sampleSizes;
		/**
		 * The value of the -inst argument
		 */
		int numInst;
		/**
		 * The value of the -c argument
		 */
		int clumpFactor;
		/**
		 * The value of the -seed argument
		 */		
		long seed;
		
		/**
		 * Indicates that there was a problem parsing the command line arguments for the generate command
		 * 
		 * @author Eric Moyer
		 *
		 */
		@SuppressWarnings("serial")
		public static class ParseException extends Exception{
			ParseException(String usageError){
				super(usageError);
			}
		}

		/**
		 * Parse args and create an ArgsForGenerate object if they are valid. If
		 * not, throws a ParseException with an exception message that should be
		 * passed to printUsage before exiting.
		 * 
		 * @param args
		 * @throws ParseException
		 *             If there is a syntax error in the arguments. The
		 *             exception message is what should be passed to printUsage.
		 */
		ArgsForGenerate(String[] args) throws ParseException{
			if(args.length != 14){
				throw new ParseException("Wrong number of arguments passed to generate command. It should take 7 key-value pairs.");
			}

			xStd = -1; 
			yStd = -1; 
			relation = null;
			sampleSizes = new LinkedList<Integer>();
			numInst = -1;
			clumpFactor = -1;
			seed = 0;

			for(int i = 0; i+1 < args.length; i+=2){
				String key = args[i].toLowerCase();
				String value = args[i+1];
				try{
					if(key.equals("-xstd")){
						xStd = Double.valueOf(value).doubleValue();
						if(xStd < 0){
							throw new ParseException("The x standard deviation must not be negative.");
						}
					}else if(key.equals("-ystd")){
						yStd = Double.valueOf(value).doubleValue();
						if(yStd < 0){
							throw new ParseException("The y standard deviation must not be negative.");
						}
					}else if(key.equals("-rel")){
						relation = relationFor(value);
						if(relation == null){
							throw new ParseException("\""+value+"\" is not a known relation short name.");
						}
					}else if(key.equals("-nsamp")){
						String[] values = value.split(",");
						for(String v:values){
							Integer size = Integer.valueOf(v);
							if(size.intValue() < 4){
								throw new ParseException("Sample sizes must be at least 4.");
							}
							sampleSizes.add(size);
						}
					}else if(key.equals("-inst")){
						numInst = Integer.valueOf(value).intValue();
						if(numInst < 1){
							throw new ParseException("There must be at least one instance generated.");
						}
					}else if(key.equals("-c")){
						clumpFactor = Integer.valueOf(value).intValue();
						if(clumpFactor < 1){
							throw new ParseException("The clump factor (c) must be at least 1");
						}
					}else if(key.equals("-seed")){
						seed = Long.valueOf(value).longValue();
						if(seed == 0){
							throw new ParseException("The seed cannot be 0");
						}
					}else{
						throw new ParseException("Error: \""+key+"\" is not a known option to the generate command.");
					}
				}catch (NumberFormatException e){
					throw new ParseException("Error: \""+value+"\" is not a proper argument for the "+
							key+" option.");
				}
			}
			String missing="";
			if(xStd == -1){
				missing = "-xstd";
			}else if(yStd == -1){
				missing = "-ystd";
			}else if(relation == null){
				missing = "-rel";
			}else if(sampleSizes.size() == 0){
				missing = "-nsamp";
			}else if(numInst == -1){
				missing = "-inst";
			}else if(clumpFactor == -1){
				missing = "-c";
			}else if(seed == 0){
				missing = "-seed";
			}
			if(!missing.equals("")){
				throw new ParseException("Error: missing the "+missing+" option to the generate command.");
			}
		}
		
		@Override
		public String toString(){
			String out = "-xstd "+xStd+" -ystd "+yStd+" -rel "+relation.getShortName()+
					" -nsamp ";
			for(int i = 0; i < sampleSizes.size(); ++i){
				out = out + sampleSizes.get(i); if(i + 1 < sampleSizes.size()){ out = out + ","; }
			}
			out = out + " -inst "+numInst+" -c "+clumpFactor+" -seed "+seed;
			return out;
		}
	}

	/**
	 * Execute the generate command
	 * @param args The command line arguments to the generate command 
	 */
	private static void generate(String[] args) {
		ArgsForGenerate a;
		try {
			a = new ArgsForGenerate(args);
		} catch (ArgsForGenerate.ParseException e) {
			printUsage(e.getMessage(),System.err);
			return;
		}
		//TODO: a stub for generate
		System.out.println("Generate called with args corresponding to "+a.toString());
	}

	/**
	 * Returns the relation with the short name field equal to shortName or null if there is no such relation. 
	 * @param shortName The name of the relation to return 
	 * @return the relation with the short name field equal to shortName or null if there is no such relation.
	 */
	private static Relation relationFor(String shortName) {
		List<Relation> relations=allRelations();
		for(Relation r:relations){
			if(r.getShortName().equals(shortName)){
				return r;
			}
		}
		return null;
	}

	/**
	 * Execute the listdeps command.
	 * @param rest Ignored argument containing the rest of the command line arguments
	 */
	private static void listdeps(@SuppressWarnings("unused") String[] rest) {
		List<DependenceMeasure> measures=allDepsButMIC();
		for(DependenceMeasure m: measures){
			System.out.print(m.getID());
			System.out.print('\t');
			System.out.println(m.getName());
		}
		System.out.println("4+\tMaximal Information Coefficient (MIC) with that number of bins");
	}

	/**
	 * Return a list containing objects for all available dependence measures
	 * except MIC (which is a special case).
	 * 
	 * @return a list containing objects for all available dependence measures
	 *         except MIC (which is a special case).
	 */
	private static List<DependenceMeasure> allDepsButMIC() {
		List<DependenceMeasure> l = new LinkedList<DependenceMeasure>();
		l.add(new DistanceCorrelationDep());
		l.add(new SpearmanDep());
		l.add(new PearsonDep());
		return l;
	}

}
