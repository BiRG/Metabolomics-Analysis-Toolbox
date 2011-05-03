///\page file_format_docs File format documentation
///
///The tools communicate with each other using a serialization of this
///data object model. They use their own format rather than an
///existing database format like SQLite because they need a text-based
///format that is easily written by Matlab (and Mathematica, but that
///is not essential).
///
///The Hough tools use a file format consisting of lines of
///space-separated values. The first value in each line is a type
///identifier. It would be the table name in the database. There is a
///table for each of the following classes: parameterized_peak_group,
///detected_peak_group, sample, sample_parameters, param_statistics,
///human_verified_peak, unverified_peak, and unknown_peak. If the
///first character in a line is a # then the line is ignored and
///treated as a comment. Blank lines (consisting of just a newline)
///are also ignored.
///
///It is assumed that there is a peak group for any peak_group_id
///referenced in a known_peak object, this avoids materializing the
///list of peak_group_ids directly
///
///A peak is identified by a two-part primary key: (sample_id,
///peak_id) - I did this because the natural way to identify peaks is
///to sort them by ppm within each sample and then sort the samples in
///some way and give the sample number and peak number. This also
///makes merging new samples into the database a little easier - no
///need to renumber the peaks, just give each sample a unique id.
///
///\section file_format_line_types Fields for each table (that is each line-type)
///
///Each table has fixed fields. Thus each line of the file, depending
///on its type has well defined fields to model the relations and data
///shown in the table.
///
///Each description begins with a prototype line of the file and then a description of each field.
///
///\subsection parameterized_peak_group parameterized_peak_group
///
///parameterized_peak_group peak_group_id ppm param_1 param_2 ... param_n
///
///peak_group_id non-negative integer uniquely identifying the
///peak_group to which the parameters apply ppm the base location of
///the peak group
///
///param_1 ... param_n a vector of n reaction parameters so that the
///predicted location of a peak in this group is ppm +
///peak_group.parameters · sample.sample_parameters
///
///\subsection detected_peak_group detected_peak_group
///
///detected_peak_group peak_group_id ppm param_1 param_2 ... param_n
///
///peak_group_id non-negative integer uniquely identifying the
///peak_group to which the parameters apply ppm the base location of
///the peak group
///
///param_1 ... param_n a vector of n reaction parameters so that the
///predicted location of a peak in this group is ppm +
///peak_group.parameters · sample.sample_parameters
///
///\subsection human_verified_peak human_verified_peak
///
///human_verified_peak sample_id peak_id ppm peak_group_id
///
///sample_id non-negative integer uniquely identifying the sample to
///which this peak belongs
///
///peak_id non-negative integer uniquely identifying this peak within
///all peaks belonging to that sample
///
///peak_group_id the id of the peak group to which this peak belongs
///
///\subsection unverified_peak unverified_peak
///
///unverified_peak sample_id peak_id ppm peak_group_id
///
///Fields are the same as in human_verified_peak
///
///\subsection unknown_peak unknown_peak
///
///unknown_peak sample_id peak_id ppm
///
///The fields are the same as in human_verified_peak 
///
///\subsection sample sample
///
///sample sample_id class
///
///sample_id a non-negative integer uniquely identifying the sample
///described by this line
///
///class a string (without spaces) indicating which treatment class
///this sample came from. If two samples have different strings, then
///they came from different classes, same string, same classes
///
///\subsection sample_params sample_params
///
///sample_params sample_id param_1 param_2 ... param_n
///
///sample_id a non-negative integer uniquely identifying the sample to
///which these parameters apply
///
///param_1 ... param_n a vector of n sample parameters so that the
///predicted location of a peak in this sample is peak_group.ppm +
///peak_group.parameters · sample.sample_parameters
///
///\subsection param_stats param_stats
///
///param_stats fracvar_1 fracvar_2 ... fracvar_n
///
///fracvar_1 ... fracvar_n is a vector of n non-negative decimal
///rational numbers that give fraction of variance explained by the
///corresponding sample parameter in the group of known peaks used to
///generate the sample parameters. The sum of all fracvar_i parameters
///cannot be more than 1.
///
///Note that fracvar values of 0 are acceptable. This is needed, for
///example, in the case that the user specifies a model with more
///parameters than necessary.
