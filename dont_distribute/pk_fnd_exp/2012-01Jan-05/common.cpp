#include "common.hpp"
#include <GClasses/GRand.h>

PeakList peaksFromPrior(GClasses::GRandMersenneTwister& rng){
  using namespace Prior;
  uint64_t numPeaks = rng.geometric(1/7);
  //Technically, this makes it not a geometric distribution anymore,
  //but it also ensures that we will always have enough memory for our
  //list of peaks
  if(numPeaks > 100000){ numPeaks = 100000; }
  PeakList ret;
  ret.reserve(numPeaks);
  for(uint64_t i = 0; i < numPeaks; ++i){
    Peak pk
      (rng.exponential()*mean_height,
       rng.gamma(gamma_shape)*gamma_scale,
       rng.uniform(freq_int_min, freq_int_max),
       rng.uniform(min_lorentzianness, max_lorentzianness)
       );
	    
    ret.push_back(pk);
  }
  return ret;
}
