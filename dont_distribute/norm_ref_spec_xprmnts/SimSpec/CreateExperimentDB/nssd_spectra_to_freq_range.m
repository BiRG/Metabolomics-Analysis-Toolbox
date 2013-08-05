function nssd_spectra_to_freq_range( output_name )
% Takes the default NSSD database in the parent directory and converts to a tsv containing frequency ranges
%
% Usage: nssd_spectra_to_freq_range( output_name )
%
% Where:
%
% output_name is a string giving the filename where the resulting data will
% be written
% 
% Reads each spectrum from the nssd database and records the maximum and
% minimum ppm. For each spectrum, it writes a line of the form:
%
% HMDB????? <tab> frequency_range_in_ppm_min_then_max <tab> [min_freq] <tab> [max_freq] <end line>
%
% to the output database. The ????? are replaced by digits and the spaces
% are written above for clarity and do not appear in the file.
%
% The database is hard-coded to be the database that came with MetAssimulo
% 1.2. The resulting data will be written to the file
% named 'output_name'. 

% Access the metassimulo_spectrad function (which is defined in the parent
if ~exist('metassimulo_specread.m','file')
    path(path,'..');
end

% Set up a database of the various compounds in the NSSD
idx_nssd_dirname = 1; % Index of the compound's subdirectory in the database
idx_nssd_exp = 2; % Index of the experiment number in the database
idx_nssd_proc = 3; % Index of the processed data number in the database
idx_hmdb_id = 8; % Index of the HMDB ID in the database

NSSD_names = nssd_translation_table();

% Read the compounds
nssd_root = '../NSSD'; % Directory in which NSSD compounds are located
num_compounds = size(NSSD_names,1);
freq = nan(num_compounds, 2); % min freq is - freq(compound_num, 1), max freq is freq(compound_num, 2)

wait_h = waitbar(0,'Reading compounds ...');
for i=1:num_compounds
    waitbar((i-1)/num_compounds, wait_h, sprintf('Reading %s', ...
        NSSD_names{i,idx_nssd_dirname}));
    base_dir = fullfile(nssd_root, NSSD_names{i, idx_nssd_dirname});
    cs=metassimulo_specread(base_dir, NSSD_names{i, idx_nssd_exp}, ...
        NSSD_names{i, idx_nssd_proc});
    if strcmp(cs, 'empty')
        delete(wait_h);
        error('nssd_spectra_to_spectral_collections:no_spectrum',...
            'No spectrum to plot in %s', base_dir);
    end
    if size(cs,2) ~= 3
        delete(wait_h);
        error('nssd_spectra_to_spectral_collections:not_one_dim',...
            'The spectrum in %s is not a 1D spectrum.', base_dir);
    end
    freq(i, 1) = min(cs(:,1));
    freq(i, 2) = max(cs(:,1));
end

% Set up the spectral collection structure
waitbar(0, wait_h, 'Writing tsv file');
fid = fopen(output_name, 'w');
for i=1:num_compounds
    waitbar((i-1)/num_compounds, wait_h);
    fprintf(fid, '%s\tfrequency_range_in_ppm_min_then_max\t%.18g\t%.18g\n', ...
        NSSD_names{i, idx_hmdb_id}, freq(i,1), freq(i,2));
end
fclose(fid);

close(wait_h);