function updated_data = GLBIO2013_run_update_all( instance_number, data )
% Return the effect of running update on every element of data (and print status while doing it)
%
% Usage: updated_data = GLBIO2013_run_update_all( data )
%
% For each element in data (data(i)), returns an updated version in
% updated_data(i) that is the result of running update on data(i)
%
% As the update is run, continually prints a status indicator to show
% progress.
%
% -------------------------------------------------------------------------
% Input parameters
% -------------------------------------------------------------------------
%
% instance_number - (scalar) an id number printed with the status so that
%     different processes running on the same machine can be identified.
%
% data - (vector of ExpDatum) the datum objects to edit. Must 
%     contain at least one object.
%
% -------------------------------------------------------------------------
% Output parameters
% -------------------------------------------------------------------------
%
% updated_data - the GLBIODatum objects in data after updating
%
% -------------------------------------------------------------------------
% Examples
% -------------------------------------------------------------------------
%
% -------------------------------------------------------------------------
% Authors
% -------------------------------------------------------------------------
%
% Eric Moyer (eric_moyer@yahoo.com) July 2013

spectrum_times = [];

updated_data(length(data)) = data(length(data));
for datum_idx = 1:length(data)
	cur_spectrum_time = tic;
    
    num_completed_spectra = datum_idx - 1;
    spectra_remaining = length(data) - datum_idx;
    
	fprintf(['%6.2f%%: Instance %d> Updating datum %d of %d time remaining: '...
        '%d +/- %d minutes, %d elapsed\n'], ...
        100*num_completed_spectra/length(data), ...
              instance_number, datum_idx, length(data), ...
              round(spectra_remaining*mean(spectrum_times)), ...
              round(spectra_remaining*std(spectrum_times)), ...
              round(sum(spectrum_times)));
          
    updated_data(datum_idx) = data(datum_idx).updateDeconvolutions;
    
	spectrum_times = [spectrum_times, toc(cur_spectrum_time)/60]; %#ok<AGROW>
end

