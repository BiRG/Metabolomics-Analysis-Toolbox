///\file
///
///Holds the declarations that are common among the Bayesian
///peak-finding and noise reducing suite of programs
///
///Why am I putting everything common in two files?  Because I don't
///want the complexity of having to change the dependencies in the
///makefile every time.  Nor do I feel like puting in the auto-deps
///generation.

#include <exception>
#include <vector>
#include <cmath>

//Allow boost serialization
#include <boost/archive/text_oarchive.hpp>
#include <boost/archive/text_iarchive.hpp>

#include <GClasses/GError.h>

#ifndef BAYES_COMMON_HPP
#define BAYES_COMMON_HPP


///\brief Parameters of the prior distribution
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

  friend class boost::serialization::access;

  ///\brief Serialization method - uses boost-serialize
  ///
  ///\param ar The archive to serialize to
  ///
  ///\param version the version number
  template<class Archive>
  void serialize(Archive& ar, const unsigned int /*version*/){
    ar & amp;
    ar & gamma;
    ar & loc;
    ar & lorentzianness;
  }

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

  friend class boost::serialization::access;

  ///\brief Serialization method - uses boost-serialize
  ///
  ///\param ar The archive to serialize to
  ///
  ///\param version the version number
  template<class Archive>
  void serialize(Archive& ar, const unsigned int /*version*/){
    ar & boost::serialization::base_object<std::vector<Peak> >(*this);
  }

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


///\brief The amplitude for a given spectrum frequency and whether
///that frequency was a peak
struct AmpAndIsPeak{
  ///\brief The amplitude at the frequency
  double amp;
  
  ///\brief True iff the frequency is a peak
  bool is_peak;
};

///\brief Create the samples that would be derived from measuring the
///peaks in \a l together
///
///The number of samples specified in Prior::freq_int_num_samp is used
///and the interval is that specified in Prior::freq_int_min and
///Prior::freq_int_max
std::vector<AmpAndIsPeak> ampsAndLocsFrom(const PeakList& l);

///\brief Discretizes an interval into n equal sized bins
///
///If a value lies outside of the explicitly discretized interval it
///is put into the appropriate end bin. (That is, if it is less than
///the minimum of the interval, it goes into the first bin and if it
///is greater, it goes into the last bin.)
class UniformDiscretization{
  ///\brief The minimum value of the explicitly discretized interval
  double min;
  ///\brief The maximum value of the explicitly discretized interval
  double max;
  ///\brief The number of bins to form
  unsigned m_num_bins;


  friend class boost::serialization::access;

  ///\brief Serialization method - uses boost-serialize
  ///
  ///\param ar The archive to serialize to
  ///
  ///\param version the version number
  template<class Archive>
  void serialize(Archive& ar, const unsigned int /*version*/){
    ar & min;
    ar & max;
    ar & m_num_bins;
  }

public:
  ///\brief Create a uniform discretization for the closed interval
  ///[\a min,\a max]
  ///
  ///Discretizes the interval [\a min, \a max] which includes both \a min and
  ///\a max into \a num_bins bins
  ///
  ///\param min The minimum value of the explicitly discretized
  ///           interval (must be less than max)
  ///
  ///\param max The maximum value of the explicitly discretized
  ///           interval (must be greater than min)
  ///
  ///\param num_bins The number of bins to form (must be at least 1)
  UniformDiscretization(double min, double max, unsigned num_bins):
    min(min), max(max), m_num_bins(num_bins){ 
    using GClasses::to_str; using GClasses::ThrowError;
    if(min >= max){ 
      std::string s; 
      ThrowError(s+"min >= max in UniformDiscretization (min="+to_str(min)+
		 " max="+to_str(max));
    }
    if(num_bins < 1){ 
      ThrowError("UniformDiscretization constructor called with 0 bins.  "
		 "It must have at least one bin");
    }
  }

  ///\brief Return the number of bins in this discretization
  ///\return the number of bins in this discretization
  unsigned num_bins(){ return m_num_bins; }

  ///\brief Return the index of the bin containing the given number
  ///
  ///Bin indices are zero-based
  ///
  ///\return the index of the bin containing the given number
  unsigned bin_for(double num){
    if      (num <= min){  return 0;
    }else if(num >= max){  return num_bins()-1; 
    }else{                 return num_bins()*(num-min)/(max-min);    }
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


///Thrown when there is an expected speedy exit
class expected_exception: public std::exception{
public:
  ///The exit status of the application.
  int exit_status;

  ///Create an expected exception that should cause the given
  ///exit_status to be returned from the application
  expected_exception(int exit_status):exit_status(exit_status){}
};

#endif //BAYES_COMMON_HPP
