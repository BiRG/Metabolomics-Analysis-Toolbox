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
import choco.cp.model.CPModel;
import choco.kernel.model.variables.integer.IntegerVariable;

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
				col[j]=data.get(i)[j];
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
	
	private static double calcMIC(SampleVariable x,
			SampleVariable y) {
		assert(x.getValues().length == y.getValues().length);
		//N is the number of samples
		final int N = x.getValues().length;
		
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
			samples[i]=new Sample(i, x.getValues()[i], y.getValues()[i]);
		}
		
		// Create the model (so I don't forget to add variables at the end, I'll add them as I create them)
		CPModel m = new CPModel();
		
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
		m.addConstraint(eq(numBins, mult(numXBins, numYBins)));
		
		// xBin[i] holds the x bin for sample i
		IntegerVariable[] xBin = new IntegerVariable[N];
		for(int i = 0; i < xBin.length; ++i){ xBin[i]=makeIntVar("xBin["+i+"]",1,b/2); }
		m.addVariables(xBin);
		
		// Constrain the samples to have x bin numbers consistent with their x ordering
		Arrays.sort(samples, new Comparator<Sample>(){ //sort by x coordinate
			public int compare(Sample l, Sample r){return (int)(r.x-l.x);}
		});
		m.addConstraint(eq(1,xBin[samples[0].id])); //First sample in bin 1
		m.addConstraint(eq(numXBins,xBin[samples[N].id]));//Last sample in last bin
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
			public int compare(Sample l, Sample r){return (int)(r.y-l.y);}
		});
		m.addConstraint(eq(1,yBin[samples[0].id])); //First sample in bin 1
		m.addConstraint(eq(numYBins,yBin[samples[N].id]));//Last sample in last bin
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
		
		// inXYBin[i][j] is the number of samples whose x value is assigned to the i-th x bin and whose y value is also
		// assigned to the j-th y bin.  Since there is no bin 0, inXYBin[0][j]=inXYBin[i][0]=null
		IntegerVariable[][] inXYBin = new IntegerVariable[b/2+1][b/2+1];
		//Assign placeholder nulls
		for(int i = 0; i <= b/2; ++i){ inXYBin[i][0]=null; inXYBin[0][i]=null; }
		//Create the variables
		for(int i = 0; i <= b/2; ++i){
			for(int j = 0; j <= b/2; ++j){
				inXYBin[i][j]=makeIntVar("inXYBin["+i+"]["+j+"]", 0, N);
				m.addVariable(inXYBin[i][j]);
				
				
				
				
				/// TODO:
				/// Add variables XYBin[i] which have (b/2)*xBin[i]+yBin[i] (thus they index into the XY array in some sense)
				/// 
				/// Then, make an occurrence constraint for each inXYBin that checks the appropriate value
				///
				
				
			}
		}
		return 0;
	}

}
