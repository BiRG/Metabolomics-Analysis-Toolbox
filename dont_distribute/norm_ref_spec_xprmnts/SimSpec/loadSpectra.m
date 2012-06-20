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
subdirs = regexp(strtrim(ls(default_dir)),'\s+','split');
subdirs = sort(subdirs);

% Read each data file and extract its y-values
spectra = cell(length(subdirs),1);
for i=1:length(subdirs)
    data_file_name = 'Simulated_Data.mat';
    tmp = load(fullfile(default_dir, subdirs{i}, data_file_name));
    spectra{i} = tmp.simulation.mix2.spectra;
end

end

