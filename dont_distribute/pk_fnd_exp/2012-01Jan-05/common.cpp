#include "common.hpp"
#include <GClasses/GRand.h>

PeakList peaksFromPrior(GClasses::GRandMersenneTwister& rng){
  using namespace Prior;
  uint64_t numPeaks = rng.geometric(1.0/7.0);
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

std::vector<AmpAndIsPeak> ampsAndLocsFrom(const PeakList& l){
  const double width = Prior::freq_int_max - Prior::freq_int_min;
  const double min = Prior::freq_int_min;
  const double max = Prior::freq_int_max;
  const unsigned n = Prior::freq_int_num_samp;
  std::vector<AmpAndIsPeak> ret(n);
  for(unsigned i = 0; i < ret.size(); ++i){
    double x = i*(width/(n-1))+min;
    ret[i].amp = l.a(x);
    ret[i].is_peak = false;
  }
  std::vector<Peak>::const_iterator pk;
  for(pk = l.begin(); pk != l.end(); ++pk){
    double x = pk->x0();
    if(x <= min){ 
      ret.at(0).is_peak = true;
    }else if(x >= max){ 
      ret.at(ret.size()-1).is_peak = true;
    }else{
      double bin = (n-1)*(x-min)/width;
      unsigned low = bin;
      unsigned high = low+1;
      if((bin - low) < (high - bin)){
	ret.at(low).is_peak = true;
      }else{
	ret.at(high).is_peak = true;
      }
    }
  }
  return ret;
}
