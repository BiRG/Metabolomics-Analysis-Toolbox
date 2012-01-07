///\file
///
///Holds the declarations that are common among the Bayesian
///peak-finding and noise reducing suite of programs

#include <exception>
#include <vector>
#include <cmath>

#ifndef BAYES_COMMON_HPP
#define BAYES_COMMON_HPP

namespace Prior{
  ///\brief The minimum of the frequency interval
  const double freq_int_min=0;

  ///\brief The maximum of the frequency interval
  const double freq_int_max=0.05504;

  ///\brief The number of samples to make of the frequency
  const double freq_int_num_samp = 128;

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



///Thrown when there is an expected speedy exit
class expected_exception: public std::exception{
public:
  ///The exit status of the application.
  int exit_status;

  ///Create an expected exception that should cause the given
  ///exit_status to be returned from the application
  expected_exception(int exit_status):exit_status(exit_status){}
};

///\brief A Gauss-Lorentzian Peak
///
///A linear combination between a Gaussian and a Lorentzian of equal
///half height width, mode location and amplitude.
class Peak{
  ///\brief The amplitude of the peak at its mode.  Must be non-negative
  double amp;
  
  ///\brief The width of the peak at half-height
  double gamma;

  ///\brief The x location of the peak mode
  double loc;
  
  ///\brief The fraction of lorentzian in the Gauss-Lorentzian linear
  ///combination.  
  ///
  ///Must be in the interval [0, 1], which includes both 0 and 1.
  double lorentzianness;

public:
  ///\brief Construct a peak with \a loc, \a amp, \a gamma, and \a
  ///lorentzianness
  ///
  ///\param amp The amplitude of the peak at its mode
  ///
  ///\param gamma The width of the peak at half-height
  ///
  ///\param loc The x location of the peak mode
  ///  
  ///\param lorentzianness The fraction of lorentzian in the
  ///                      Gauss-Lorentzian linear combination
  Peak(double amp, double gamma, double loc, double lorentzianness):
    amp(amp), gamma(gamma), loc(loc), lorentzianness(lorentzianness) { }

  ///\brief Return the amplitude of the peak at the given x value
  ///
  ///\param x the x coordinate at which the peak's amplitude is
  ///evaluated
  ///
  ///\return the amplitude of the peak at the given x value
  inline double a(const double x) const{
    const double gammaSqToSigmaSqFactor = 
      0.1803368801111204259199905851252365171783307442691232417669;
    const double gsq = gamma * gamma;
    const double sigmaSq = gsq * gammaSqToSigmaSqFactor;
    const double dxsq = (x-loc)*(x-loc);
    return
      amp * lorentzianness * gsq / (4*dxsq+gsq) +
      amp * (1-lorentzianness) * std::exp(-dxsq/(2*sigmaSq));
  }

  ///\brief Return the frequency of the peak's mode
  double x0() const{ return loc; }
};

///\brief List of peaks 
///
///I expose the "implemented as" a vector because this is research
///code and I don't want the hassle of reimplmenting those methods
///that are appropriate in the public section and having a private
///vector member.  The coupling is too tight with an isa relationship,
///but coding time for the prototype outweights it.
class PeakList:public std::vector<Peak>{
public:
  ///\brief Create an empty PeakList object
  PeakList(){}

  ///\brief Return the amplitude of a spectrum which contains the given peaks
  ///at \a x
  ///
  ///\param x the x coordinate at which the amplitude is evaluated
  ///
  ///\return the amplitude of a spectrum which contains the given peaks
  ///at \a x
  inline double a(const double x) const{
    double sum = 0;
    for(const_iterator it=begin(); it != end(); ++it){
      sum += it->a(x);
    }
    return sum;
  }
};

namespace GClasses{  class GRandMersenneTwister; }

///\brief Returns a peak-list sampled from the prior distribution for
///the noise-filtering/peak-locating test
///
///I've hard-coded the prior distribution right now.
///
///\param rng a random number generator to be used to generate the samples
PeakList peaksFromPrior(GClasses::GRandMersenneTwister& rng);

#endif //BAYES_COMMON_HPP
