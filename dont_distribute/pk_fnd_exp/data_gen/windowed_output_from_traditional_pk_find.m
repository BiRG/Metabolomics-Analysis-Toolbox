function windowed_output_from_traditional_pk_find( spectrum_indices, output_filename )
%Write output of traditional peak finding to arff file for processing by waffles tools
%
%Usage: windowed_output_from_traditional_pk_find( spectrum_indices, output_filename )
%
%******************************************
% Detailed description
%******************************************
%
% Reads the spectra from synthetic_spectrum_filename.  Extracts the spectra
% at the given indices.  Then finds the peaks in those spectra.  Finally,
% Writes an arff file to output_filename.  It has 3 attributes.
%
% "spectrum identifier" the index of the spectrum that was analyzed
% "window center index" the sample index within the spectrum closest to the location where the peak was detected
% "has peaks" whether a peak was detected.
%
% It writes one pattern for each sample in each input spectrum.
%
%******************************************
% Example
%******************************************
%
%>> windowed_output_from_traditional_pk_find( [3,4], "sp_3_4_trad_find.arff")
%
% Would output peak locations from spectra 3 and 4 of the collection
% specified by synthetic_spectrum_filename

%TODO: write

end

