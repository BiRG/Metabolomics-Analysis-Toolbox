function spec=nssd_spectra_to_spectral_collections( output_name )
% Takes the default NSSD database in the parent directory and converts it to a single spectral collection file
%
% Usage: spec=nssd_spectra_to_spectral_collections( output_name )
%
% Where:
%
% output_name is a string giving the filename where the resulting spectra
% will be written.
% 
% The database is hard-coded to be the database that came with MetAssimulo
% 1.2. The resulting spectral collection file will be written to the file
% named 'output_name'. It is assumed that the input spectra are all sorted
% by x.

% Access the metassimulo_spectrad function (which is defined in the parent
if ~exist('metassimulo_specread.m','file')
    path(path,'..');
end

% Set up a database of the various compounds in the NSSD
nssd_root = '../NSSD'; % Root for the NSSD

idx_nssd_dirname = 1; % Index of the compound's subdirectory in the database
idx_nssd_exp = 2; % Index of the experiment number in the database
idx_nssd_proc = 3; % Index of the processed data number in the database
idx_mean_urine_conc=6; % Index of the mean urine concentration in the database
idx_hmdb_id = 8; % Index of the HMDB ID in the database

NSSD_names = nssd_translation_table();

% Read the compounds
num_compounds = size(NSSD_names,1);
spec = cell(num_compounds, 1);
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
    spec{i, 1} = cs;
end

% Fix the baselines
waitbar(0, wait_h, 'Fixing baselines');
for i = 1:num_compounds
    waitbar((i-1)/num_compounds, wait_h);
    y = spec{i,1}(:,2);
    spec{i,1}(:,2) = metassimulo_fix_baseline(y', 64)'; % Use baseline correction routine from MetAssimulo - 32 bins is the MetAssimulo default value, but the baselines still look a bit rough. With my improvement, we can go down to 64 bins without ringing.
end


% Calculate all the ppms (x values) that will be needed in the combined
% spectra
waitbar(0, wait_h, 'Calculating the final x values');

% Find the interval covered by all spectra 
consensus_minimum = max(cellfun(@(x) min(x(:,1)), spec));
consensus_maximum = min(cellfun(@(x) max(x(:,1)), spec));

% Set the resample locations to 32768 values that lie strictly in that 
% region
final_x = linspace(consensus_minimum, consensus_maximum, 32768+2);
final_x = final_x(2:end-1);
assert(length(final_x) == 32768);
assert(all(final_x < consensus_maximum & final_x > consensus_minimum));

% Interpolate the spectra - adding normally distributed noise where
% extrapolation would be needed (with mean and standard deviation of the
% noise taken from the mean and std of the first 100 points of the
% spectrum)
waitbar(0, wait_h, 'Interpolating');
final_y = zeros(length(final_x), num_compounds);
for i = 1:num_compounds
    waitbar((i-1)/num_compounds, wait_h);
    cs = spec{i,1}(:,2);
    if ~issorted(spec{i,1}(:,1)) && ~issorted(spec{i,1}(end:-1:1,1))
        % The spectra have to be sorted or reverse sorted so taking 
        % the first 100 values will likely lie in a noise region
        error('nssd_spectra_to_spectral_collection:not_sorted',...
            'Spectrum %d (%s) is not sorted', i, NSSD_names{i, idx_nssd_dirname});
    end
    interpd=interp1(spec{i,1}(:,1), cs, final_x, 'pchip', NaN);
    assert(~any(isnan(interpd))); % shouldn't be any extrapolation going on
    
    final_y(:,i) = interpd;
end

% Set up the spectral collection structure
waitbar(0, wait_h, 'Writing spectrum file');
clear('spec');
spec.x = final_x;
spec.Y = final_y;

num_samples = size(spec.Y,2);

spec.input_names = {'Collection ID', 'Type', 'Description', 'Processing log', 'Base sample ID', 'Time', 'Classification', 'Sample ID', 'Subject ID', 'Sample Description', 'Weight', 'Units of weight', 'Species'};
spec.formatted_input_names = {'collection_id', 'type', 'description', 'processing_log', 'base_sample_id', 'time', 'classification', 'sample_id', 'subject_id', 'sample_description', 'weight', 'units_of_weight', 'species'};
spec.collection_id=sprintf('%d',-45572);
spec.type='SpectraCollection';
spec.description=sprintf('Converted spectra from NSSD library of standards included from MetAssimulo 1.2');
spec.processing_log='Created converted from MetAssimulo 1.2 NSSD.';
spec.num_samples=num_samples; 
spec.time=zeros(1,num_samples);
spec.classification=zeros(1,num_samples);
spec.sample_id=arrayfun(@(x) sprintf('%s', NSSD_names{x, idx_hmdb_id} ), ...
    1:num_samples,'UniformOutput',false); % HMDB_ID as sample id
spec.subject_id=1:num_samples;
spec.sample_description=arrayfun(@(x) sprintf('Spectrum of %s (%s)', ...
    NSSD_names{x, idx_nssd_dirname}, NSSD_names{x, idx_hmdb_id} ), ...
    1:num_samples,'UniformOutput',false); % Use sample description to describe what compound it is a spectrum of
spec.weight=arrayfun(@(x) sprintf('%s', NSSD_names{x, idx_mean_urine_conc} ), ...
    1:num_samples,'UniformOutput',false); % Mean urine concentration as sample weight
spec.units_of_weight=arrayfun(@(x) 'Weight is mean urine concentration',1:num_samples,'UniformOutput',false);
spec.species=arrayfun(@(x) 'No species',1:num_samples,'UniformOutput',false);
spec.base_sample_id=1:num_samples;

% Write the spectrum to a file
save_collection(output_name, spec);

delete(wait_h);