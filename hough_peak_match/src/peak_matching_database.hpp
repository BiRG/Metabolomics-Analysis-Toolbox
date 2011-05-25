///\file
///\brief Declares the PeakMatchingDatabaseClass

#ifndef HOUGH_PEAK_MATCH_PEAK_MATCHING_DATABASE
#define HOUGH_PEAK_MATCH_PEAK_MATCHING_DATABASE
#include <iostream>
#include <vector>
#include <memory> //auto_ptr

#include "parameterized_peak_group.hpp"
#include "detected_peak_group.hpp"
#include "human_verified_peak.hpp"
#include "unverified_peak.hpp"
#include "unknown_peak.hpp"
#include "file_format_sample.hpp"
#include "file_format_sample_params.hpp"
#include "param_stats.hpp"

///\brief Holds all the library classes and functions for the Hough
///\brief peak matching prototype
///
///Note: this documentation block is in peak_matching_database.hpp
namespace HoughPeakMatch{

  ///Common database for the Hough peak matching tools

  ///The Hough peak matching executables work on a common data object
  ///model whose relationships are shown in the following
  ///diagram. (Arrows denote is_a/subclass relationship pointing from
  ///the subclass to the superclass.)
  ///
  ///One constraint that is not drawn in the diagram is that the
  ///parameter vectors in sample params objects and in peak group
  ///objects must have the same dimension.
  ///
  ///\image html hough_peak_match_database_object_model.png
  ///
  ///The PeakMatchingDatabase object encapsulates this database.  It
  ///allows reading, writing, and manipulating the databases as well
  ///as transforming them into structures that are more appropriate
  ///for direct computation.
  ///
  ///All of the peak matching documents use a
  ///\ref file_format_docs "common file format"
  class PeakMatchingDatabase{
    ///All ParameterizedPeakGroup objects in this database
    std::vector<ParameterizedPeakGroup> parameterized_peak_groups_;

    ///All DetectedPeakGroup objects in this database
    std::vector<DetectedPeakGroup> detected_peak_groups_;

    ///All HumanVerifiedPeak objects in this database
    std::vector<HumanVerifiedPeak> human_verified_peaks_;

    ///All UnverifiedPeak objects in this database
    std::vector<UnverifiedPeak> unverified_peaks_;

    ///All UnknownPeak objects in this database
    std::vector<UnknownPeak> unknown_peaks_;

    ///All FileFormatSample objects in this database
    std::vector<FileFormatSample> samples_;

    ///All FileFormatSampleParams objects in this database
    std::vector<FileFormatSampleParams> sample_params_;

    ///All ParamStats objects in this database
    std::vector<ParamStats> param_stats_;
  public:
    ///\brief Create an empty PeakMatchingDatabase
    PeakMatchingDatabase():
      parameterized_peak_groups_(),detected_peak_groups_(),
      human_verified_peaks_(),unverified_peaks_(),unknown_peaks_(),
      samples_(),sample_params_(),param_stats_(){}

    ///\brief Read database from the given stream replacing current contents
    ///
    ///The stream should contain a database in the 
    ///\ref file_format_docs "peak match tool common file format"
    ///
    ///\param in the stream to read the new contents from.
    ///
    ///\return true on success and false on failure.  On failure the
    ///database will be empty
    bool read(std::istream& in);

    ///\brief Remove all objects from the database
    void make_empty();

    ///\brief Return true if the database satisfies its constraints,
    ///\brief false otherwise
    ///
    ///There are a number of constraints the database must satisfiy to
    ///be in a consistent state.  For example: all sample_id's refered
    ///to by sample_params objects must be present in exactly one
    ///sample object; all sample_params, parameterized_peak_group,
    ///detected_peak_group, and param_statistics objects must have the
    ///same number of parameters; there cannot be two param_stats
    ///objects in the database; and many more.
    ///
    ///This function returns true if they are all satisfied and false
    ///if there is an unsatisifed constraint.
    ////
    ///\return true if the database satisfies its constraints,
    ///false otherwise
    bool satisfies_constraints();

#if 0
    ///\brief Returns an auto_pointer to a newly allocated copy of the peak
    ///\brief object specified by peak_id
    ///
    ///I use an auto-pointer to a heap allocated copy so one can
    ///downcast the resulting pointer (use auto_ptr_dynamic_cast from
    ///utils.hpp)
    ///
    ///\param sample_id the id of the sample containing the peak to
    ///copy
    ///
    ///\param peak_id the id of the peak to copy within its sample
    ///
    ///\return An auto_pointer to a newly allocated copy of the peak
    ///object specified by peak_id or to null if there is no such peak
    std::auto_ptr<Peak> peak_copy_from_id(unsigned sample_id, unsigned peak_id) const;

#endif

    ///\brief Returns an auto_pointer to a newly allocated copy of the
    ///\brief sample_params object specified by sample_id
    ///
    ///I use an auto-pointer to a heap allocated copy because it makes
    ///it easy to return null and also to ensure that the object's
    ///deletion semantics are obvious
    ///
    ///\param sample_id the id of the sample the copied sample_params describes
    ///
    ///\return An auto_pointer to a newly allocated copy of the
    ///sample_params object specified by sample_id or to null if there
    ///is no such object
    std::auto_ptr<FileFormatSampleParams> sample_params_copy_from_id(unsigned sample_id) const;

    ///\brief Returns an auto_pointer to a newly allocated copy of the
    ///\brief peak_group object specified by peak_group_id
    ///
    ///I use an auto-pointer to a heap allocated copy because it makes
    ///it easy to return null and also to ensure that the object's
    ///deletion semantics are obvious.  It also allows down-casting to
    ///the appropriate peak-group object type.
    ///
    ///\param peak_group_id the id of the peak-group to copy
    ///
    ///\return An auto_pointer to a newly allocated copy of the
    ///peak_group object specified by peak_group_id or to null if there
    ///is no such object
    std::auto_ptr<PeakGroup> peak_group_copy_from_id(unsigned peak_group_id) const;

    ///\brief Returns an auto_pointer to a newly allocated copy of the
    ///\brief sample object specified by sample_id
    ///
    ///I use an auto-pointer to a heap allocated copy because it makes
    ///it easy to return null and also to ensure that the object's
    ///deletion semantics are obvious
    ///
    ///\param sample_id the id of the sample the copied sample describes
    ///
    ///\return An auto_pointer to a newly allocated copy of the
    ///sample object specified by sample_id or to null if there
    ///is no such object
    std::auto_ptr<FileFormatSample> sample_copy_from_id(unsigned sample_id) const;

    ///\brief Return all ParameterizedPeakGroup objects in this database
    ///\return all ParameterizedPeakGroup objects in this database
    const std::vector<ParameterizedPeakGroup>& 
    parameterized_peak_groups() const {
      return parameterized_peak_groups_;
    }

    ///\brief Return all DetectedPeakGroup objects in this database
    ///\return all DetectedPeakGroup objects in this database
    const std::vector<DetectedPeakGroup>& detected_peak_groups() const {
      return detected_peak_groups_;
    }

    ///\brief Return all HumanVerifiedPeak objects in this database
    ///\return all HumanVerifiedPeak objects in this database
    const std::vector<HumanVerifiedPeak>& human_verified_peaks() const {
      return human_verified_peaks_;
    }

    ///\brief Return all UnverifiedPeak objects in this database
    ///\return all UnverifiedPeak objects in this database
    const std::vector<UnverifiedPeak>& unverified_peaks() const {
      return unverified_peaks_;
    }

    ///\brief Return all UnknownPeak objects in this database
    ///\return all UnknownPeak objects in this database
    const std::vector<UnknownPeak>& unknown_peaks() const {
      return unknown_peaks_;
    }

    ///\brief Return all FileFormatSample objects in this database
    ///\return all FileFormatSample objects in this database
    const std::vector<FileFormatSample>& samples() const {
      return samples_;
    }

    ///\brief Return all FileFormatSampleParams objects in this database
    ///\return all FileFormatSampleParams objects in this database
    const std::vector<FileFormatSampleParams>& sample_params() const {
      return sample_params_;
    }

    ///\brief Return all ParamStats objects in this database
    ///\return all ParamStats objects in this database
    const std::vector<ParamStats>& param_stats() const {
      return param_stats_;
    }

  };


  ///\brief Returns the given database or aborts with an appropriate message
  ///
  ///Either returns the result of successfully reading and opening the
  ///given database file or executes printUsageAndExit with an
  ///appropriate error message.  On an error, does not return.
  ///
  ///\param file_name the name of the file to read the database from
  ///
  ///\param which_db A user-level identifier for the database that would
  ///fit in the blank in this sentence: <code> ERROR: Could not open
  ///____ database "db_filename.db" </code>
  ///
  ///\param print_error_and_exit a function that never returns
  ///(because it aborts the program) and takes a single string
  ///parameter with an error message to print.  A good candiate would
  ///be the print_usage_and_exit methods in most programs.  You should
  ///be able to all it as:
  /// <code>print_error_and_exit(my_error_message);</code>
  ///
  ///\return (if it returns) the contents of the specified database file
  PeakMatchingDatabase read_database(std::string file_name, 
				     std::string which_db,
				     void (*print_error_and_exit)(std::string));
  
}

#endif //HOUGH_PEAK_MATCH_PEAK_MATCHING_DATABASE
