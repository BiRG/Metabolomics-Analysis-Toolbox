function spectra = loadSpectra( )
% Return the test spectra as a cell array
%
% Loads the spectra created by createSpectra from the directory in
% which they were created. spectra{i} is an array of the spectra in
% group i. Each row is the same ppm value, each column is a spectrum
% 
% -------------------------------------------------------------------------
% Example
% -------------------------------------------------------------------------
%
% >> spectra = loadSpectra( )
%
% loads the created test spectra from their directory

% Read the subdirectory names into a cell array
default_dir = 'spectra';
if isunix
    subdirs = regexp(strtrim(ls(default_dir)),'\s+','split');
else
    subdirs = dir(default_dir);
    subdirs = {subdirs.name};
    not_dot_dirs = ~(strcmp(subdirs,'.') | strcmp(subdirs,'..'));
    subdirs = subdirs(not_dot_dirs);
end
subdirs = sort(subdirs);

% Read each data file and extract its y-values
spectra = cell(length(subdirs),1);
for i=1:length(subdirs)
    data_file_name = 'Simulated_Data.mat';
    full_file_name = fullfile(default_dir, subdirs{i}, data_file_name);
    tmp = load(full_file_name);

    spectra{i}.Y = tmp.simulation.mix2.spectra;
    spectra{i}.x = tmp.simulation.mix2.x;
    num_samples = size(spectra{i}.Y,2);
    
    spectra{i}.input_names = {'Collection ID', 'Type', 'Description', 'Processing log', 'Base sample ID', 'Time', 'Classification', 'Sample ID', 'Subject ID', 'Sample Description', 'Weight', 'Units of weight', 'Species'};
    spectra{i}.formatted_input_names = {'collection_id', 'type', 'description', 'processing_log', 'base_sample_id', 'time', 'classification', 'sample_id', 'subject_id', 'sample_description', 'weight', 'units_of_weight', 'species'};
    spectra{i}.collection_id=sprintf('%d',-1200-i);
    spectra{i}.type='SpectraCollection';
    spectra{i}.description=sprintf(['Collection for evaluating '...
        'normalization routines loaded from %s'], full_file_name);
    spectra{i}.processing_log='Created by metAssimulo.';
    spectra{i}.num_samples=num_samples; 
    spectra{i}.time=zeros(1,num_samples);
    spectra{i}.classification=arrayfun(@(x) sprintf('Group %d loaded from %s', i,full_file_name),1:num_samples,'UniformOutput',false); % Classify by dilution factor
    spectra{i}.sample_id=1:num_samples;
    spectra{i}.subject_id=1:num_samples;
    spectra{i}.sample_description=spectra{i}.classification;
    spectra{i}.weight=ones(1,num_samples);
    spectra{i}.units_of_weight=arrayfun(@(x) 'No weight unit',1:num_samples,'UniformOutput',false);
    spectra{i}.species=arrayfun(@(x) 'No species',1:num_samples,'UniformOutput',false);
    spectra{i}.base_sample_id=1:num_samples;
end

end

