function results = probability_of_peak_merging_in_random_spec( numbers_of_peaks, numbers_of_peak_widths, num_reps )
% Return a monte-carolo estimate the joint probability distribution of certain numbers of local maxima being generated in a random spectrum when 
%
% Usage: results = probability_of_peak_merging_in_random_spec( numbers_of_peaks, numbers_of_peak_widths, num_reps )
%
% Takes the cartesian product of the two input vectors numbers_of_peaks,
% and numbers_of_peak widths (that is, all combinations of the entries of
% those two vectors) and generates num_reps spectra for each
%
% Input params:
%
% numbers_of_peaks - (vector) each entry in this vector is a number of
%            peaks to use in a trial.
%
% numbers_of_peak_widths - (vector) each entry in this vector represents a
%            generation interval to use in a trial measured in terms of the
%            mean peak half width at half height used the generating 
%            distribution in random_spec_from_nssd_data. So a 1 would
%            indicate an interval 0.00453630122481774988 ppm wide.
%
% num_reps - (scalar) the number of noiseless random spectra to generate 
%            for each member of the cartesian product of numbers_of_peaks 
%            and numbers_of_peak_widths
%
% Output params:
%
% results - (vector of struct) Each entry in this vector has 4 fields and
%           represents the result of the num_reps trials for one member of
%           the cartesian product of numbers_of_peaks and
%           numbers_of_peak_widths. The fields are as follows:
%
%           num_peaks - (scalar) the number of peaks used in the trial
%
%           width - (scalar) width (in ppm) of the interval used in the
%                   trial
%
%           num_reps - (scalar) the number of repetitions used in the trial
%
%           counts - (vector) has length num_peaks. counts(i) is the number
%                   of times there were i local maxima detected. subtract
%                   the sum from num_reps to determine the number of times
%                   0 local maxima were detected.
%
% Example:
%
% c = probability_of_peak_merging_in_random_spec( [1:3], [1,5:5:15], 100 )
%
% Generates 100 spectra for each combination in the cartesian product of
% the arrays [1,2,3] and [1,5,10,15], that is for all pairs (1,1), (1,5),
% (1,10), (1,15), (2,1), (2,5), (2,10), (2,15), (3,1), (3,5), (3,10), and
% (3,15). For each of these pairs (a,b), c will contain a struct with
% fields num_peaks, width, num_reps, and counts. Counts will be a
% vector whose i'th entry will be the number of times in the 100 that 
% i local maxima were detected in the interval. c.num_reps will be
% 100 but is saved so that it is easy to count the number of times 0 local
% maxima were detected
%
% 

end

