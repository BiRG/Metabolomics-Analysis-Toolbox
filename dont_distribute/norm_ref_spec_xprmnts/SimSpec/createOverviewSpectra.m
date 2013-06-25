function createOverviewSpectra( met_assimulo_dir )
% Create the simulated spectral data to use in the normalization overview experiment
%
% TODO: update when I have decided on how to create the spectra
%
% Reproducibly creates the test spectra files. Makes a local copy of the
% NSSD directory from MetAssimulo so everything works ok.
%
% -------------------------------------------------------------------------
% Example
% -------------------------------------------------------------------------
%
% >> createOverviewSpectra('path/to/MetAssimulo')
%
% Creates the spectra using the MetAssimulo code located at
% /path/to/MetAssimulo

% Make a copy
if ~exist('NSSD','dir')
    fprintf('Copying NSSD\n');
    [success, message]=copyfile(fullfile(met_assimulo_dir, 'NSSD'), './NSSD');
    if ~success
        error('createSpectra:no_NSSD',['Could not copy NSSD ' ...
            'from MetAssimulo directory. System error: %s'], message);
    end
end

% Add MetAssimulo to the path so it can be executed
old_path = path;
path(met_assimulo_dir, path);

% Create 6 independent reproducible random number streams, one for each set
% of spectra
[rg1,rg2,rg3,rg4,rg5,rg6]=RandStream.create('mrg32k3a','NumStreams',6);
streams = {rg1,rg2,rg3,rg4,rg5,rg6};

% Make an array of the 6 parameter files that will be used to create the
% spectra and their corresponding output directories
param_files={'MetAssimuloInput/01_control.param.txt', ...
    'MetAssimuloInput/02_control.param.txt', ...
    'MetAssimuloInput/03_1_up_sm.param.txt', ...
    'MetAssimuloInput/04_1_up.param.txt', ...
    'MetAssimuloInput/05_10_up.param.txt', ...
    'MetAssimuloInput/06_7_up_8_down.param.txt'};

output_dirs={'spectra/01_control', ...
    'spectra/02_control', ...
    'spectra/03_1_up_sm', ...
    'spectra/04_1_up', ...
    'spectra/05_10_up', ...
    'spectra/06_7_up_8_down'};

assert(length(param_files) == length(streams));


% Generate the spectra
for i=1:length(streams)
    fprintf('Generating spectra from %s\n', param_files{i});
    RandStream.setDefaultStream(streams{i});
    SimulateSpectrum(output_dirs{i}, param_files{i});
end

% Put the path back the way we found it
path(old_path);

end

