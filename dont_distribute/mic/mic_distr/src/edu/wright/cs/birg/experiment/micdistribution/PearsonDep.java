/**
 * 
 */
package edu.wright.cs.birg.experiment.micdistribution;

/**
 * @author Eric Moyer
 *
 */
public final class PearsonDep implements DependenceMeasure {

	/* (non-Javadoc)
	 * @see edu.wright.cs.birg.experiment.micdistribution.DependenceMeasure#getID()
	 */
	@Override
	public int getID() {
		return 3;
	}

	/* (non-Javadoc)
	 * @see edu.wright.cs.birg.experiment.micdistribution.DependenceMeasure#getName()
	 */
	@Override
	public String getName() {
		return "Pearson product-moment correlation coefficient";
	}

	/* (non-Javadoc)
	 * @see edu.wright.cs.birg.experiment.micdistribution.DependenceMeasure#dependence(edu.wright.cs.birg.experiment.micdistribution.Instance)
	 */
	@Override
	public float dependence(Instance inst) {
		return PearsonDep.valueOf(inst);
	}

	/**
	 * Return the sample Pearson product-moment correlation coefficient for the given instance.
	 * This is a public static method so it can be used by the Spearman correlation. 
	 * @param inst The instance whose correlation is to be measured. Must have at least 2 samples.
	 * @return the sample Pearson product-moment correlation coefficient for the given instance
	 */
	public static float valueOf(Instance inst){
		double mx = mean(inst.x);
		double my = mean(inst.y);
		double sx = std(inst.x, mx);
		double sy = std(inst.y, my);
		double sum = 0;
		for(int i = 0; i < inst.getNumSamples(); ++i){
			double x = inst.x[i];
			double y = inst.y[i];
			sum += ((x-mx)/sx)*((y-my)/sy);
		}
		return (float)sum/(inst.getNumSamples()-1);
	}

	/**
	 * Return the sample standard deviation of the values in the x array. 
	 * The standard deviation of an empty array is 0.
	 * @param x The values whose standard deviation will be calculated.
	 * @param mean The mean of the x array
	 * @return the sample standard deviation of the values in the x array.
	 */
	private static double std(float[] x, double mean) {
		double sum = 0;
		for(float val:x){
			double dx = val-mean;
			sum += dx*dx;
		}
		return sum/(x.length-1);
	}

	/**
	 * Return the mean of the values in the x array. The mean of an empty array is 0.
	 * @param x The values whose mean will be calculated
	 * @return the mean of the values in the x array
	 */
	private static double mean(float[] x) {
		double sum = 0;
		for(float val:x){
			sum += val;
		}
		return sum/x.length;
	}
}
