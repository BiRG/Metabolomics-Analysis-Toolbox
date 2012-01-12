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
#include <stdint.h>

//Allow boost serialization
#include <boost/archive/text_oarchive.hpp>
#include <boost/archive/text_iarchive.hpp>
#include <boost/serialization/vector.hpp>
#include <boost/serialization/map.hpp>
#include <boost/serialization/utility.hpp>


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
  const std::size_t freq_int_num_samp = 128;

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

  ///\brief Creates an uninitialized UniformDiscretization for serialization
  UniformDiscretization(){}

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

///\brief A discrete variable counted by a CountTable
class CountTableVariable{
  ///\brief The name of this variable
  std::string m_name;

  ///\brief The number of values that this discrete variable can take
  ///on
  unsigned m_num_vals;


  friend class boost::serialization::access;

  ///\brief Serialization method - uses boost-serialize
  ///
  ///\param ar The archive to serialize to
  ///
  ///\param version the version number
  template<class Archive>
  void serialize(Archive& ar, const unsigned int /*version*/){
    ar & m_name;
    ar & m_num_vals;
  }

  ///\brief Creates an uninitialized CountTableVariable for serialization
  CountTableVariable(){}

  //this friend declaration is needed to keep the no-arg
  //CountTableVariable constructor private
  friend class CountTable2D;

public:
  ///\brief Create a CountTableVariable named \a name that can take on
  ///\a num_vals values
  ///
  ///\param name The name of the new variable
  ///
  ///\param num_vals the number of values the variable can take on
  CountTableVariable(std::string name, unsigned num_vals)
    :m_name(name), m_num_vals(num_vals){}

  ///\brief Create a CountTableVariable named \a base_name \a number that can
  ///take on \a num_vals values 
  ///
  ///To create a variable named "a1" that takes on 256 values, you
  ///call \code CountTableVariable("a",1, 256) \endcode
  ///
  ///\param base_name The base-name of the new variable
  ///
  ///\param index The index of the new variable
  ///
  ///\param num_vals the number of values the variable can take on
  CountTableVariable(std::string base_name, unsigned index, unsigned num_vals)
    :m_name(base_name+GClasses::to_str(index)), m_num_vals(num_vals){}

  ///\brief Return the name of this variable
  std::string name() const{ return m_name; }

  ///\brief Return the number of values that this discrete variable can take
  unsigned num_vals() const{ return m_num_vals; }
};

///\brief The counts of events for discrete variables
///
///I implemented a hierarchy with abstract base classes rather than
///just using the explicit classes I needed because:
///
///1. The model fits the model in my head
///
///2. It might be desirable to have collecitons of CountTable later.
///   This will be much easier if everything is already organized that
///   way.
///
///3. As long as one uses the leaf-node objects explicitly in his
///   code, the virtual functions will only provide a small memory
///   penalty and no speed penalty (since the compiler can optimize
///   those indirect calls away to direct function calls)
///
///\warning serialization through base-class pointers will require
///         explicit registration of sub-classes in the base-class
///         serialization method.  You have been warned.  (Right now
///         no subclasses are registered, so hopefully things should
///         break in a big way and be detected early before that
///         happens.)
class CountTable{

  friend class boost::serialization::access;

  ///\brief Serialization method - uses boost-serialize
  ///
  ///\param ar The archive to serialize to
  ///
  ///\param version the version number
  ///
  ///\warning serialization through base-class pointers will require
  ///         explicit registration of sub-classes in the base-class
  ///         serialization method.  You have been warned.  (Right now
  ///         no subclasses are registered, so hopefully things should
  ///         break in a big way and be detected early before that
  ///         happens.)
  template<class Archive>
  void serialize(Archive& /*ar*/, const unsigned int /*version*/){}

public:
  ///\brief True if CountTable subclasses should check the ranges of
  ///their arguments.
  const static bool do_range_checking = true;


  ///\brief Return a human-readable name for the table
  ///
  ///By default, lists the variables counted
  virtual std::string name() const;

  ///\brief Return a list of the variables counted by this table
  ///
  ///I use a vector rather than a list because we will not be adding
  ///to or deleting from this list often.
  virtual std::vector<CountTableVariable> variables() const = 0;
};

///\brief The counts of events for two discrete variables
class CountTable2D:public CountTable{
protected:
  ///\brief the first variable counted by this table
  CountTableVariable m_v1;

  ///\brief the second variale counted by this table
  CountTableVariable m_v2;

  ///\brief An ordered pair of values, the first being the value of
  ///m_v1 and the second being the value of m_v2
  typedef std::pair<unsigned,unsigned> ValuePair;


  ///\brief Create uninitialized CountTable2D
  CountTable2D(){}

  ///\brief Create a CountTalbe2D that counts the given variables
  CountTable2D(CountTableVariable v1, CountTableVariable v2)
    :m_v1(v1), m_v2(v2){}

private:
  friend class boost::serialization::access;

  ///\brief Serialization method - uses boost-serialize
  ///
  ///\param ar The archive to serialize to
  ///
  ///\param version the version number
  template<class Archive>
  void serialize(Archive& ar, const unsigned int /*version*/){
    ar & boost::serialization::base_object<CountTable>(*this);
    ar & m_v1;
    ar & m_v2;
  }

public:
  ///\brief Return a list of the variables counted by this table
  virtual std::vector<CountTableVariable> variables() const{
    std::vector<CountTableVariable> ret; ret.reserve(2);
    ret.push_back(m_v1); ret.push_back(m_v2);
    return ret;
  }

  ///\brief Return the number of occurrences of the event that the
  ///first variable == v1 and the second variable == v2
  ///
  ///\param v1 the value of the first variable
  ///
  ///\param v2 the value of the second variable
  ///
  ///\return the number of occurrences of the event that the first
  ///variable == v1 and the second variable == v2
  virtual unsigned count(unsigned v1, unsigned v2) const = 0;

  ///\brief Increment the number of occurrences of the event that the
  ///first variable == v1 and the second variable == v2
  ///
  ///\param v1 the value of the first variable
  ///
  ///\param v2 the value of the second variable
  virtual void inc(unsigned v1, unsigned v2) = 0;
};

///\brief The counts of events for two discrete variables optimized
///for memory when most counts will be 0
class CountTable2DSparse:public CountTable2D{
  ///\brief An iterator for use with the underlying count map
  typedef std::map<ValuePair, unsigned>::iterator MapIter;

  ///\brief A const_iterator for use with the underlying count map
  typedef std::map<ValuePair, unsigned>::const_iterator MapIterConst;

  ///\brief count[ValuePair] is the number of times that pair has occurred
  std::map<ValuePair, unsigned> m_count;

  friend class boost::serialization::access;

  ///\brief Serialization method - uses boost-serialize
  ///
  ///\param ar The archive to serialize to
  ///
  ///\param version the version number
  template<class Archive>
  void serialize(Archive& ar, const unsigned int /*version*/){
    ar & boost::serialization::base_object<CountTable2D>(*this);
    ar & m_count;
  }

  ///\brief Create an uninitialized table for serialization purposes
  CountTable2DSparse(){}

public:
  ///\brief Create a table that counts the joint occurrences of
  ///variables \a v1 and \a v2
  ///
  ///The table initially has no occurrences
  ///
  ///\param v1 the first variable
  ///
  ///\param v2 the second variable
  CountTable2DSparse(CountTableVariable v1, CountTableVariable v2)
    :CountTable2D(v1,v2){}

  ///\brief Return the number of occurrences of the event that the
  ///first variable == v1 and the second variable == v2
  ///
  ///\param v1 the value of the first variable
  ///
  ///\param v2 the value of the second variable  
  ///
  ///\warning no range checking is done on v1 and v2
  virtual unsigned count(unsigned v1, unsigned v2) const{
    if(do_range_checking && (v1 >= m_v1.num_vals() || v2 >= m_v2.num_vals())){
      std::string s("");
      using GClasses::to_str;
      GClasses::ThrowError(s+"Attempt to access cell out of range in the "
			   "CountTable2DSparse named:" + this->name() + 
			   ".  The indices of the cell were: "
			   "("+to_str(v1)+", "+to_str(v2)+")");
    }

    MapIterConst loc = m_count.find(ValuePair(v1,v2));
    if(loc == m_count.end()){ return 0; 
    }else{ return loc->second; }
  }

  ///\brief Increment the number of occurrences of the event that the
  ///first variable == v1 and the second variable == v2
  ///
  ///\param v1 the value of the first variable
  ///
  ///\param v2 the value of the second variable
  ///
  ///\warning no range checking is done on v1 and v2
  virtual void inc(unsigned v1, unsigned v2){
    if(do_range_checking && (v1 >= m_v1.num_vals() || v2 >= m_v2.num_vals())){
      std::string s("");
      using GClasses::to_str;
      GClasses::ThrowError(s+"Attempt to increment cell out of range in the "
			   "CountTable2DSparse named:" + this->name() + 
			   ".  The indices of the cell were: "
			   "("+to_str(v1)+", "+to_str(v2)+")");
    }
    MapIter loc = m_count.find(ValuePair(v1,v2));
    if(loc == m_count.end()){ 
      m_count.insert(std::make_pair(ValuePair(v1,v2),1));
    }else{ ++loc->second; }
  }

};


///\brief The counts of events for two discrete variables
class CountTable2DDense:public CountTable2D{
  ///\brief count[v1+v2*m_v1.num_vals] is the number of times the pair
  ///v1,v2 has occurred
  std::vector<unsigned> m_count;

  friend class boost::serialization::access;

  ///\brief Serialization method - uses boost-serialize
  ///
  ///\param ar The archive to serialize to
  ///
  ///\param version the version number
  template<class Archive>
  void serialize(Archive& ar, const unsigned int /*version*/){
    ar & boost::serialization::base_object<CountTable2D>(*this);
    ar & m_count;
  }

  ///\brief Create an uninitialized table for serialization purposes
  CountTable2DDense(){}

protected:

  ///\brief Return the index of the cell holding the count for
  ///variable 1 == v1 and variable 2 == v2
  ///
  ///\param v1 the value of variable 1 counted by the cell
  ///
  ///\param v2 the value of variable 2 counted by the cell
  ///
  ///\return the index of the cell holding the count for variable 1 ==
  ///v1 and variable 2 == v2
  std::size_t cell_idx(unsigned v1, unsigned v2) const{
    if(do_range_checking && (v1 >= m_v1.num_vals() || v2 >= m_v2.num_vals())){
      std::string s("");
      using GClasses::to_str;
      GClasses::ThrowError(s+"Attempt to access cell out of range in the "
			   "CountTable2DDense named:" + this->name() + 
			   ".  The indices of the cell were: "
			   "("+to_str(v1)+", "+to_str(v2)+")");
    }
    return v1+v2*m_v1.num_vals(); 
  }

public:
  ///\brief Create a table that counts the joint occurrences of
  ///variables \a v1 and \a v2
  ///
  ///The table initially has no occurrences
  ///
  ///\param v1 the first variable
  ///
  ///\param v2 the second variable
  CountTable2DDense(CountTableVariable v1, CountTableVariable v2)
    :CountTable2D(v1,v2),m_count(v1.num_vals()*v2.num_vals(),0){}
  
  ///\brief Return the number of occurrences of the event that the
  ///first variable == v1 and the second variable == v2
  ///
  ///\param v1 the value of the first variable
  ///
  ///\param v2 the value of the second variable  
  ///
  ///\warning no range checking is done on v1 and v2
  virtual unsigned count(unsigned v1, unsigned v2) const{
    return m_count[cell_idx(v1,v2)];
  }

  ///\brief Increment the number of occurrences of the event that the
  ///first variable == v1 and the second variable == v2
  ///
  ///\param v1 the value of the first variable
  ///
  ///\param v2 the value of the second variable
  ///
  ///\warning no range checking is done on v1 and v2
  virtual void inc(unsigned v1, unsigned v2){
    ++m_count[cell_idx(v1,v2)];
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
