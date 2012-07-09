/**
 * 
 */
package edu.wright.cs.birg.experiment.micdistribution;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map.Entry;
import java.util.Random;
import java.util.TreeMap;
import org.sureassert.uc.annotation.Exemplar;
import org.sureassert.uc.annotation.Exemplars;
import org.sureassert.uc.annotation.IgnoreTestCoverage;

import com.jmatio.io.MatFileWriter;
import com.jmatio.types.MLArray;
import com.jmatio.types.MLDouble;

import edu.wright.cs.birg.experiment.micdistribution.relations.AlmostFlatRel;
import edu.wright.cs.birg.experiment.micdistribution.relations.ArcLengthRelation;
import edu.wright.cs.birg.experiment.micdistribution.relations.ArcLengthSine;
import edu.wright.cs.birg.experiment.micdistribution.relations.CategoricalRel;
import edu.wright.cs.birg.experiment.micdistribution.relations.CircleRel;
import edu.wright.cs.birg.experiment.micdistribution.relations.CosineRel;
import edu.wright.cs.birg.experiment.micdistribution.relations.CubicRel;
import edu.wright.cs.birg.experiment.micdistribution.relations.DownLineRel;
import edu.wright.cs.birg.experiment.micdistribution.relations.ExponentialRel;
import edu.wright.cs.birg.experiment.micdistribution.relations.Halton23Rel;
import edu.wright.cs.birg.experiment.micdistribution.relations.LinearThresholdSigmoidRel;
import edu.wright.cs.birg.experiment.micdistribution.relations.Monomial;
import edu.wright.cs.birg.experiment.micdistribution.relations.NonCoexistenceRel;
import edu.wright.cs.birg.experiment.micdistribution.relations.ParabolicRel;
import edu.wright.cs.birg.experiment.micdistribution.relations.RandomRel;
import edu.wright.cs.birg.experiment.micdistribution.relations.Relation;
import edu.wright.cs.birg.experiment.micdistribution.relations.ReshefLRel;
import edu.wright.cs.birg.experiment.micdistribution.relations.ReshefLopLRel;
import edu.wright.cs.birg.experiment.micdistribution.relations.SineRel;
import edu.wright.cs.birg.experiment.micdistribution.relations.SlantSineRel;
import edu.wright.cs.birg.experiment.micdistribution.relations.SpikeRel;
import edu.wright.cs.birg.experiment.micdistribution.relations.UnionRelation;
import edu.wright.cs.birg.experiment.micdistribution.relations.UpLineRel;
import edu.wright.cs.birg.experiment.micdistribution.relations.VaryingCosineRel;
import edu.wright.cs.birg.experiment.micdistribution.relations.VaryingSineRel;


/**
 * @author Eric Moyer
 *
 */
public final class MICDistributionCalculator {
	private static enum Command{
		help, generate, geninstance, roc, listrelations, listdeps, dbdump, dbmerge, dbtomat
	}
	
	/**
	 * Print the usage message for a given command followed by an optional error
	 * message <code>msg</code> on its own line.
	 * 
	 * @param msg
	 *            The message to print or null
	 * @param commandName
	 *            The command for which to print the usage message (or null)
	 * @param errOut
	 *            The stream on which to print the usage and error message
	 */
	@IgnoreTestCoverage
	private static void printUsage(String msg, String commandName,
			PrintWriter errOut) {
		help(new String[]{commandName}, errOut,errOut);
		
		if(msg != null){
			errOut.println("");			
			errOut.println(msg);
		}
	}

	/**
	 * Print the usage message followed by msg on its own line. If msg is null,
	 * it is not printed, but the usage is still printed.
	 * 
	 * @param msg
	 *            The message to print after the usage message. not printed if
	 *            null.
	 * @param out
	 *            The stream on which to print the message, can't be null
	 */
	@IgnoreTestCoverage
	public static void printUsage(String msg, PrintWriter out){
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
				out.println();
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
	 * @param errOut The stream for normal text
	 * @param txtOut The stream for errors and status messages
	 */
	@IgnoreTestCoverage
	public static void help(String[] args, PrintWriter txtOut, PrintWriter errOut){
		if(args.length < 1){
			printUsage(null, txtOut);
			return;
		}
		Command c;
		try{
			c = Command.valueOf(args[0]);
		}catch (IllegalArgumentException e){
			printUsage(args[0]+" is an unknown command. Help must be called with a known command.", errOut);
			return;
		}
			
		switch(c){
		case generate: 
			txtOut.println("generate -xstd num -ystd num -rel shortname -nsamp n1,n2,n3...nm ");
			txtOut.println("         -inst numinst -c num -seed num > database_file");
			txtOut.println("The generate command generates a database of measurements of the MIC");
			txtOut.println("and other dependence measures using numinst instances of data representing ");
			txtOut.println("a particular relation sampled a certain number of times with a particular ");
			txtOut.println("noise distribution. It generates tuples for each listed sample size.");
			txtOut.println("");
			txtOut.println("The command takes key-value pair arguments that can be listed in any");
			txtOut.println("order. All of the arguments must be present however. The meaning of each");
			txtOut.println("argument is:");
			txtOut.println("-xstd  The standard deviation of the noise added to the x coordinate. If");
			txtOut.println("       0, then the x coordinate is sampled noise-free.");
			txtOut.println("-ystd  The standard deviation of the noise added to the y coordinate. If");
			txtOut.println("       0, then the y coordinate is sampled noise-free.");
			txtOut.println("-rel   The short name of the base relation from which the samples are drawn");
			txtOut.println("-nsamp a comma separated list of the sample sizes that will be used for");
			txtOut.println("       generating the instances. You must have at least 4 samples so that");
			txtOut.println("       MIC may be used. Note: do not include spaces or the shell will break");
			txtOut.println("       the list up into two options and you will get an error.");
			txtOut.println("-inst  The number of instances whose dependences will be added to the ");
			txtOut.println("       database");
			txtOut.println("-c     by what factor clumps may outnumber columns when OptimizeXAxis is ");
			txtOut.println("       called. When trying to partition the x-axis into x columns, ");
			txtOut.println("       the algorithm will start with at most cx clumps. This option only");
			txtOut.println("       affects the calculation of the MIC dependence and is the same as ");
			txtOut.println("       the c option to MINE.jar.");
			txtOut.println("-seed  The seed to use in starting the pseudorandom number generator.");
			txtOut.println("       Cannot be 0.");
			break;
		case listrelations:
			txtOut.println("listrelations");
			txtOut.println("The listrelations command takes no arguments and prints the available ");
			txtOut.println("base relations including their names and ids as a tab-separated list ");
			txtOut.println("to stdout. Each row is one relation. The first column is the id, the ");
			txtOut.println("second, the relation's short name, and the third, the full name");
			break;
		case listdeps:
			txtOut.println("listdeps");
			txtOut.println("The listdeps command takes no arguments and prints the available ");
			txtOut.println("dependence measures along with their names and ids as a tab-separated list ");
			txtOut.println("to stdout. Each row is one measure. The first column is the id and the ");
			txtOut.println("second, the measure's name");
			break;
		case dbdump:
			txtOut.println("dbdump [relationids|relationnames] < input_file.ser > output_file.tsv");
			txtOut.println("dumps the java serialized database to a tab-separated value file.");
			txtOut.println("The input database is read from standard input and the tab-separated");
			txtOut.println("file is written to standard output.");
			txtOut.println("");
			txtOut.println("The dbdump command takes one parameter which can be either \"relationids\"");
			txtOut.println("or \"relationames\". If the parameter is relationids, then the relation");
			txtOut.println("field is dumped as an ID number. If the parameter is relationnames");
			txtOut.println("then relation field is dumped as a string.");
			break;
		case dbmerge:
			txtOut.println("dbmerge db1.ser db2.ser db3.ser ... > outputdb.ser");
			txtOut.println("Merges all database files listed as arguments into one database and");
			txtOut.println("prints that to stdout.");
			break;
		case dbtomat:
			txtOut.println("dbtomat < inputdb.ser > outputdb.mat");
			txtOut.println("Reads a database from stdin and writes it to stdout as a mat file.");
			txtOut.println("Right now, the mat file will contain the relation id for each entry");			
			break;
		case help:
			help(new String[0], txtOut, errOut);
			break;
		case geninstance:
			txtOut.println("genInstance relation numSamples xStd yStd > samples.tsv");
			txtOut.println("Generates numSamples samples from the given relation and noise");
			txtOut.println("condition and writes them to stdout.");
			txtOut.println("");
			txtOut.println("relation   the short name of a relation (see listrelations)");
			txtOut.println("numSamples the number of samples to generate");
			txtOut.println("xStd       the standard deviation of the noise added to the x axis");
			txtOut.println("           0 for noiseless.");
			txtOut.println("yStd       the standard deviation of the noise added to the y axis");
			txtOut.println("           0 for noiseless.");
			break;
		case roc:
			txtOut.println("roc nullHyp.ser altHyp.ser numSamples depMeasureID > roc_points.tsv");
			txtOut.println("Prints a tab-separated value file of the points on the ");
			txtOut.println("receiver-operator characteristic curve.");
			txtOut.println("");
			txtOut.println("The roc points are ordered pairs: the fraction of false positives then");
			txtOut.println("the fraction true positives.");
			txtOut.println("");
			txtOut.println("A positive is when the classifier at a given threshold rejects ");
			txtOut.println("the null hypothesis that the instance comes from sampling the relation ");
			txtOut.println("in nullHyp.ser. ");
			txtOut.println("");
			txtOut.println("nullHyp.ser  The java-serialized databse holding the data from the ");
			txtOut.println("             relation that forms the null hypothesis for the classifier.");
			txtOut.println("             This will probably be the dependence measures of random ");
			txtOut.println("             data.");
			txtOut.println("altHyp.ser   Like nullHyp.ser but the data is from the alternative ");
			txtOut.println("             hypothesis relation.");
			txtOut.println("numSamples   Only instances with numSamples samples are considered");
			txtOut.println("depMeasureID The threshold is applied to the dependence generated");
			txtOut.println("             by the dependence measure with this id");
			break;
		}
	}
	
	/**
	 * Return true if and only if there are fewer than two distinct values for the entries of x
	 * @param x The array whose contents are examined.  Cannot be null
	 * @return true if and only if there are fewer than two distinct values for the entries of x
	 */
	@Exemplars(set={
	@Exemplar(args={"null"}, ee="NullPointerException"),
	@Exemplar(args={"edu/wright/cs/birg/test/ArrayUtils.emptyFloat()"}, expect="true"),
	@Exemplar(args={"[pa:1.0f]"}, expect="true"),
	@Exemplar(args={"[pa:0.0f]"}, expect="true"),
	@Exemplar(args={"[pa:1.0f,0.0f]"}, expect="false"),
	@Exemplar(args={"[pa:1.0f,1.0f]"}, expect="true")
	})
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
	@IgnoreTestCoverage
	public static List<Relation> allRelations(){
		List<Relation> rels = new java.util.LinkedList<Relation>();
		//Random relationship
		rels.add(new RandomRel());
		
		//Parabolic relationship
		rels.add(new ParabolicRel());
		
		//Cubic relationship
		rels.add(new CubicRel(10, "cubic1", "Cubic 1", 11, 47, 12, -11, 8));
		rels.add(new CubicRel(11, "cubic2", "Cubic 2", 7, 57, 2, -73, 48));
		
		//Exponential relationship
		rels.add(new ExponentialRel(20, "exp2", "Exponential base 2", 2.0));
		rels.add(new ExponentialRel(21, "exp10", "Exponential base 10", 10.0));
		rels.add(new ExponentialRel(22, "exp1e10", "Exponential base 1e10", 1e10));
		
		//Sine relationships
		ArcLengthRelation sin02pi = new ArcLengthSine(32, "sin02pi", "Sine 2 pi", 2);
		ArcLengthRelation sin03pi = new ArcLengthSine(33, "sin03pi", "Sine 3 pi", 3);
		ArcLengthRelation sin04pi = new ArcLengthSine(34, "sin04pi", "Sine 4 pi", 4);
		ArcLengthRelation sin10pi = new ArcLengthSine(40, "sin10pi", "Sine 10 pi", 10);
		rels.add(new SineRel(30, "sinhalfpi", "Sin 1/2 pi", 0.5));
		rels.add(new SineRel(31, "sin01pi", "Sin 1 pi", 1.0));
		rels.add(sin02pi);
		rels.add(sin03pi);
		rels.add(sin04pi);
		rels.add(new CosineRel(37, "cos07pi", "Cosine 7 pi", 7));
		rels.add(new SineRel(38, "sin08pi", "Sin 8 pi", 8.0));
		rels.add(new SineRel(39, "sin09pi", "Sin 9 pi", 9.0));
		rels.add(sin10pi);
		rels.add(new SineRel(43, "sin13pi", "Sin 13 pi", 13.0));
		rels.add(new CosineRel(44, "cos14pi", "Cosine 14 pi", 14.0));
		rels.add(new SineRel(46, "sin16pi", "Sin 16 pi", 16.0));
		rels.add(new SineRel(62, "sin32pi", "Sin 32 pi", 32.0));
		
		//Varying frequency sine and cosine relationships
		rels.add(new VaryingCosineRel(85, "varfr5c", "Varying Freq 5 pi Cosine", 5.0));
		rels.add(new VaryingSineRel(86, "varfr6s", "Varying Freq 6 pi Sine", 6.0));
		rels.add(new VaryingSineRel(87, "varfr7s", "Varying Freq 7 pi Sine", 7.0));
		
		//Two sine relationships
		rels.add(new UnionRelation(92, "2sin2_3",  "Two Sine (2,3)",  sin02pi, sin03pi));
		rels.add(new UnionRelation(94, "2sin4_10", "Two Sine (4,10)", sin04pi, sin10pi));
		
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
		
		//Linear relationships
		ArcLengthRelation lines1 = new UpLineRel(161, "lines1", "1 Line", 1.0);
		ArcLengthRelation lines2 = new NonCoexistenceRel();
		ArcLengthRelation linesqrt3 = new UpLineRel(0, "linesqrt3", "Line slope sqrt 3", Math.sqrt(3));
		ArcLengthRelation linesqrt3recip = new UpLineRel(0, "linesqrt3recip", "Line slope one over sqrt 3", 1/Math.sqrt(3));
		ArcLengthRelation linesqrt2m1 = new UpLineRel(0, "linesqrt2m1", "Line slope -1 plus sqrt 2", Math.sqrt(2)-1);
		ArcLengthRelation linesqrt2m1recip = new UpLineRel(0, "linesqrt2m1recip", "Line slope one over -1 plus sqrt 2", 1/(Math.sqrt(2)-1));
		ArcLengthRelation dline1 = new DownLineRel(0, "dline1", "1 Line Down", -1.0);
		rels.add(lines1);
		rels.add(lines2);
		rels.add(new UnionRelation(163, "lines3", "3 Lines", lines2, lines1));
		rels.add(new UnionRelation(164, "lines4", "4 Lines", lines2, 
				new UnionRelation(0,"sqrt3Lines","Both lines based on sqrt 3",linesqrt3, linesqrt3recip)));
		rels.add(new UnionRelation(165, "lines5", "5 Lines", lines2,
				new UnionRelation(0, "inner3Of5","inner 3 of the 5 equispaced line group",
						lines1,
						new UnionRelation(0,"sqrt2m1Lines","Both lines based on sqrt 2 minus 1",
								linesqrt2m1, linesqrt2m1recip))));
		//X
		rels.add(new UnionRelation(180, "x", "X", lines1, dline1));
		
		//Circle
		rels.add(new CircleRel());
		
		//Line and Parabola
		rels.add(new UnionRelation(200, "lineparab", "Line and Parabola", lines1, new ParabolicRel()));
		
		//Spike
		rels.add(new SpikeRel());
		
		//Sigmoid
		rels.add(new LinearThresholdSigmoidRel());
		
		//L-shaped
		rels.add(new ReshefLRel());
		
		//Lopsided L-shaped
		rels.add(new ReshefLopLRel());
		
		//Slant-sine
		rels.add(new SlantSineRel(408, "slsin0811116", "Slant Sine 11,8,116", -0.10541412190940591799, 
				-8.0, 4.0, 1.1595553410034650979, -0.07977767050173254893));
		rels.add(new SlantSineRel(421, "slsin2105110", "Slant Sine 5,21,110", -0.049616836075317710997, 
				-21.2, 10.6, 1.0915703936569896419, -0.045785196828494820969));
		rels.add(new SlantSineRel(423, "slsin2110106", "Slant Sine 10,21,106", -0.09591241288864109547, 
				-21.2, 10.6, 1.0550365417750520501, -0.0275182708875260251));
		rels.add(new SlantSineRel(428, "slsin2833033", "Slant Sine 33,28,33", -0.33333333333333333333, 
				28.274333882308139146, 1.5707963267948966192, 
				0.33333333333333333333, 0.33333333333333333333));
		rels.add(new SlantSineRel(431, "slsin3137037", "Slant Sine 37,31,37", 0.3702314242429132339, 
				31.415926535897932385, 0, 
				0.3702314242429132339, 0.31488428787854338307));
		
		/////////////////////////
		// Pathological relations
		/////////////////////////
		
		rels.add(new AlmostFlatRel());
		rels.add(new Halton23Rel());
		rels.add(new SineRel(10003, "sin2046pi", "Sine 2046 pi", 2046));
		rels.add(new Monomial(10004, "steeppoly", "Steep poly", 1000000000.0));
		
		return rels;
	}

	
	/**
	 * Execute the listrelations command. Prints the list of relations as a tab-separated txt file to txtOut.
	 * @param txtOut The stream for normal messages (on which the list will be printed)
	 */
	@IgnoreTestCoverage
	public static void listrelations(PrintWriter txtOut){
		List<Relation> rels = allRelations();
		txtOut.println("ID\tShort Name\tFull Name");
		for(Relation r:rels){
			txtOut.print(r.getId());
			txtOut.print("\t");
			txtOut.print(r.getShortName());
			txtOut.print("\t");
			txtOut.println(r.getFullName());
		}
	}
	
	/**
	 * Calculate the distribution of the MIC over samples
	 * @param args The command-line arguments
	 */
	@IgnoreTestCoverage
	public static void main(String[] args) {
		PrintWriter errOut = new PrintWriter(System.err, true); //Stream for errors and status
		PrintWriter txtOut = new PrintWriter(System.out, true); //Stream for printing normal messages
		OutputStream dbOut = System.out; //Stream for printing the output database
		InputStream dbIn = System.in; //Stream for reading the input database
		
		//Print an error if there were no arguments
		if(args.length < 1){
			printUsage("Error: must have at least one argument",errOut); 
			return;
		}
		assert(args.length >= 1);
		
		//Convert the first argument to a Command object
		Command c;
		try{
			c = Command.valueOf(args[0]);
		}catch (IllegalArgumentException e){
			printUsage("Error: "+args[0]+" is not a known command.", errOut);
			return;
		}

		//Execute the appropriate command
		String[] rest = Arrays.copyOfRange(args, 1, args.length);
		switch(c){
		case help:
			help(rest, txtOut, errOut);
			return;
		case generate:
			generate(rest, errOut, dbOut);
			return;
		case geninstance:
			geninstance(rest, txtOut, errOut);
			return;
		case listrelations:
			listrelations(txtOut);
			return;
		case listdeps:
			listdeps(txtOut);
			return;
		case dbdump:
			dbdump(rest, dbIn, txtOut, errOut);
			return;
		case dbmerge:
			dbmerge(rest, errOut, dbOut);
			return;
		case dbtomat:
			dbtomat(dbIn, errOut, dbOut);
			return;
		case roc:
			roc(rest, txtOut, errOut);
			break;
		}
	}
	
	/**
	 * Return a new database object loaded from the file named
	 * <code>filename</code>. Any errors in loading the database are fatal and
	 * printed to the user.
	 * 
	 * @param filename
	 *            The name of a file containing the serialized form of the
	 *            database to load
	 * @param errOut
	 *            The stream on which error messages are printed
	 * @return a new database object loaded from the file named
	 *         <code>filename</code>
	 */
	@IgnoreTestCoverage	
	private static Database loadDB(String filename, PrintWriter errOut) {
		FileInputStream fIn;
		try{
			fIn = new FileInputStream(filename);
		} catch (FileNotFoundException e1) {
			errOut.println("Error: could not find the database file \""+filename+"\"");
			System.exit(-1); return null;
		}

		ObjectInputStream obIn;
		try {	
			obIn = new ObjectInputStream(fIn);
		} catch (IOException e) {
			errOut.println("Error reading from the database file \""+filename+"\". System message: "+e.getLocalizedMessage());
			System.exit(-1); return null;
		}

		try {
			return (Database)obIn.readObject();
		} catch (IOException e) {
			errOut.println("Error: could not read database from input; io exception: "+e.getLocalizedMessage());
			System.exit(-1); return null;
		} catch (ClassNotFoundException e) {
			errOut.println("Error: could not read database from input; class not found exception: "+e.getLocalizedMessage());
			System.exit(-1); return null;
		}
	}
	
	/**
	 * Counts of the number of dependencies above a threshold
	 * in the null distribution and the alternative distribution
	 * 
	 * @author Eric Moyer
	 * 
	 */
	private static final class ThresholdCount{
		/**
		 * The number of data points in the null distribution that have
		 * dependence values greater than this threshold
		 */
		public int nullCount;
		/**
		 * The number of data points in the alternative distribution that have
		 * dependence values greater than this threshold
		 */
		public int altCount;

		/**
		 * Create a ThresholdCount with zero counts
		 */
		@Exemplar(expect = {"=(retval.nullCount,0)", "=(retval.altCount,0)" })
		ThresholdCount() {
			nullCount = 0;
			altCount = 0;
		}

		@Override
		public String toString() {
			return "ThresholdCount(n:" + nullCount + " a:"
					+ altCount + ")";
		}
	}
	
	/**
	 * Run the <code>roc</code> command. Generate points on the
	 * receiver-operator characteristic curve.
	 * 
	 * @param args
	 *            The command line arguments to the <code>roc</code> command.
	 *            Cannot be null.
	 * @param txtOut
	 *            The stream on which the roc points will be output. Cannot be
	 *            null.
	 * @param errOut
	 *            The stream for error and status messages. Cannot be null.
	 */
	@SuppressWarnings("boxing")
	@IgnoreTestCoverage
	private static void roc(String[] args, PrintWriter txtOut,
			PrintWriter errOut) {
		if (args.length != 4) {
			printUsage(
					"Error: wrong number of arguments passed to roc command.",
					"roc", errOut);
		}

		Database nullDB = loadDB(args[0], errOut);
		Database altDB = loadDB(args[1], errOut);
		int numSamples = toInt(args[2], 0, Integer.MAX_VALUE, errOut);
		int depMethodID = toInt(args[3], minDependenceMethodID(), numSamples, errOut);
		
		//Set up as thresholds all dependence values that appear in either set.
		TreeMap<Float, ThresholdCount> depCounts = new TreeMap<Float, ThresholdCount>();
		LinkedList<Float> nullVals = new LinkedList<Float>();
		for(DataPoint dp:nullDB){
			if(dp.numSamples == numSamples && dp.dependenceMeasureID == depMethodID){
				Float thresh = new Float(dp.dependence);
				nullVals.add(thresh);
				if(!depCounts.containsKey(thresh)){
					depCounts.put(thresh, new ThresholdCount());
				}
			}
		}
		nullDB = null;
		
		LinkedList<Float> altVals = new LinkedList<Float>();
		for(DataPoint dp:altDB){
			if(dp.numSamples == numSamples && dp.dependenceMeasureID == depMethodID){
				Float thresh = new Float(dp.dependence);
				altVals.add(thresh);
				if(!depCounts.containsKey(thresh)){
					depCounts.put(thresh, new ThresholdCount());
				}
			}
		}
		altDB = null;
		

		//Add thresholds above the highest dependence and below the lowest.
		depCounts.put(Math.nextUp(depCounts.lastKey()), new ThresholdCount());
		depCounts.put(Math.nextAfter(depCounts.firstKey(), Float.NEGATIVE_INFINITY), new ThresholdCount());
		
		//Set the counts to the number of values with exactly that threshold
		for(Float dep:nullVals){
			++depCounts.get(dep).nullCount;
		}
		for(Float dep:altVals){
			++depCounts.get(dep).altCount;
		}
		
		//Update the counts so they reflect the values of lower and higher thresholds
		int altLessEqual = 0;  //Number of alternate distribution entries that have a threshold less than or equal to this entry
		int nullLessEqual = 0; //Number of null distribution entries that have a threshold less than or equal to this entry
		for(Entry<Float, ThresholdCount> entry: depCounts.entrySet()){
			altLessEqual += entry.getValue().altCount;
			nullLessEqual += entry.getValue().nullCount;
			entry.getValue().altCount = altVals.size() - altLessEqual;
			entry.getValue().nullCount = nullVals.size() - nullLessEqual;
		}

		//Convert the total counts to double for more readable division operations later
		double nullTotal = nullVals.size();
		double altTotal = altVals.size();
		
		//Print the output
		//txtOut.print("False Positives\tTrue Positives\n");
		for(Entry<Float, ThresholdCount> entry: depCounts.entrySet()){
			txtOut.printf("%.9f\t%.9f\n",
					entry.getValue().nullCount/nullTotal, entry.getValue().altCount/altTotal);
		}
	}

	/**
	 * Return the minimum id value used by any dependence method.
	 * 
	 * @return the minimum id value used by any dependence method.
	 */
	private static int minDependenceMethodID() {
		List<DependenceMeasure> deps = allDepsButMIC();
		int min = Integer.MAX_VALUE;
		for (DependenceMeasure dep : deps) {
			if (min > dep.getID()) {
				min = dep.getID();
			}
		}
		return min;
	}

	/**
	 * Convert <code>string</code> to an integer. Prints error messages and
	 * exits if <code>string</code> is not an integer or if it does not lie
	 * between <code>minValue</code> and <code>maxValue</code>
	 * 
	 * @param string
	 *            The string to convert. Cannot be null.
	 * @param minValue
	 *            The minimum acceptable value for the return.
	 * @param maxValue
	 *            The maximum acceptable value for the return.
	 * @param errOut
	 *            The stream on which to print error messages.
	 * @return <code>string</code> as an integer
	 */
	@IgnoreTestCoverage
	private static int toInt(String string, int minValue, int maxValue,
			PrintWriter errOut) {
		try{
			int retval = Integer.parseInt(string);
			if(retval < minValue){
				errOut.println("Error: "+string+" cannot be less than "+minValue);				
				System.exit(-1); return 0;
			}
			if(retval > maxValue){
				errOut.println("Error: "+string+" cannot be greater than "+maxValue);				
				System.exit(-1); return 0;
			}
			return retval;
		}catch (NumberFormatException e){
			errOut.println("Error: \""+string+"\" is not an integer.");
			System.exit(-1); return 0;
		}
	}

	/**
	 * Run the <code>geninstance</code> command. Generate an instance and print
	 * it to stdout as a tab-separated value file.
	 * 
	 * @param args
	 *            The command line arguments to the <code>geninstance</code>
	 *            command. Cannot be null.
	 * @param txtOut
	 *            The stream on which the instance will be output.  Cannot be null.
	 * @param errOut
	 *            The stream for error and status messages. Cannot be null.
	 */
	@IgnoreTestCoverage
	private static void geninstance(String[] args, PrintWriter txtOut,
			PrintWriter errOut) {
		if(args.length != 4){
			help(new String[]{"geninstance"}, errOut, errOut);
			errOut.println("Error: not enough arguments passed to geninstance");
			return;			
		}
		
		Relation relation = relationFor(args[0]);
		if(relation == null){
			help(new String[]{"geninstance"}, errOut, errOut);
			errOut.println("Error: "+args[0]+" is not the name of a known relation");
			return;
		}
		
		double xStd = 0;
		double yStd = 0;
		int numSamples = 0;
		try{
			numSamples = Integer.valueOf(args[1]).intValue();
			xStd = Double.valueOf(args[2]).doubleValue();
			yStd = Double.valueOf(args[3]).doubleValue();
		}catch(NumberFormatException e){
			help(new String[]{"geninstance"}, errOut, errOut);
			errOut.println("Error: could not parse one of the arguments to geninstance");
			return;
		}
		
		Random rng = new Random();
		
		Instance inst = newNoisyInstance(relation, xStd, yStd, rng, numSamples);
		
		txtOut.println("X\tY");
		for(int i = 0; i < numSamples; ++i){
			txtOut.println(inst.x[i]+"\t"+inst.y[i]);
		}
	}

	/**
	 * Run the <code>dbtomat</code> command. Reads a database from <code>dbIn</code> and writes it out as a mat file.
	 * @param dbIn The stream from which the database will be read. Cannot be null.
	 * @param errOut The stream for status and error messages
	 * @param dbOut The stream on which the database will be written.
	 */
	@IgnoreTestCoverage
	private static void dbtomat(InputStream dbIn, PrintWriter errOut, OutputStream dbOut) {
		ObjectInputStream obIn;
		try {
			obIn = new ObjectInputStream(dbIn);
		} catch (IOException e) {
			errOut.println("Error creating object input stream - probably wrong file format. The full error is: "+e.getLocalizedMessage());
			return;
		} 

		Database db = null;
		try {
			db = (Database)obIn.readObject();
		} catch (IOException e) {
			errOut.println("Error: could not read database from input; io exception: "+e.getLocalizedMessage());
			return;
		} catch (ClassNotFoundException e) {
			errOut.println("Error: could not read database from input; class not found exception: "+e.getLocalizedMessage());
			return;
		}
		
		MLDouble dependence;
		MLDouble dependenceMeasureID;
		MLDouble instanceID;
		MLDouble numSamples;
		MLDouble relationID;
		MLDouble xNoiseStd;
		MLDouble yNoiseStd;

		int numDP = db.getNumDatapoints();
		dependence = new MLDouble("dependences", new int[] {numDP,1});
		dependenceMeasureID = new MLDouble("dependenceMeasureIDs", new int[] {numDP,1}); 
		instanceID = new MLDouble("instanceIDs", new int[] {numDP,1});
		numSamples = new MLDouble("numSamples", new int[] {numDP,1});
		relationID = new MLDouble("relationIDs", new int[] {numDP,1});
		xNoiseStd = new MLDouble("xNoiseStds", new int[] {numDP,1});
		yNoiseStd = new MLDouble("yNoiseStds", new int[] {numDP,1});
		
		{
			int curIdx = 0;
			for(DataPoint p: db){
				dependence.setReal(new Double(p.dependence), curIdx);
				dependenceMeasureID.setReal(new Double(p.dependenceMeasureID), curIdx);
				instanceID.setReal(new Double(p.instanceID), curIdx);
				numSamples.setReal(new Double(p.numSamples), curIdx);
				relationID.setReal(new Double(p.relationID), curIdx);
				xNoiseStd.setReal(new Double(p.xNoiseStandardDeviation), curIdx);
				yNoiseStd.setReal(new Double(p.yNoiseStandardDeviation), curIdx);
				++curIdx;
			}
		}
				
		List<MLArray> toSave = new LinkedList<MLArray>();
		toSave.add(dependence);
		toSave.add(dependenceMeasureID);
		toSave.add(instanceID);
		toSave.add(numSamples);
		toSave.add(relationID);
		toSave.add(xNoiseStd);
		toSave.add(yNoiseStd);
		try {
			MatFileWriter.writeMat(dbOut, toSave);
		} catch (IOException e) {
			errOut.println("Error writing database. The system message is: "+e.getLocalizedMessage());
		}
	}

	/**
	 * Run the dbmerge command. Starts with an empty database and adds the entries from each database file
	 * on the command line to it. Writes the resulting database to dbOut
	 * @param args  The command-line arguments to the dbdump command. Cannot be null.
	 * @param errOut The stream for errors and status messages. Cannot be null.
	 * @param dbOut The stream to which the combined database will be written
	 */
	@IgnoreTestCoverage
	private static void dbmerge(String[] args, PrintWriter errOut,
			OutputStream dbOut) {
		Database db = new Database();
		for(String filename:args){
			FileInputStream fileIn = null;
			try {
				fileIn = new FileInputStream(filename);
			} catch (FileNotFoundException e) {
				errOut.println("Error: could not find database file \""+filename+"\". System error message: "+e.getLocalizedMessage());
				return;
			}
			ObjectInputStream in = null;
			try {
				in = new ObjectInputStream(fileIn);
			} catch (IOException e) {
				errOut.println("Error: could not begin reading database from file \""+filename+"\". System error message: "+e.getLocalizedMessage());
				return;
			}
			Database lastRead = null;
			try {
				lastRead = (Database)in.readObject();
			} catch (IOException e) {
				errOut.println("Error reading database from file \""+filename+"\". System error message: "+e.getLocalizedMessage());
				return;
			} catch (ClassNotFoundException e) {
				errOut.println("Error: the file \""+filename+"\" contained an object of a class that could not be loaded. System error message: "+e.getLocalizedMessage());
				return;
			} catch (ClassCastException e) {
				errOut.println("Error: the file \""+filename+"\" contained an object of a class that could not cast to type Database. System error message: "+e.getLocalizedMessage());
				return;				
			}
			
			db.splice(lastRead);
			
			try {
				in.close();
			} catch (IOException e) {
				errOut.println("Error: could not close file \""+filename+"\". System error message: "+e.getLocalizedMessage());
				return;
			}
		}
		
		ObjectOutputStream out = null; 
		try {
			out = new ObjectOutputStream(dbOut);
		} catch (IOException e) {
			errOut.println("Error: could not open the database output stream to write the database. System error message:"+e.getLocalizedMessage());
			return;
		}
		
		try {
			out.writeObject(db);
		} catch (IOException e) {
			errOut.println("Error: could not write the database. System error message: "+e.getLocalizedMessage());
			return;
		}
	}

	/**
	 * Run the dbdump command. Prints the database read from dbIn to txtOut as a csv file. Whether the relations are printed as strings or numbers is determined by the contents of args.
	 * @param args The command-line arguments to the dbdump command. Cannot be null.
	 * @param dbIn The stream from which the input database will be read. Cannot be null.
	 * @param txtOut The stream on which the output csv will be written. Cannot be null.
	 * @param errOut The stream for errors and status messages. Cannot be null.
	 */
	@IgnoreTestCoverage
	private static void dbdump(String[] args, InputStream dbIn,
			PrintWriter txtOut, PrintWriter errOut) {
		ObjectInputStream obIn;
		try {
			obIn = new ObjectInputStream(dbIn);
		} catch (IOException e) {
			errOut.println("Error creating object input stream - probably wrong file format. The full error is: "+e.getLocalizedMessage());
			return;
		} 

		Database db = null;
		try {
			db = (Database)obIn.readObject();
		} catch (IOException e) {
			errOut.println("Error: could read database from input io exception: "+e.getLocalizedMessage());
			return;
		} catch (ClassNotFoundException e) {
			errOut.println("Error: could read database from input class not found exception: "+e.getLocalizedMessage());
			return;
		}
		if(args.length != 1){
			printUsage("Wrong number of arguments to dbdump", errOut);
			return;
		}
		boolean printIds;
		String relation_header;
		if(args[0].equals("relationids")){
			printIds = true;
			relation_header = "relation id";
		}else if(args[0].equals("relationnames")){
			printIds = false;
			relation_header = "relation name";
		}else{
			printUsage(args[0]+" is not a known argument to dbdump", errOut);
			return;
		}
		List<Relation> relations=allRelations();
		HashMap<Integer,String> relNameForID = new HashMap<Integer, String>(5*relations.size());
		for(Relation r:relations){
			relNameForID.put(new Integer(r.getId()), r.getShortName());
		}
		
		
		txtOut.println("instance id\t"+relation_header+"\tnumber of samples\tx noise standard deviation\ty noise standard deviation\tdependence measure id\tdependence value");
		Iterator<DataPoint> it= db.iterator();
		while(it.hasNext()){
			DataPoint p = it.next();
			txtOut.print(p.instanceID);	txtOut.print('\t');
			if(printIds){
				txtOut.print(p.relationID);
			}else{
				String name = relNameForID.get(new Integer(p.relationID));
				txtOut.print(name);
			}
			txtOut.print('\t');

			txtOut.print(p.numSamples); txtOut.print('\t');
			txtOut.print(p.xNoiseStandardDeviation); txtOut.print('\t');
			txtOut.print(p.yNoiseStandardDeviation); txtOut.print('\t');
			txtOut.print(p.dependenceMeasureID); txtOut.print('\t');
			txtOut.printf("%.9f",new Float(p.dependence)); 
			txtOut.println();
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
		 * Parse <code>args</code> and create an <code>ArgsForGenerate</code> object if they are valid. If
		 * not, throws a {@link ParseException}</code> with an exception message that should be
		 * passed to {@link #printUsage} before exiting.
		 * 
		 * @param args The command line arguments that will be parsed
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
	 * Execute the generate command.
	 * @param args The arguments to the generate command
	 * @param errOut The stream for status messages and 
	 * @param out The stream to which the generated database will be written
	 */
	@IgnoreTestCoverage
	private static void generate(String[] args, PrintWriter errOut, OutputStream out) {
		ArgsForGenerate a;
		try {
			a = new ArgsForGenerate(args);
		} catch (ArgsForGenerate.ParseException e) {
			printUsage(e.getMessage(),errOut);
			return;
		}

		Database db = new Database();
		Random rng = new Random(a.seed);
		List<DependenceMeasure> deps = allDepsButMIC();
		for(Integer sampleSize : a.sampleSizes){
			int numSamples = sampleSize.intValue();
			int numMICs = numSamples-4+1;
			for(int instNum = 0; instNum < a.numInst; ++instNum){
				DBInstance record = new DBInstance(a.relation.getId(), (float)a.xStd, (float)a.yStd, numSamples, 
						deps.size()+numMICs);
				Instance inst = newNoisyInstance(a.relation, a.xStd, a.yStd, rng, numSamples);
				
				//Record dependence measures
				int firstUnfilledDep = 0;
				
				//First record mics
				float[] mics = micScores(inst, a.clumpFactor);
				assert(numMICs == mics.length);
				for(; firstUnfilledDep < mics.length; ++firstUnfilledDep){
					record.dependenceMeasureIds[firstUnfilledDep] = firstUnfilledDep+4;
					record.dependences[firstUnfilledDep] = mics[firstUnfilledDep];
				}
				
				//Then record the rest of the dependences
				for(DependenceMeasure dm: deps){
					record.dependenceMeasureIds[firstUnfilledDep] = dm.getID();
					record.dependences[firstUnfilledDep] = dm.dependence(inst);
					++firstUnfilledDep;
				}
				db.add(record);
			}
		}
		ObjectOutputStream objOut;
		try {
			objOut = new ObjectOutputStream(out);
		} catch (IOException e) {
			errOut.println("Error: Could not open the output stream to write the database: "+e.getLocalizedMessage());
			return;
		}
		try {
			objOut.writeObject(db);
			return;
		} catch (IOException e) {
			errOut.println("Error: could not write database: "+e.getLocalizedMessage());
			return;
		}
	}

	/**
	 * Generate an instance with <code>numSamples</code> samples from the
	 * <code>relation</code> with the given noise parameters
	 * 
	 * @param relation
	 *            The relation from which the samples will be generated. Cannot
	 *            be null.
	 * @param xStd
	 *            The standard deviation of the noise added to the x coordinate.
	 *            If 0, then no noise is added. Cannot be negative.
	 * @param yStd
	 *            The standard deviation of the noise added to the y coordinate.
	 *            If 0, then no noise is added. Cannot be negative.
	 * @param rng
	 *            The random number generator used to select the samples from
	 *            the relation and to add the noise. Cannot be null.
	 * @param numSamples
	 *            The number of samples to generate from the relation. Cannot be negative.
	 * @return a new instance with <code>numSamples</code> samples from the
	 *         <code>relation</code> with the given noise parameters
	 */
	@Exemplars(set={
	@Exemplar(args={"CategoricalRel/cat01","0.0","0.0","new java/util/Random(1l)","1"}, expect={
		"java/util/Arrays.equals(retval.x,[pa:0f])",
		"java/util/Arrays.equals(retval.y,[pa:0f])"}),
	@Exemplar(args={"CategoricalRel/cat01","0.1","0.0","new java/util/Random(1l)","1"}, expect={
			"java/util/Arrays.equals(retval.x,[pa:-0.08673886f])",
			"java/util/Arrays.equals(retval.y,[pa:0f])"}),
	@Exemplar(args={"CategoricalRel/cat01","0.0","0.1","new java/util/Random(1l)","1"}, expect={
			"java/util/Arrays.equals(retval.y,[pa:-0.08673886f])",
			"java/util/Arrays.equals(retval.x,[pa:0f])"}),
	@Exemplar(args={"null","0.0","0.0","new java/util/Random(1l)","0"}, ee="NullPointerException"),
	@Exemplar(args={"CategoricalRel/cat01","0.0","0.0","null","0"}, ee="NullPointerException"),
	@Exemplar(args={"CategoricalRel/cat01","0.0","0.0","new java/util/Random(1l)","-1"}, ee="IllegalArgumentException")
	})
	private static Instance newNoisyInstance(Relation relation, double xStd, double yStd, Random rng,
			int numSamples) {
		Instance inst = relation.samples(rng, numSamples);
		addNoise(inst.x, xStd, rng);
		addNoise(inst.y, yStd, rng);
		return inst;
	}

	/**
	 * Adds zero-mean Gaussian noise with a standard deviation of std to each
	 * entry in x. If std is 0, then does nothing.
	 * 
	 * @param x
	 *            The entries to which noise will be added. Cannot be null. Will
	 *            be modified
	 * @param std
	 *            The standard deviation of the noise. Cannot be negative.
	 * @param rng
	 *            The random number generator used to generate the noise. Cannot be null
	 */
	@Exemplars(set={
	@Exemplar(args={"null","0.0","null"}, ee="NullPointerException"),
	@Exemplar(args={"[pa:1f]","-1d","null"}, ee="NullPointerException"),
	@Exemplar(args={"[pa:1f]","-1d","new java/util/Random(1l)"}, ee="IllegalArgumentException"),
	@Exemplar(args={"[pa:1f]","0d","new java/util/Random(1l)"}, e="java/util/Arrays.equals([pa:1f],$arg1)"),
	@Exemplar(args={"[pa:1f]","1d","new java/util/Random(1l)"}, e="java/util/Arrays.equals([pa:2.5615811f],$arg1)"),
	@Exemplar(args={"[pa:1f,0f]","1d","new java/util/Random(1l)"}, e="java/util/Arrays.equals([pa:2.5615811f,-0.6081826f],$arg1)"),
	@Exemplar(args={"[pa:0f]","2d","new java/util/Random(1l)"}, e="java/util/Arrays.equals([pa:3.123162f],$arg1)"),
	@Exemplar(args={"edu/wright/cs/birg/test/ArrayUtils.emptyFloat()","2d","new java/util/Random(1l)"}, e="java/util/Arrays.equals(edu/wright/cs/birg/test/ArrayUtils.emptyFloat(),$arg1)")
	})
	private static void addNoise(float[] x, double std, Random rng) {
		if(x == null){ 
			throw new NullPointerException("The x array passed to addNoise cannot be null");
		}
		if(rng == null){ 
			throw new NullPointerException("The random number generator passed to addNoise cannot be null");
		}
		if(std < 0.0){
			throw new IllegalArgumentException("The standard deviation passed to addNoise cannot be negative");
		}else if(std == 0){
			return;
		}else{
			for(int i = 0; i < x.length; ++i){
				x[i] += rng.nextGaussian()*std;
			}
			return;
		}
	}

	/**
	 * Return an array a such that a[i] is the MIC score of that instance for
	 * i+4 bins. a will have inst.getNumSamples()-4+1 entries.
	 * 
	 * @param inst
	 *            The instance for which to calculate the score. It must have at least 4 samples.
	 * @param maxClumpColumnRatio
	 *            The clump ratio used in the MIC approximation, must be greater than 0.
	 * @return an array a such that a[i] is the MIC score of that instance for
	 *         i+4 bins.
	 */
	private static float[] micScores(Instance inst, int maxClumpColumnRatio) {
		if(inst.getNumSamples() < 4){
			throw new IllegalArgumentException("The instances passed to micScores must have at least 4 samples. The instance passed had "+inst.getNumSamples());
		}
		if(maxClumpColumnRatio <= 0){
			throw new IllegalArgumentException("The clump factor passed to micScores must be greater than 0. The clump factor passed had "+maxClumpColumnRatio);
		}
		// Initialize the array of MICs to the minimum possible MIC score - 0
		float[] mic = new float[inst.getNumSamples()-4+1];
		Arrays.fill(mic, 0);
		
		// Calculate the MINE characteristic matrix
		float[][] mineMatrix = reshefMINEWrapper(inst.x, inst.y, maxClumpColumnRatio);
		
		// Fill mic with entries such that mic[i] is the maximum normalized mine
		// score for a binning with exactly i+4 bins
		for(int i = 2; i < mineMatrix.length; ++i){
			float[] row = mineMatrix[i];
			if(row == null){ continue; }
			for(int j = 2; j < row.length; ++j){
				int numBins = i*j;
				int micIndex = numBins - 4;
				if(micIndex < mic.length){
					mic[micIndex] = Math.max(mic[micIndex], row[j]);
				}
			}
		}
		
		// Recalculate the mic entries so that mic[i] is the maximum score of any
		// number of bins less than or equal to i+4, that is, it is the MIC for i+4
		// bins
		for(int i = 1; i < mic.length; ++i){
			mic[i]=Math.max(mic[i-1],mic[i]);
		}
		
		return mic;
	}

	/**
	 * Returns the relation with the short name field equal to shortName or null if there is no such relation. 
	 * @param shortName The name of the relation to return. 
	 * @return the relation with the short name field equal to shortName or null if there is no such relation.
	 */
	@Exemplars(set={
	@Exemplar(args={"null"}, expect="null"),
	@Exemplar(args={"''"}, expect="null"), 
	@Exemplar(args={"'random'"}, expect="RandomRel"), 
	@Exemplar(args={"'categorical01'"}, expect="CategoricalRel")
	})
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
	 */
	@IgnoreTestCoverage
	private static void listdeps(PrintWriter txtOut) {
		List<DependenceMeasure> measures=allDepsButMIC();
		for(DependenceMeasure m: measures){
			txtOut.print(m.getID());
			txtOut.print('\t');
			txtOut.println(m.getName());
		}
		txtOut.println("4+\tMaximal Information Coefficient (MIC) with that number of bins");
	}

	/**
	 * Return a list containing objects for all available dependence measures
	 * except MIC (which is a special case).
	 * 
	 * @return a list containing objects for all available dependence measures
	 *         except MIC (which is a special case).
	 */
	@IgnoreTestCoverage
	private static List<DependenceMeasure> allDepsButMIC() {
		List<DependenceMeasure> l = new LinkedList<DependenceMeasure>();
		l.add(new DistanceCorrelationDep());
		l.add(new SpearmanDep());
		l.add(new PearsonDep());
		return l;
	}

}
