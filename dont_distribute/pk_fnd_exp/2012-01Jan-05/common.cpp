#include "common.hpp"
#include <GClasses/GRand.h>
#include <fstream>
#include <boost/archive/text_iarchive.hpp>
#include <boost/serialization/string.hpp>

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


//virtual 
std::string CountTable::name() const{
  std::vector<CountTableVariable> vars = variables();
  std::stringstream out;
  out << "[";
  std::vector<CountTableVariable>::const_iterator it;
  for(it = vars.begin(); it != vars.end(); ++it){
    if(it != vars.begin()){ out << ", "; }
    out << it->name();
  }
  out << "]";
  return out.str();
}

CountTablesForFirstExperiment::CountTablesForFirstExperiment
(std::string table_file, std::vector<UniformDiscretization> discretizations){
  //Abbreviation for number of samples
  const std::size_t ns = Prior::freq_int_num_samp;

  std::ifstream table_stream(table_file.c_str());
  if(table_stream){
    //We could read the file.  Read from the file.
    boost::archive::text_iarchive in(table_stream);
    in >> *this;
  }else{
    //The file could not be read, initialize to empty
    amp_pairs.reserve(ns-1);
    l_pairs.reserve(ns-1);
    l_amp.reserve(ns);
    for(std::size_t samp = 0; samp < ns; ++samp){
      CountTableVariable a0("a",samp,discretizations.at(samp).num_bins());
      CountTableVariable l0("l",samp,2);
      if(samp+1 < ns){
	CountTableVariable a1
	  ("a",samp+1,discretizations.at(samp+1).num_bins());
	CountTableVariable l1("l",samp+1,2);
	amp_pairs.push_back(CountTable2DSparse(a0,a1));
	l_pairs.push_back(CountTable2DDense(l0,l1));
      }
      l_amp.push_back(CountTable2DDense(l0,a0));
    }
  }
}

CountTablesForFirstExperiment::CountTablesForFirstExperiment
(std::string table_file){
  std::ifstream table_stream(table_file.c_str());
  if(table_stream){
    //We could read the file.  Read from the file.
    boost::archive::text_iarchive in(table_stream);
    in >> *this;
  }else{
    GClasses::ThrowError("Could not read table of experiment counts from the "
			 "file \"", table_file, "\"");
  }
}



bool CountTablesForFirstExperiment::is_compatible_with
(std::vector<UniformDiscretization> discretizations){
  //Abbreviation for number of samples
  const std::size_t ns = Prior::freq_int_num_samp;

  bool compatible = true;
  for(std::size_t samp = 0; samp < ns; ++samp){
    if(samp+1 < ns){
      compatible &= amp_pairs.at(samp).variables().at(0).num_vals() == 
	discretizations.at(samp).num_bins();
      compatible &= amp_pairs.at(samp).variables().at(1).num_vals() == 
	discretizations.at(samp+1).num_bins();
    }
    compatible &= l_amp.at(samp).variables().at(1).num_vals() == 
      discretizations.at(samp).num_bins();
  }

  return compatible;
}

void CountTablesForFirstExperiment::add_sample_from_prior
(GClasses::GRandMersenneTwister& rng,
 const std::vector<UniformDiscretization>& discretizations){
  //Abbreviation for number of samples
  const std::size_t ns = Prior::freq_int_num_samp;
  
  //Generate another sample
  std::vector<AmpAndIsPeak> samp = ampsAndLocsFrom(peaksFromPrior(rng));
  
  //Discretize the amplitudes and location variables
  std::vector<unsigned> amps(samp.size());
  std::vector<unsigned> locs(samp.size());
  for(unsigned i = 0; i < samp.size(); ++i){
    amps[i]=discretizations[i].bin_for(samp[i].amp);
    locs[i]=samp[i].is_peak ? 1:0;
  }
  
  
  //Add the sample to the tables
  for(unsigned i = 0; i < ns; ++i){
    if(i+1 < ns){
      amp_pairs[i].inc(amps[i],amps[i+1]);
      l_pairs[i].inc(locs[i],locs[i+1]);
    }
    l_amp[i].inc(locs[i], amps[i]);
  }
}



