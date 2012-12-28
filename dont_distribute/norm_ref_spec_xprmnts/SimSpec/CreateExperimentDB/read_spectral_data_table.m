function generate_noiseless_nssd( target_dir, spectral_params_file )
% Generates artificial spectral data in target_dir accoring to the description stored in spectral_params_file
% 
% Usage: generate_noiseless_nssd( target_dir, spectral_params_file )
%
% Where:
%
% target_dir is a string containing the path to the directory which will be
%            filled with one subdirectroy for each compound 
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
% Note: each entry in the spectral_params_file must be a compound that is
% listed in the return value of nssd_translation_table()

% Set up the translation table
idx_dirname = 1; % Index of the compound's subdirectory in the database
idx_exp = 2; % Index of the experiment number in the database
idx_proc = 3; % Index of the processed data number in the database
idx_hmdb_id = 8; % Index of the HMDB ID in the database
trans_tbl = nssd_translation_table();

hmdb_ids = trans_tbl(:, idx_hmdb_id);
function idx = table_idx_for_hmdbid(id)
    % Usage: idx = table_idx_for_hmdbid(id)
    %
    % Return the index of the compound with hmdb ascession number id (of
    % the form HMDB????? ) in the value returned by 
    % nssd_translation_table(). If not found, returns the empty array.
    idx = find(strcmp(id, hmdb_ids),1,'first');
end

% Read in spectral params file
fid = fopen(spectral_params_file,'rt');
spectral_data = cell(size(trans_tbl,1),1);
line = fgetl(fid);
while ischar(line)
    [line_head,end_pos] = textscan(line, '%s\t%s',1);
    idx = table_idx_for_hmdbid(line_head{1}{1});
    if isempty(idx)
        error('generate_noiseless_nssd:unknown_HMDB_ID', ...
            ['%s is not an HMDB ID contained in ' ....
            'nssd_translation_table() but appears in %s'], ...
            line_head{1}, spectral_params_file);
    end
    tmp = textscan(line(end_pos+1:end), '%f');
    spectral_data{idx}.(line_head{2}{1}) = tmp{1};
    line = fgetl(fid);
end
fclose(fid);

% Make sure that the target directory exists
if ~exist(target_dir,'dir')
    success = mkdir(target_dir);
    if ~success
        error('generate_noiseless_nssd:cant_mkdir', ...
            ['The target directory %s does not exist but could not '...
            create it.'], target_dir);
    end
end

% Calculate median half_height_width
all_widths = [];
for i=1:size(spectral_data,1)
    if isfield(spectral_data{i}, 'half_height_width')
        w = spectral_data{i}.half_height_width;
        if iscolumn(w)
            all_widths = [all_widths, w']; %#ok<AGROW>
        else
            all_widths = [all_widths, w]; %#ok<AGROW>
        end
    end
end
median_width = median(all_widths);

% Loop through the spectral parameters objects, making the directories
% filled with artificial data
wait_h = waitbar(0,'Writing data');
for i=1:size(spectral_data,1)
    waitbar((i-1)/size(spectral_data,1), wait_h, sprintf('Writing %s', ...
        trans_tbl{i,idx_dirname}));
    
    % Skip values that didn't appear at all
    if isempty(spectral_data{i})
        continue;
    end
    
    
    % Use recorded lorenzianness values if available or 1 as default
    if isfield(spectral_data{i}, 'lorentzianness')
        lor = spectral_data{i}.lorentzianness;
    else
        lor = ones(size(spectral_data{i}.ppms));
    end
    
    % Use recorded height values if available or median as default
    if isfield(spectral_data{i}, 'half_height_width')
        wid = spectral_data{i}.half_height_width;
    else
        wid = median_width*ones(size(spectral_data{i}.ppms));
    end
    
    % Write the files
    write_nssd_entry(target_dir, trans_tbl{i,idx_dirname}, ...
        trans_tbl{i, idx_exp}, trans_tbl{i, idx_proc}, ...
        spectral_data{i}.heights, wid, lor, spectral_data{i}.ppms, ...
        spectral_data{i}.frequency_range_in_ppm_min_then_max, ...
        spectral_data{i}.number_of_samples);
        
end

close(wait_h);

end

