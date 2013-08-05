function saved_deconvolution_to_tsv( tsv_name, spectrum_ids )
% Convert a saved deconvolution file to a tab-separated value file
%
% Usage: saved_deconvolution_to_tsv( tsv_name, spectrum_ids )
%
% tsv_name: the name of the tsv file to which the tab-separated values will
% be written
%
% spectrum_ids: cell array of strings. spectrum_ids{i} is the string 
% identifier for the i'th spectrum. Must not contain tab characters and 
% must have the same number of entries as the saved deconvolution
%
% ------------------------------------------------------------------------
%
% Reads the file saved_full_deconvolution.mat in the current directory and
% writes it to a file named tsv_name. The tsv file will have each row start
% with spectrum_ids{i} and then a description of the type of data for that
% line: 'ppms', 'heights', 'lorentzianness', and 'half_height_width',
% followed by one field for each peak. The fields will be separated by
% tabs.
%
% This file is intended to be concatenated with files from other sets of
% spectra.
%
% ------------------------------------------------------------------------
% Examples
% ------------------------------------------------------------------------
% >> saved_deconvolution_to_tsv( 'hmdb00906.tsv',{'

% Load the peaks
load('saved_full_deconvolution.mat','-mat');
if ~exist('all_peaks','var')
    error('saved_deconvolution_to_tsv:wrong_mat_file',['The '...
        'saved_full_deconvolution.mat file did not contain the ' ...
        'all_peaks variable']);
end
num_spec=size(all_peaks,1); %#ok<USENS>

% Check input
if ~iscellstr(spectrum_ids)
    error('saved_deconvolution_to_tsv:cell_array',['The spectrum_ids '...
        'parameter must be a cell array of strings']);
end

if length(spectrum_ids) ~= num_spec
    error('saved_deconvolution_to_tsv:num_spec',['The spectrum_ids ' ...
        'parameter must have one string for each spectrum in the saved '...
        'deconvolution file.']);
end

% Write the spectra
fid = fopen(tsv_name,'w');
if fid == -1
    error('saved_deconvolution_to_csv:no_file',['Could not open the '...
        'tsv file "%s" for writing.'], tsv_name);
end

field_names = {'ppms','heights','half_height_width','lorentzianness'};
for spec=1:num_spec
    params = [...
        all_peaks{spec}.location; ...
        all_peaks{spec}.height; ...
        all_peaks{spec}.half_height_width; ...
        all_peaks{spec}.lorentzianness];
    for field=1:4
        fprintf(fid,'%s\t%s', spectrum_ids{spec},field_names{field});
        fprintf(fid,'\t%.18g',params(field,:));
        fprintf(fid,'\n');
    end
end
fclose(fid);


end

