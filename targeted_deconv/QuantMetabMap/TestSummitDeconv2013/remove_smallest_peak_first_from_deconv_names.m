function [ final_results ] = remove_smallest_peak_first_from_deconv_names( results )
% Renames any deconvolutions with "smallest_peak_first" in their names to have "summit" instead
% 
% Usage: [ final_results ] = remove_smallest_peak_first_from_deconv_names( results )
%
% Given an array of ExpDatum objects, renames each starting point name that
% contains the string smallest_peak_first to say summit in its place. For
% example. If the starting point name was "dsp_smallest_peak_first_100_pctile"
% it would become "summit_100_pctile"
%
% This code is here to patch old test files so that they work with the most
% recent version of the code - in which I have made this change.
%
% NOTE: ExpDeconv and ExpDatum must have the line 
%
% properties (SetAccess = public)"
%
% in their code
% -----------------------------------------
% Input Args
% -----------------------------------------
%
% results - (vector of ExpDatum)
%
% -----------------------------------------
% Output Args
% -----------------------------------------
%
% final_results - (vector of ExpDatum) the same as results except that the
%     renaming has taken place
%
% -----------------------------------------
% Examples
% -----------------------------------------
%
% 
% -----------------------------------------
% Author
% -----------------------------------------
%
% Eric Moyer (Aug 2013)

final_results = results;
for r_idx = 1:length(results)
    datum = results(r_idx);
    for d_idx = 1:length(datum.deconvolutions)
        dec = datum.deconvolutions(d_idx);
        dec.starting_point_name = strrep(dec.starting_point_name,'smallest_peak_first','summit');
        datum.deconvolutions(d_idx) = dec;
    end
    final_results(r_idx) = datum;
end

end

