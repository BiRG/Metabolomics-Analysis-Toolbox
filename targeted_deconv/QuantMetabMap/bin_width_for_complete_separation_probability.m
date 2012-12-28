function width = bin_width_for_complete_separation_probability( target_probability, num_peaks, min_width, max_width, tolerance, num_reps, num_intensities)
% Return the bin width that will ensure (approximately) that there is the target probability of having num_peaks local maxima in a spectrum generated with num_peaks peaks from the nssd data.
% 
% Usage: width = bin_width_for_complete_separation_probability( target_probability, num_peaks, min_width, max_width, tolerance, num_reps, num_intensities)
%
% Input parameters:
%
% target_probability - the probability of there being num_peaks local
%    maxima in a bin with the returned width
%
% num_peaks - the number of peaks generated in the bin
%
% min_width - the minimum width of bin to consider
%
% max_width - the maximum widht of bin to consider
%
% tolerance - the first bin width that lies within tolerance of the target
%    probability will be returned
%
% num_reps - the number of repetitions - the number of spectra generated to
%    estimate the probability for a given width
%
% num_intensities - the number of intensities to use in the generated
%    spectra
%
% Output parameters:
%
% width - the bin width that should give the chosen probability

    function e=error_for_width(w)
        % Returns the calculated probability of complete separation for a bin of width w
        s = probability_of_peak_merging_in_random_spec(num_peaks, w, num_reps, num_intensities, false);
        p = s.counts(num_peaks)/num_reps;
        e = abs(target_probability-p);
    end

width = fminbnd(@error_for_width, min_width, max_width, optimset('TolX',tolerance,'PlotFcns',{@optimplotfval,@optimplotx}));

end

