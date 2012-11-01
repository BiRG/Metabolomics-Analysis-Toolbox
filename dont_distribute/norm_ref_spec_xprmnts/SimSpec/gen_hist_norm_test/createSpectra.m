function createSpectra( met_assimulo_dir )
% Create the simulated spectral data to test histogram normalization
%
% Reproducibly creates the test spectra files. Makes a local copy of the
% NSSD directory from MetAssimulo so everything works ok.
%
% -------------------------------------------------------------------------
% Example
% -------------------------------------------------------------------------
%
% >> createSpectra('path/to/MetAssimulo')
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

% Create 2 independent reproducible random number streams, one for each set
% of spectra
[rg1,rg2]=RandStream.create('mrg32k3a','NumStreams',2);
streams = {rg1,rg2};

% Make an array of the 6 parameter files that will be used to create the
% spectra and their corresponding output directories
param_files={'MetAssimuloInput/01_control.param.txt', ...
    'MetAssimuloInput/02_control.param.txt', ...
    };

output_dirs={'spectra/01_control', ...
    'spectra/02_control', ...
    };

assert(length(param_files) == length(streams));
assert(length(param_files) <= length(streams));

% Generate the spectra
for i=1:length(streams)
    fprintf('Generating spectra from %s\n', param_files{i});
    RandStream.setDefaultStream(streams{i});
    SimulateSpectrum(output_dirs{i}, param_files{i});
end

% Put the path back the way we found it
path(old_path);

end

