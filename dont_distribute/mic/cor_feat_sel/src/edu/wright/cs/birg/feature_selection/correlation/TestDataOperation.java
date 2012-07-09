/**
 * 
 */
package edu.wright.cs.birg.feature_selection.correlation;

import java.io.IOException;

import au.com.bytecode.opencsv.CSVReader;
import edu.wright.cs.birg.CSVUtil;
import edu.wright.cs.birg.mic.MIC;
import edu.wright.cs.birg.test.ArrayUtils;

/**
 * Generates test data for use in validating my MIC implementation
 * @author Eric Moyer
 *
 */
public class TestDataOperation extends Operation {

	/**
	 * Create a TestDataOperation that was passed the given args on the command line
	 * @param args the command line arguments given to this operation
	 */
	public TestDataOperation(String[] args) {
		if(args.length > 0){
			printUsage("Error: the testData operation takes no arguments");
			System.exit(-1); return;
		}
		
	}

	/* (non-Javadoc)
	 * @see java.lang.Runnable#run()
	 */
	@Override
	public void run() {
		CSVReader in = stdinAsCSV();
		
		//Read in the 2d array from the test file
		double[][] data;
		try{
			data = CSVUtil.csvToMatrix(in).entries;
		}catch(java.text.ParseException e){
			System.err.println("Error parsing input csv file as a matrix:" + e.getMessage());
			System.exit(-1); return;
		} catch (IOException e) {
			System.err.println("Error reading input csv file:" + e.getMessage());
			System.exit(-1); return;
		}
		if(data.length <= 0){ return; }
		
		double[][] vars = new double[data[0].length][data.length];
		for(int i = 0; i < vars.length; ++i){
			for(int j=0; j < data.length; ++j){
				vars[i][j]=data[j][i];
			}
		}
		for(int i = 0; i < vars.length; ++i){
			double[] x = vars[i];
			for(int j = i+1; j < vars.length; ++j){
				double[] y = vars[j];
				for (int numBins = 4; numBins <= x.length; ++numBins) {
					double clumpRatio = 15; //Later vary this
					double[][] result = MIC.testApproxMatrix(x, y, numBins,
							clumpRatio);
					System.out.println("@Exemplar(a={"
							+ ArrayUtils.qExemplar(x) + ","
							+ ArrayUtils.qExemplar(y) + ",\"" + numBins
							+ "\",\"" + clumpRatio + "\"},e={\"#=(retval,"
							+ ArrayUtils.exemplarString(result) + ")\"}),");

				}
			}
		}
	}

}
