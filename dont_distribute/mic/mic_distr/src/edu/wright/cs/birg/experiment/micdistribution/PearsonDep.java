/**
 * 
 */
package edu.wright.cs.birg.experiment.micdistribution;

import org.sureassert.uc.annotation.Exemplar;
import org.sureassert.uc.annotation.Exemplars;

/**
 * Absolute value of Pearson coefficient
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
		return "Absolute value of Pearson product-moment correlation coefficient";
	}

	/* (non-Javadoc)
	 * @see edu.wright.cs.birg.experiment.micdistribution.DependenceMeasure#dependence(edu.wright.cs.birg.experiment.micdistribution.Instance)
	 */
	@Override
	@Exemplars(set={
	@Exemplar(args={"null"}, ee="NullPointerException"),
	@Exemplar(args={"Instance/i0_0"}, ee="IllegalArgumentException"), 
	@Exemplar(args={"Instance/i01_10"}, e="1f"),
	@Exemplar(args={"Instance/i012_120"}, e="0.5f"),
	@Exemplar(args={"Instance/i0123_1032"}, e="0.6f"),
	@Exemplar(args={"Instance/i01234_34330"}, e="0.72980046f")
	})
	public float dependence(Instance inst) {
		return Math.abs(PearsonDep.valueOf(inst));
	}

	/**
	 * Return the sample Pearson product-moment correlation coefficient for the given instance.
	 * This is a public static method so it can be used by the Spearman correlation. 
	 * @param inst The instance whose correlation is to be measured. Must have at least 2 samples. Cannot be null.
	 * @return the sample Pearson product-moment correlation coefficient for the given instance
	 */
	@Exemplars(set={
	@Exemplar(args={"null"}, ee="NullPointerException"),
	@Exemplar(args={"Instance/i0_0"}, ee="IllegalArgumentException"), 
	@Exemplar(args={"Instance/i01_10"}, e="-1f"),
	@Exemplar(args={"Instance/i012_120"}, e="-0.5f"),
	@Exemplar(args={"Instance/i0123_1032"}, e="0.6f"),
	@Exemplar(args={"Instance/i01234_34330"}, e="-0.72980046f")
	})
	public static float valueOf(Instance inst){
		if(inst.getNumSamples() < 2){
			throw new IllegalArgumentException("Instances passed to Pearson.valueOf must have at least two samples.");
		}
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
		double norm = inst.getNumSamples()-1;
		return (float)(sum/(norm*norm));
	}

	/**
	 * Return the sample standard deviation of the values in the x array. 
	 * The standard deviation of an empty array and of one with one element is 0.
	 * @param x The values whose standard deviation will be calculated.
	 * @param mean The mean of the x array
	 * @return the sample standard deviation of the values in the x array.
	 */
	@Exemplars(set={
	@Exemplar(args={"null","0d"}, ee="NullPointerException"),
	@Exemplar(args={"edu/wright/cs/birg/test/ArrayUtils.emptyFloat()","1d"}, expect="0.0"),
	@Exemplar(args={"[pa:1.0f]","1d"}, expect="0.0"),
	@Exemplar(args={"[pa:1.0f,2.5f]","1.75"}, expect="1.0606601717798213")
	})
	private static double std(float[] x, double mean) {
		double sum = 0;
		for(float val:x){
			double dx = val-mean;
			sum += dx*dx;
		}
		if(x.length > 1){
			return Math.sqrt(sum)/(x.length-1);
		}else{
			return 0;
		}
	}

	/**
	 * Return the mean of the values in the x array. The mean of an empty array is 0.
	 * @param x The values whose mean will be calculated. Can't be null
	 * @return the mean of the values in the x array
	 */
	@Exemplars(set={
	@Exemplar(args={"null"}, ee="NullPointerException"),
	@Exemplar(args={"edu/wright/cs/birg/test/ArrayUtils.emptyFloat()"}, expect="0.0"),
	@Exemplar(args={"[pa:1.0f]"}, expect="1.0"),
	@Exemplar(args={"[pa:1.0f,2.5f]"}, expect="1.75")
	})
	private static double mean(float[] x) {
		double sum = 0;
		for(float val:x){
			sum += val;
		}
		if(x.length == 0){ 
			return 0;
		}else{
			return sum/x.length;
		}
	}
}
