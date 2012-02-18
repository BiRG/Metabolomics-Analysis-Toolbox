/**
 * 
 */
package edu.wright.cs.birg.exactmic;

import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.List;

import static choco.Choco.*;
import choco.Options;
import choco.cp.model.CPModel;
import choco.cp.solver.CPSolver;
import choco.kernel.model.variables.integer.IntegerConstantVariable;
import choco.kernel.model.variables.integer.IntegerVariable;
import choco.kernel.solver.constraints.integer.extension.BinRelation;
import choco.kernel.solver.variables.integer.IntDomainVar;

import au.com.bytecode.opencsv.CSVReader;
import au.com.bytecode.opencsv.CSVWriter;

/**
 * @author Eric Moyer
 *
 */
public class ExactMIC {

	/**
	 * @param args The command line arguments
	 */
	public static void main(String[] args) {
		if(args.length != 0){
			System.err.println("Usage: java edu.wright.cs.birg.exactmic < filename.csv > mics.csv");
			System.err.println("Prints the exact mic's for all pairs of variables in filename to stdout.");
			System.err.println("If the first line of filename is not all numeric, it is assumed to be a header line");
			return;
		}
		
		// Initialize data and header from the file (if the file has no header, one is created for it)
		List<double[]> data = null;
		String[] header = null;
		try {
			List<String[]> contents = (new CSVReader(new InputStreamReader(System.in))).readAll();
			data = new ArrayList<double[]>(contents.size());
			
			//Convert the data to double
			for(String[] line: contents){
				double[] row = new double[line.length];
				try{
					for(int i = 0; i < line.length; ++i){
						row[i]=Double.parseDouble(line[i]);
					}
					data.add(row);
					if(row.length != data.get(0).length){
						System.err.println("Error: Row "+data.size()+" in the data file had a different "+
								"number of elements from the first row.  All rows in the CSV " + 
								"must be the same length.");
					}
				} catch(NumberFormatException e){
					//Skip lines that contain things that can't be parsed as doubles
					//
					//The first unparsable line is treated as the header
					if(header==null){ header = line; }
				}
			}
			
			if(data.size()==0){
				System.err.println("Error: The CSV file must have at least one row which only contains "+
						"numeric data.  The CSV file on standard input had no such rows.  Cannot process.");
				return;
			}
			
			if(data.get(0).length==0){
				System.err.println("The CSV file has only 0-length lines.  Cannot process.");
				return;
			}
			
			// Create a header if there was none 
			if(header == null){
				header = new String[data.get(0).length];
				for(int i = 0; i < header.length; ++i){
					header[i]="Variable["+i+"]";
				}
			}
			
			// Ensure that the header is the right length by padding it with default values if necessary
			if(header.length < data.get(0).length){
				String[] oldHeader = header;
				header = new String[data.get(0).length];
				for(int i = 0; i < header.length; ++i){
					if(i < oldHeader.length){
						header[i]=oldHeader[i];
					}else{
						header[i]="Variable["+i+"]";
					}
				}
			}
		} catch (IOException e) {
			System.err.println("Error trying to parse CSV from standard input.");
			return;
		}
		
		assert(header != null && data.size() > 0 && data.get(0).length > 0);

		// vars holds the individual variables represented in the CSV file
		SampleVariable[] vars=new SampleVariable[data.get(0).length];
		for(int i=0; i < vars.length; ++i){
			double[] col = new double[data.size()];
			for(int j=0; j < data.size(); ++j){
				col[j]=data.get(j)[i];
			}
			vars[i]=new SampleVariable(header[i],col);
		}
		
		// Create the object that writes the CSV to standard output
		CSVWriter out = new CSVWriter(new OutputStreamWriter(System.out));

		// Write the output header
		String[] outputHeader = {"X Var Index","Y Var Index","X Var Name","Y Var Name","Maximal Information Coefficient"};
		out.writeNext(outputHeader);
		
		// loop through all non-identical pairs of variables, printing the results to output at each pass
		java.text.NumberFormat micFormat=java.text.NumberFormat.getInstance();
		micFormat.setGroupingUsed(false);
		micFormat.setMinimumFractionDigits(Math.min(18,micFormat.getMaximumFractionDigits()));
		for(int i = 0; i < vars.length; ++i){
			SampleVariable x=vars[i];
			for(int j = i+1; j < vars.length; ++j){
				SampleVariable y=vars[j];
				double mic = calcMIC(vars[i],vars[j]);
				String[] line = {Integer.toString(i),Integer.toString(j),
						x.getName(), y.getName(), micFormat.format(mic)
				};
				out.writeNext(line);
			}
		}
		try {
			out.close();
		} catch (IOException e) {
			System.err.println("Error closing output file.");
			e.printStackTrace();
		}
	}
	/**	The two-dimensional projection of a sample point taken from the input data.
	 *   
	 * This class mainly exists to allow easy manipulation for the calcMIC class
	 *   
	 * @author Eric Moyer
	 */
	private static class Sample{
		/** Sample number of this sample - the index into the typical arrays of samples */
		public final int id;
		/** x value of this sample */
		public final double x;
		/** y value of this sample */
		public final double y;
		/**
		 * Create a Sample with the given id, x, and y values
		 * @param id The sample number of this sample
		 * @param x The x value of this sample
		 * @param y The y value of this sample
		 */
		Sample(int id, double x, double y){ this.id = id; this.x = x; this.y = y; }
	}
	
	private static double calcMIC(SampleVariable xIn,
			SampleVariable yIn) {
		assert(xIn.getValues().length == yIn.getValues().length);
		//N is the number of samples
		final int N = xIn.getValues().length;
		
		//F is the number by which logarithms will be multiplied before rounding 
		//to give a fixed-point approximation which can be easily used in the CSP solver 
		final int F = 32768; 

		if(N*Math.log(N) >= 65536){
			System.err.println("Warning: N log N is large enough that multiplying it by "+ 
					F + " could cause integer overflow.  This may cause problems with the "+
					"optimization problem.  Proceeding to optimize anyway, double check the results if "+
					"possible. Or rewrite the solver to use a real log function :)");
		}
		
		Sample[] samples = new Sample[N];
		for(int i = 0; i < N; ++i){
			samples[i]=new Sample(i, xIn.getValues()[i], yIn.getValues()[i]);
		}
		
		// Create the model (so I don't forget to add variables at the end, I'll add them as I create them)
		CPModel m = new CPModel();
		
		// Bool used for eliminating potentially problematic code
		final boolean include = false;

		
		// b is the B parameter n^0.6 taken to the next greatest integer.  
		// b is clamped to be at least 4 (since in the paper, they start with a 2x2 grid)
		int b = Math.max(4, (int)Math.ceil(Math.pow(N, 0.6)));
		
		// numBins variable
		IntegerVariable numBins = makeIntVar("numBins: number of bins in the grid", 4, b);
		m.addVariable(numBins);
		
		// number of bins for x axis since there must be at least 2 bins on the y axis, then 
		// b/2 is the maximum number of bins that can be on this axis without its multiple 
		// by numYBins being greater than b
		IntegerVariable numXBins = makeIntVar("numXBins",2,b/2);
		m.addVariable(numXBins);
		
		// number of bins for y axis
		IntegerVariable numYBins = makeIntVar("numYBins",2,b/2);
		m.addVariable(numYBins);
		
		// Constrain number of bins on x and y axis, when multiplied == numBins
		m.addConstraint(times(numXBins, numYBins, numBins));
		

		// xBin[i] holds the x bin for sample i
		IntegerVariable[] xBin = new IntegerVariable[N];
		for(int i = 0; i < xBin.length; ++i){ xBin[i]=makeIntVar("xBin["+i+"]",1,b/2); }
		m.addVariables(xBin);
		
		// Constrain the samples to have x bin numbers consistent with their x ordering
		Arrays.sort(samples, new Comparator<Sample>(){ //sort by x coordinate
			public int compare(Sample l, Sample r){return (int)(l.x-r.x);}
		});
		m.addConstraint(eq(1,xBin[samples[0].id])); //First sample in bin 1
		m.addConstraint(eq(numXBins,xBin[samples[N-1].id]));//Last sample in last bin
		for(int i = 1; i < N; ++i){
			IntegerVariable cur = xBin[samples[i].id];
			IntegerVariable prev = xBin[samples[i-1].id];
			//If the two adjacent samples are equal, in the x dimension, they must be in the same bin, 
			//otherwise they must be in the same bin or the greater one can be in the next bin over.   
			if(samples[i].x == samples[i-1].x){
				m.addConstraint(eq(cur,prev));
			}else{
				m.addConstraint(or(eq(cur,prev),eq(cur,plus(1, prev))));
			}
		}

		// xBinSorted is just the xBin array sorted in order of increasing x value
		// Here I add another constraint (increasingNValue) that is mostly redundant on what I've already implemented, 
		// but since it is directly from the framework, may have better heuristics attached
		IntegerVariable[] xBinSorted = new IntegerVariable[N];
		for(int i = 0; i < N; ++i){
			xBinSorted[i]=xBin[samples[i].id];
		}
		m.addConstraint(increasingNValue(numXBins, xBinSorted));

		
		// yBin[i] holds the y bin for sample i
		IntegerVariable[] yBin = new IntegerVariable[N];
		for(int i = 0; i < yBin.length; ++i){ yBin[i]=makeIntVar("yBin["+i+"]",1,b/2); }
		m.addVariables(yBin);
		
		// Constrain the samples to have y bin numbers consistent with their y ordering
		Arrays.sort(samples, new Comparator<Sample>(){ //Sort by y coordinate
			public int compare(Sample l, Sample r){return (int)(l.y-r.y);}
		});
		m.addConstraint(eq(1,yBin[samples[0].id])); //First sample in bin 1
		m.addConstraint(eq(numYBins,yBin[samples[N-1].id]));//Last sample in last bin
		for(int i = 1; i < N; ++i){
			IntegerVariable cur = yBin[samples[i].id];
			IntegerVariable prev = yBin[samples[i-1].id];
			//If the two adjacent samples are equal, in the y dimension, they must be in the same bin, 
			//otherwise they must be in the same bin or the greater one can be in the next bin over.   
			if(samples[i].y == samples[i-1].y){
				m.addConstraint(eq(cur,prev));
			}else{
				m.addConstraint(or(eq(cur,prev),eq(cur,plus(1, prev))));
			}
		}
		
		// yBinSorted is just the yBin array sorted in order of increasing y value
		// Here I add another constraint (increasingNValue) that is mostly redundant on what I've already implemented, 
		// but since it is directly from the framework, may have better heuristics attached
		IntegerVariable[] yBinSorted = new IntegerVariable[N];
		for(int i = 0; i < N; ++i){
			yBinSorted[i]=yBin[samples[i].id];
		}
		m.addConstraint(increasingNValue(numYBins, yBinSorted));
		
		
		// Create the bin size variables
		
		// inXBin[i] is the number of samples whose x value is assigned to the i-th x bin. 
		// inXBin[0] is just a placeholder (and is set to null). It serves to keep the indexing uncomplicated 
		IntegerVariable[] inXBin = new IntegerVariable[b/2+1];
		inXBin[0]=null; //Assign to null so we know if I accidentally try to do something with it
		for(int i = 1; i <= b/2; ++i){
			inXBin[i]=makeIntVar("inXBin["+i+"]", 0, N);
			m.addVariable(inXBin[i]);
			//inXBin[i] is the number of xBin values that have the value i
			m.addConstraint(occurrence(inXBin[i],xBin,i));
		}

		// inYBin[i] is the number of samples whose y value is assigned to the i-th y bin.
		// inYBin[0] is just a placeholder (and is set to null). It serves to keep the indexing uncomplicated 
		IntegerVariable[] inYBin = new IntegerVariable[b/2+1];
		inYBin[0]=null; //Assign to null so we know if I accidentally try to do something with it
		for(int i = 1; i <= b/2; ++i){
			inYBin[i]=makeIntVar("inYBin["+i+"]", 0, N);
			m.addVariable(inYBin[i]);
			//inYBin[i] is the number of yBin values that have the value i
			m.addConstraint(occurrence(inYBin[i],yBin,i));
		}
		
		//Create boolean variables that are 1 if a given sample is in a given bin.
		//
		//These will be summed to count the number of samples in a given x-y bin. Note that they are non-decision 
		//variables because their state is completely determined by other decision variables
		//
		//sampleHasXY[sample][x][y] is 1 if sample is in x bin x and y bin y.  
		//Nothing is ever in bin 0, so those are placeholders
		IntegerVariable[][][] sampleHasXY = new IntegerVariable[N][b/2+1][b/2+1];
		for(int samp=0; samp < N; ++samp){
			//Set placeholders to null
			for(int i=0; i <= b/2; ++i){ sampleHasXY[samp][i][0] = sampleHasXY[samp][0][i] = null; }
			for(int x=1; x <= b/2; ++x){
				for(int y=1; y <= b/2; ++y){
					sampleHasXY[samp][x][y]=makeIntVar("sampleHasXY["+samp+"]["+x+"]["+y+"]", 0, 1, Options.V_NO_DECISION);
					m.addVariable(sampleHasXY[samp][x][y]);
					//The next constraint should be 
					//m.addConstraint(reifiedConstraint(sampleHasXY[samp][x][y],));
					//
					//But this appears to expose a bug in the solver, so I've rewritten it as
					m.addConstraint(ifThenElse(and(eq(xBin[samp],x),eq(yBin[samp],y)),
							eq(sampleHasXY[samp][x][y],1),
							eq(sampleHasXY[samp][x][y],0)));
				}
			}
			//TODO: add redundant constraints
			//We may want to add some redundant constraints here: constraints indicating that for each sample value, 
			//exactly one of the [x][y] pairs is true, constraints duplicating 
			//the constraints on cur bin = prev or prev+1.  These can potentially speed up constraint propagation.
			//Maybe even the original variables of which bin should be ignored and only these boolean variables should 
			//be in the model. 
		}

		// inXYBin[i][j] is the number of samples whose x value is assigned to the i-th x bin and whose y value is also
		// assigned to the j-th y bin.  Since there is no bin 0, inXYBin[0][j]=inXYBin[i][0]=null
		IntegerVariable[][] inXYBin = new IntegerVariable[b/2+1][b/2+1];
		//Assign placeholder nulls
		for(int i = 0; i <= b/2; ++i){ inXYBin[i][0]=null; inXYBin[0][i]=null; }
		
		
		//Create the variables
		int[] allOnes = new int[N];	for(int i = 0; i < N; ++i){ allOnes[i] = 1; };
		for(int x = 1; x <= b/2; ++x){
			for(int y = 1; y <= b/2; ++y){
				inXYBin[x][y]=makeIntVar("inXYBin["+x+"]["+y+"]", 0, N);
				m.addVariable(inXYBin[x][y]);
				
				//Set inXYBin[x][y] to the sum of the booleans for all samples that that sample is in bin x,y
				IntegerVariable[] hasXYBools = new IntegerVariable[N];
				for(int samp = 0; samp < N; ++samp){ hasXYBools[samp] = sampleHasXY[samp][x][y]; }
				assert hasXYBools.length == allOnes.length;
				m.addConstraint(equation("cp:bc",inXYBin[x][y],hasXYBools,allOnes));
			}
		}
		
		//Create the Log relation (I'll use base 2)
		BinRelation fLog2Rel;
		int[] rangeOfFLog2Rel = new int[N]; //Holds the integers that are in the range of fLog2Rel - in increasing order
		{
			int[] mins={0,fLog2(F,0)};
			int[] maxes={N,fLog2(F,N)};
			List<int[]> feasiblePairs = new ArrayList<int[]>(N+1);
			for(int i = 0; i <= N; ++i){
				int[] pair = {i, fLog2(F,i)};
				if(i >= 1){ rangeOfFLog2Rel[i-1]=fLog2(F,i); }
				feasiblePairs.add(pair);
			}
			fLog2Rel = makeBinRelation(mins, maxes, feasiblePairs, true);
		}
		
		//Check the bits required for the intermediate products again.
		double bitsRequiredForMaxProduct = 
				Math.log(N)+Math.log(rangeOfFLog2Rel[N-1])+Math.log(2*b);
		bitsRequiredForMaxProduct /= Math.log(2);
		if(bitsRequiredForMaxProduct >= 31){
			System.err.println("Warning: the upper bound estimate for one of the intermediate sums in the "+
					"fixed-point integer approximation requires "+bitsRequiredForMaxProduct+" bits. "+
					"Java integers only hold 31 bits. This could result in overflow and erroneous calculation. "+
					"The program is assuming that this won't happen and calculating anyway. But double-check the "+
					"results. Reducing F (the denominator of the fixed point fraction) could help. "+
					"F is currently "+F+".");
		}
		
		//Add variables for the logarithms of the different bin sizes
		IntegerVariable[] logInXBin = new IntegerVariable[inXBin.length];
		for(int x = 1; x <= b/2; ++x){
			logInXBin[x]=makeIntVar("logInXBin["+x+"]", rangeOfFLog2Rel); 
			m.addVariable(logInXBin[x]);
			m.addConstraint(relationPairAC(inXBin[x], logInXBin[x], fLog2Rel));
		}
		IntegerVariable[] logInYBin = new IntegerVariable[inYBin.length];
		for(int y = 1; y <= b/2; ++y){
			logInYBin[y]=makeIntVar("logInYBin["+y+"]", rangeOfFLog2Rel); 
			m.addVariable(logInYBin[y]);
			m.addConstraint(relationPairAC(inYBin[y], logInYBin[y], fLog2Rel));
		}
		assert inXYBin.length > 0;
		IntegerVariable[][] logInXYBin = new IntegerVariable[inXYBin.length][inXYBin[0].length];
		for(int i = 0; i <= b/2; ++i){ logInXYBin[0][i]=logInXYBin[i][0]=null; } //Set placeholders to null
		for(int x = 1; x <= b/2; ++x){
			for(int y = 1; y <= b/2; ++y){
				logInXYBin[x][y]=makeIntVar("logInXYBin["+x+"]["+y+"]", rangeOfFLog2Rel);
				m.addVariable(logInXYBin[x][y]);
				m.addConstraint(relationPairAC(inXYBin[x][y],logInXYBin[x][y], fLog2Rel));
			}
		}
		
		//Add product variables
		IntegerVariable[][] XYLogN = new IntegerVariable[b/2+1][b/2+1];
		IntegerVariable[][] XYLogXY = new IntegerVariable[b/2+1][b/2+1];
		IntegerVariable[][] XYLogX = new IntegerVariable[b/2+1][b/2+1];
		IntegerVariable[][] XYLogY = new IntegerVariable[b/2+1][b/2+1];
		
		//Set placeholders to null
		for(int i = 0; i <= b/2; ++i){
			XYLogN[i][0]=XYLogN[0][i]=null;
			XYLogXY[i][0]=XYLogXY[0][i]=null;
			XYLogX[i][0]=XYLogX[0][i]=null;
			XYLogY[i][0]=XYLogY[0][i]=null;
		}
		
		//Rest of constraints for product variables
		for(int x = 1; x <= b/2; ++x){
			for(int y = 1; y <= b/2; ++y){
				XYLogN[x][y] = makeIntVar("XYLogN[" +x+"]["+y+"]", 0, N*fLog2(F,N));
				XYLogXY[x][y]= makeIntVar("XYLogXY["+x+"]["+y+"]", 0, N*fLog2(F,N));
				XYLogY[x][y] = makeIntVar("XYLogY[" +x+"]["+y+"]", 0, N*fLog2(F,N));
				XYLogX[x][y] = makeIntVar("XYLogX[" +x+"]["+y+"]", 0, N*fLog2(F,N));
				m.addVariables(XYLogN[x][y],XYLogXY[x][y],XYLogX[x][y],XYLogX[x][y]);
				m.addConstraint(times(inXYBin[x][y], fLog2(F,N),       XYLogN[x][y]));
				m.addConstraint(times(inXYBin[x][y], logInXYBin[x][y], XYLogXY[x][y]));
				m.addConstraint(times(inXYBin[x][y], logInXBin[x],     XYLogX[x][y]));
				m.addConstraint(times(inXYBin[x][y], logInYBin[y],     XYLogY[x][y]));
			}
		}
		
		IntegerVariable[] allProductVars = new IntegerVariable[4*(b/2)*(b/2)];
		int[] productVarsCoeffs = new int[allProductVars.length];
		for(int x = 1; x <= b/2; ++x){
			for(int y = 1; y <= b/2; ++y){
				int offset = 4*((x-1)*b/2+(y-1));
				allProductVars   [offset+0]=XYLogN[x][y];
				productVarsCoeffs[offset+0]=1;
				allProductVars   [offset+1]=XYLogXY[x][y];
				productVarsCoeffs[offset+1]=1;
				allProductVars   [offset+2]=XYLogX[x][y];
				productVarsCoeffs[offset+2]=-1;
				allProductVars   [offset+3]=XYLogY[x][y];
				productVarsCoeffs[offset+3]=-1;
			}
		}
		
		//Unscaled MutInf is the sum of all the product variables multiplied by their particular coefficients
		//
		//If you divide by N you get the Mutual Information expressed in F-denominator fixed point.
		IntegerVariable unscaledMutInf = makeIntVar("unscaledMutInf", 0, N*fLog2(F,b));
		m.addVariable(unscaledMutInf);
		m.addConstraint(equation(unscaledMutInf, allProductVars, productVarsCoeffs));
		
		//Mutual information is the unscaled MutInf divided by N expressed in F-denominator fixed point
		IntegerConstantVariable NVar = constant(N); //N as a variable in the model
		IntegerVariable mutualInf = makeIntVar("mutualInformation", 0, fLog2(F,b));
		m.addVariable(mutualInf);
		m.addConstraint(intDiv(unscaledMutInf, NVar, mutualInf));
		
		//Minimum Grid Dimension expressed in F-denominator fixed point
		IntegerVariable minGridDim = makeIntVar("minimumGridDimension",0,b/2);
		m.addVariable(minGridDim);
		m.addConstraint(min(numXBins, numYBins, minGridDim));
		
		//Take the log of the minimum grid dimension
		IntegerVariable logMinGridDim = makeIntVar("logMinimumGridDimension", rangeOfFLog2Rel);
		m.addVariable(logMinGridDim);
		m.addConstraint(relationPairAC(minGridDim,logMinGridDim, fLog2Rel));
		
		//MIC is the mutual information divided by the log of the minimum grid dimension
		IntegerVariable mic = makeIntVar("mic",0,F);
		m.addVariable(mic);
		
		
		m.addConstraint(intDiv(mutualInf,logMinGridDim,mic));
		
		
		//Solve the optimization problem
		CPSolver s = new CPSolver();
		s.read(m);
		Boolean result = s.maximize(s.getVar(mic), false);
		if(result == null){
			System.err.println("Error: A search limit was reached without finding a solution for variables "+
					xIn.getName()+ " and " + yIn.getName());
		}else if(result == Boolean.FALSE){
			System.err.println("Error: No feasible solution was found for the constraint problem with variables "+
					xIn.getName()+ " and " + yIn.getName()); 
			System.err.println("The solver is:"+s.pretty());
			
			System.err.println("#######################################");
			System.err.println("########## Empty domain vars ##########");
			System.err.println("#######################################");
			final int numVars = s.getNbIntVars();
			for(int i = 0; i < numVars; ++i){
				IntDomainVar v = s.getIntVar(i);
				if(v.getDomainSize()==0){
					System.err.println(v.pretty());
				}
			}
						
			
		}
		
		//TODO: recalculate the MIC for the chosen grid and binning using the set cardinality 
		//variables (inXYBin[][] etc.) and floating point to get better resolution than just the 
		//fixed point approximation
		double micFixed = (double)s.getVar(mic).getVal();
		
		return micFixed/F;
	}
	/**
	 * Return a fixed point integer representation of a modified log function base 2.
	 * 
	 * Return Round(F * log n / log 2), that is, the logarithm base 2, multiplied by F and then rounded to
	 * the nearest integer. If divided by F, this will give the true logarithm accurate to +/- 1/F.
	 * 
	 * I modify the log function so log(0) = 0 (rather than -infinity as would be the normal representation)  
	 * since I will be using this function in information-theoretic contexts
	 * 
	 * @param F The denominator of the fixed point representation.  Divide by F to get the actual logarithm.
	 * @param n The number whose logarithm will be taken
	 * @return Round(F * log n / log 2) if n != 0 or 0 if n == 0
	 * 
	 * @throws IllegalArgumentException if n < 0
	 */
	private static int fLog2(int F, int n) throws IllegalArgumentException {
		if(n < 0){ throw new IllegalArgumentException("You can't take the log of a negative number."); }
		if(n > 0){
			return 0;
		}else{
			return 0;
		}
	}

}
