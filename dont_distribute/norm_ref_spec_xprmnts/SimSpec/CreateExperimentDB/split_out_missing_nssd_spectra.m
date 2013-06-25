function split_out_missing_nssd_spectra( )
% Takes the default NSSD database in the parent directory and extracts the 4 metabolites that were missing peak lists in the HMDB database
%
% Usage: split_out_missing_nssd_spectra( )
%
% The substances that were missing peak lists are:
%
% HMDB00158 L-Tyrosine
%  
% HMDB00906 Trimethylamine
%  
% HMDB06344 p-Cresol sulfate
%  
% HMDB11635 phenylacetylglutamine
% 
% The database is hard-coded to be the database that came with MetAssimulo
% 1.2. The resulting spectral collection file will be written to files
% named HMDB00158, HMDB00906, HMDB06344, and HMDB11635. It is assumed that 
% the input spectra are all sorted by x.

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

NSSD_names = { ...
    'L_Tyrosine','7','1','L-Tyrosine','L-Tyrosine','361.02','184.54','HMDB00158'; ...
    'Trimethylamine','7','1','Trimethylamine','Trimethylamine','101.6','98','HMDB00906'; ...
    'phenylacetylglutamine','2','1','Alpha-N-Phenylacetyl-L-','phenylacetylglutamine','937.2','79.2','HMDB06344'; ...
    'p-cresol_sulfate','1','1','p-Cresol sulfate','p-Cresol sulfate','300','100','HMDB11635'; ...
};

% Read the compounds
num_compounds = size(NSSD_names,1);
wait_h = waitbar(0,'Processing compounds ...');
for i=1:num_compounds
    waitbar((i-1)/num_compounds, wait_h, sprintf('Processing %s', ...
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
    spec.x = cs(:,1);
    spec.Y = cs(:,2);
    
    num_samples = size(spec.Y,2);

    spec.input_names = {'Collection ID', 'Type', 'Description', 'Processing log', 'Base sample ID', 'Time', 'Classification', 'Sample ID', 'Subject ID', 'Sample Description', 'Weight', 'Units of weight', 'Species'};
    spec.formatted_input_names = {'collection_id', 'type', 'description', 'processing_log', 'base_sample_id', 'time', 'classification', 'sample_id', 'subject_id', 'sample_description', 'weight', 'units_of_weight', 'species'};
    spec.collection_id=sprintf('%d',-45572-i);
    spec.type='SpectraCollection';
    spec.description=sprintf('Converted spectrum from NSSD library of standards included from MetAssimulo 1.2');
    spec.processing_log='Created: converted from MetAssimulo 1.2 NSSD.';
    spec.num_samples=num_samples; 
    spec.time=zeros(1,num_samples);
    spec.classification=zeros(1,num_samples);
    spec.sample_id=arrayfun(@(x) sprintf('%s', NSSD_names{x, idx_hmdb_id} ), ...
        i:i,'UniformOutput',false); % HMDB_ID as sample id
    spec.subject_id=i;
    spec.sample_description=arrayfun(@(x) sprintf('Spectrum of %s (%s)', ...
        NSSD_names{x, idx_nssd_dirname}, NSSD_names{x, idx_hmdb_id} ), ...
        i:i,'UniformOutput',false); % Use sample description to describe what compound it is a spectrum of
    spec.weight=arrayfun(@(x) sprintf('%s', NSSD_names{x, idx_mean_urine_conc} ), ...
        i:i,'UniformOutput',false); % Mean urine concentration as sample weight
    spec.units_of_weight=arrayfun(@(x) 'Weight is mean urine concentration',i:i,'UniformOutput',false);
    spec.species=arrayfun(@(x) 'No species',i:i,'UniformOutput',false);
    spec.base_sample_id=i:i;

    % Write the spectrum to a file
    save_collection([NSSD_names{i, idx_hmdb_id} '.xy.txt'], spec);
end

delete(wait_h);