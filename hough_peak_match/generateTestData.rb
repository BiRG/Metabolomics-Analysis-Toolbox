#!/usr/bin/ruby

# Returns a stream of normally distributed random numbers through the
# next method - they have 0 mean and unit standard deviation
#
# Note: if you change the global random number generator seed, make a
# new GaussianGenerator object as well to ensure that you get a
# repeatable stream of numbers.
class GaussianGenerator 
  # Creates a GaussianGenerator 
  def initialize()
    @cache = []
  end

  # Return a normally distributed random deviate with the given mean
  # and standard deviation.  Note that a standard deviation of 0
  # returns a constant value -- the mean.
  def next(mean=0, standard_deviation=1)
    return basic_next()*standard_deviation+mean
  end

private
  # Return the next gaussian random number (mean 0, standard deviation 1)
  def basic_next()
    if @cache.empty? 
      x1 = x2 = w = 0
      begin
        x1 = 2.0 * rand - 1.0
        x2 = 2.0 * rand - 1.0
        w = x1 * x1 + x2 * x2
      end while ( w >= 1.0 )
    
      w = Math.sqrt( (-2.0 * Math.log( w ) ) / w )
      y1 = x1 * w
      y2 = x2 * w
      @cache.unshift(y2)
      return y1
    else
      return @cache.shift
    end
  end


end

require 'generator' #For SyncEnumerator

#Represents a DetectedPeakGroup
class DetectedPeakGrop
  def initialize(groupId, ppm, params)
    @groupId, @ppm, @params=groupId, ppm, params
  end
  
  def to_s
    "detected_peak_group #{@id} #{@ppm} #{@params.join(' ')}"
  end
end

#Represents a Parameterized Peak Group in the hough tools database
class ParameterizedPeakGroup
  attr_reader :id, :ppm, :params

  #Create a PeakGroup whose center is in the range [0,centerMax) and
  #with peak reaction coefficients drawn independently from Normal
  #distributions with mean 0 and standard deviations given by the
  #array
  def initialize(id, centerMax, standardDeviations)
    g = GaussianGenerator.new
    @id = id
    @ppm = centerMax * rand
    @params = standardDeviations.map {|sd| g.next(0,sd)}
  end

  def to_s
    "parameterized_peak_group #{@id} #{@ppm} #{@params.join(' ')}"
  end

  #Returns a copy changed to a detected peak group
  def to_detectedPeakGroup
    DetectedPeakGroup.new(@id,@ppm,@params)
  end
end

class Sample
  attr_reader :id, :sampClass
  def initialize(id, sampClass)
    @id = id
    @sampClass = sampClass
  end

  def to_s
    "sample #{@id} #{@sampClass}"
  end
end

class SampleParams
  attr_reader :id, :params
  def initialize(id, params)
    @id = id
    @params = params
  end

  def to_s
    "sample_params #{@id} #{@params.join(' ')}"
  end
end

#Represents the combination of a sample and sample_params object.  I
#implement it this way to make the ID common
class ParameterizedSample
  attr_reader :id, :sampClass, :params
  
  #Create a sample with its parameters
  def initialize(id, sampClass, standardDeviations)
    g = GaussianGenerator.new
    @id = id
    @sampClass = sampClass
    @params = standardDeviations.map {|sd| g.next(0,sd)}
  end

  #Construct a sample object representing the sample portion of
  #this Parameterized sample
  def to_sample
    Sample.new(@id,@sampClass)
  end

  #Construct a sample object representing the sampleParams portion of
  #this Parameterized sample
  def to_sample_params
    SampleParams.new(@id,@params)
  end
end

class HumanVerifiedPeak
  def initialize(sampleId, id, ppm, groupId)
    @sampleId, @id, @ppm, @groupId=sampleId, id, ppm, groupId
  end

  def to_s
    "human_verified_peak #{@sampleId} #{@id} #{@ppm} #{@groupId}"
  end  
end

class UnknownPeak
  def initialize(sampleId, id, ppm)
    @sampleId, @id, @ppm=sampleId, id, ppm
  end

  def to_s
    "unknown_peak #{@sampleId} #{@id} #{@ppm}"
  end  
end

class UnverifiedPeak
  #Create an unverified peak in the given sample and peak_group whose
  #location is perturbed by 0-mean Gaussian noise with the given
  #standard deviation.  0 standard deviation = no noise
  def initialize(peakId, sampleParams, parameterizedPeakGroup, noiseStdDev)
    g = GaussianGenerator.new
    @ppm = dot(sampleParams.params,parameterizedPeakGroup.params) + 
      parameterizedPeakGroup.ppm + g.next(0,noiseStdDev)
    @id = peakId
    @groupId = parameterizedPeakGroup.id
    @sampleId = sampleParams.id
  end

  def to_s
    "unverified_peak #{@sampleId} #{@id} #{@ppm} #{@groupId}"
  end

  def to_human_verified
    HumanVerifiedPeak.new(@sampleId, @id, @ppm, @groupId)
  end

  def to_unknown
    UnknownPeak.new(@sampleId, @id, @ppm)
  end

  private
  def dot(v1,v2)
    e = SyncEnumerator.new(v1,v2);
    sum = 0
    e.each {|pair| 
      sum+= pair[0]*pair[1] }
    sum
  end
end

class ParamStats
  #Creates a paramStats object for parameter lists that are
  #independent Gaussians with the given standard deviations
  #
  #NOTE: right now I am assuming that things will work out nicely even
  #after multiplying and then taking the PCA -- if my test fails, I
  #can double check what the true fractions of variance should be
  def initialize(standardDeviations)
    sumSq = standardDeviations.inject(0){| sumsq, x| sumsq+x*x }
    @fracVars = standardDeviations.map {|sd| sd*sd/sumSq}
  end

  def to_s
    "param_stats #{@fracVars.join(' ')}"
  end
end


def basic_completed_db(num_peaks, num_samples,
                       ppm_max, peak_param_std_devs, peak_noise, 
                       sample_param_std_devs)
  lastId = 0
  peak_groups = (1..num_peaks).to_a.map do  
    lastId += 1
    ParameterizedPeakGroup.new(lastId, ppm_max, peak_param_std_devs)
  end

  paramd_samples = (1..num_samples).to_a.map do 
    lastId += 1
    ParameterizedSample.new(lastId, 1, sample_param_std_devs)
  end

  sample_params_objs = paramd_samples.map { |obj| obj.to_sample_params }

  sample_objs = paramd_samples.map { |obj| obj.to_sample }
 
  unverified_peaks = (sample_params_objs.map do |sample_params|
    peak_groups.map do |peak_group|
      lastId += 1
      UnverifiedPeak.new(lastId, sample_params, peak_group, peak_noise)
    end
  end).flatten

  #Return everything mashed into one big array
  peak_groups+sample_params_objs+sample_objs+unverified_peaks+
    [ParamStats.new(sample_param_std_devs)]
end

if ARGV.length != 3
  puts <<-EOT
  Usage: generateTestData numPeaks numSamples numParams
  
  Writes a test database with all peaks being known and a minimal set of 
  peak groups.  Each parameter both in the peaks and samples is drawn from 
  a distribution having unit standard deviation and the peaks themselves 
  are generated with no noise.
  EOT

else
  numPeaks, numSamples, numParams = ARGV.map { |arg| arg.to_i }

  puts <<EOT
# Basic test data: all peaks are known and unverified, #{numPeaks} peaks
# #{numSamples} samples, and #{numParams} parameters in both the peaks and the 
# samples.
#
# The peaks are generated uniformly in the interval 0..11 and their
# reaction parameters are all zero-mean unit width Gaussians.  The
# sample parameters are also zero-mean unit width Gaussians.  All
# parameters are chosen independently.
#
# The peak group and sample parameters explain the peak locations
# commpletely, there is no noise.
#
# The blank line below serves as separating white-space and also
# helps test that the program ignores blank lines

EOT

  basic_completed_db(numPeaks, numSamples, 11, 
                     [1]*numParams, 0, [1]*numParams).each do |obj|
    puts(obj.to_s+"\n")
  end
end
