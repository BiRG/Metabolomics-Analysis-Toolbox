function spectral_data = read_spectral_data_table( spectral_params_file )
% Reads the parameters from a spectral_params_file
% 
% Usage: spectral_data = read_spectral_data_table( spectral_params_file )
%
% Where:
%
% spectral_params_file is a string containing the path to a file containing
%            the parameters to use in creating the spectra. Each line of
%            the file is a set of tab-separated values.
%
%            The first two fields are strings. The first string is of the
%            form HMDB????? and is the HMDB (human metabolome data base)
%            ascession number of a compound in nssd_translation_table().
%            The second field is a string telling the type of data in that
%            line. Recognized types are: 
%
%                frequency_range_in_ppm_min_then_max
%                   contains 2 fields, the minimum and maximum ppm for the
%                   spectrum
%
%                half_height_width
%                   contains one field for each peak giving its width (in
%                   ppm) at half-height
%
%                heights
%                   contains one field for each peak giving its height
%
%                lorentzianness
%                   contains one field for each peak giving its
%                   lorentzianness
%
%                ppms
%                   contains one field for each peak giving the ppm
%                   location of its mode
%
%                number_of_samples
%                   contains one field, the number of samples for that
%                   spectrum
%
%            If the lorentzianness field is missing, it will be assumed to
%            be 1 (all peaks being perfectly Lorentzian). If the
%            half_height_width field is missing for a compound, it will be
%            set to the median of all half-height widths that are present
%            in other compounds. The absence of any other type is an
%            error.
%
%            Note that because of some code to make things simpler, the
%            field types identifiers must be valid structure field names 
%            in matlab.
%
% spectral_data: is a cell array which has one entry for each hmdb id in
%            the original file.
%
%            each entry is a struct with one field being hmdb_id (which
%            contains the HMDB id for the compound) and the other fields
%            are the types listed under "recognized types" above and each
%            contains a Matlab vector.


% Read in hmdb ids from the file
hmdb_ids = {};
function idx = table_idx_for_hmdbid(id)
    % Usage: idx = table_idx_for_hmdbid(id)
    %
    % Return the index of the compound with hmdb ascession number id (of
    % the form HMDB????? ) in the value returned by 
    % nssd_translation_table(). If not found, returns the empty array.
    idx = find(strcmp(id, hmdb_ids),1,'first');
end
fid = fopen(spectral_params_file,'rt');
line = fgetl(fid);
while ischar(line)
    [line_head,end_pos] = textscan(line, '%s\t%s',1);
    idx = table_idx_for_hmdbid(line_head{1}{1});
    if isempty(idx)
        hmdb_ids{end+1}=line_head{1}{1};
    end
    line = fgetl(fid);
end

% Read in spectral params file
frewind(fid);
spectral_data = cell(size(hmdb_ids));
line = fgetl(fid);
while ischar(line)
    [line_head,end_pos] = textscan(line, '%s\t%s',1);
    idx = table_idx_for_hmdbid(line_head{1}{1});
    if isempty(idx)
        error('generate_noiseless_nssd:unknown_HMDB_ID', ...
            ['%s is not an HMDB ID contained in ' ....
            'first read of %s but appears in second'], ...
            line_head{1}, spectral_params_file);
    end
    tmp = textscan(line(end_pos+1:end), '%f');
    spectral_data{idx}.hmdb_id = line_head{1}{1};
    spectral_data{idx}.(line_head{2}{1}) = tmp{1};
    line = fgetl(fid);
end
fclose(fid);

end

