function createSpectra( met_assimulo_dir )
% Create the simulated spectral data to use in the normalization experiment
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
    [success, message]=copyfile(fullfile(met_assimulo_dir, 'NSSD'), './NSSD');
    if ~success
        error('createSpectra:no_NSSD',['Could not copy NSSD ' ...
            'from MetAssimulo directory. System error: %s'], message);
    end
    
end



end

