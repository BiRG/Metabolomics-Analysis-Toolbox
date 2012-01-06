#include "common.hpp"
#include <GClasses/GRand.h>

namespace{
  ///\brief The minimum of the frequency interval
  const double freq_int_min=0;

  ///\brief The maximum of the frequency interval
  const double freq_int_max=0.05504;

  ///\brief The mean amplitude of the peaks generated
  const double mean_height=0.0668214984275779;

  ///\brief The shape parameter for the gamma parameter's gamma distribution
  const double gamma_shape = 5.639291438052089;

  ///\brief The scale parameter for the gamma parameter's gamma distribution
  const double gamma_scale = 0.0005038283197638329;

  ///\brief The minimum of the allowable lorentziannesses
  const double min_lorentzianness=0;

  ///\brief The maximum of the allowable lorentziannesses
  const double max_lorentzianness=1;

}

PeakList peaksFromPrior(GClasses::GRandMersenneTwister& rng){
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
