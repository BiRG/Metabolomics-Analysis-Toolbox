function [ spectra ] = add_peak_counts( counts, spectra )
%Performs spectra{i}.num_peaks_at_x=counts{i} for all i and returns the result
%
%counts   a cell array of arrays of integer each array is the same length
%         as the list of spectra{i}.x
%
%spectra  a cell array of spectrum structures, each of which has an x array

if length(counts) ~= length(spectra)
    error('The number of counts arrays and the number of spectra must be the same');
end

for i = 1:length(counts)
    if length(spectra{i}.x) ~= length(counts{i})
        error(['Spectrum %d has a different number of x values than ' ...
            'the %d entry in counts.'], counts{i});
    end
    spectra{i}.num_peaks_at_x=counts{i};
end