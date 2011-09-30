function write_test_collection_to_foo_files(num_spectra, use_pristine_peaks)
% Write a test collection with num_spectra peaks to foo.* then starts targeted deconv
% 
% The files generated are:
%
%   foo.xy.txt              the generated test spectrum
%
%   foo.bins.csv            the bin-map to use
%
%   foo.dec.correct.xy.txt  the correct deconvolution - the peaks used
%                           to generate the spectrum
%
% If num_spectra is not given, one spectrum is generated
%
% If use_pristine_peaks is true, then uses the peaks from peak_obj as the
% starting peaks in the targeted deconvolution, otherwise lets TD detect
% them itself.  The default value for use_pristine_peaks is false.
%
% -------------------------------------------------------------------------
% Input arguments
% -------------------------------------------------------------------------
%
% num_spectra         (optional) the number of spectra to generate.
%                     Default value is 1.
%
% use_pristine_peaks  (optional) If true, passes the true peak locations
%                     used in generating the spectrum to targeted_identify.
%                     Otherwise targeted_identify must locate the peaks
%                     itself.
%
% -------------------------------------------------------------------------
% Output parameters
% -------------------------------------------------------------------------
%
% No ooutput parameters
%
% -------------------------------------------------------------------------
% Examples
% -------------------------------------------------------------------------
%
% write_test_collection_to_foo_files(5, 1)
%
% Write 5 spectra to the foo.* output files and start targeted
% deconvolution with the true peak list.
%
% write_test_collection_to_foo_files
%
% Write 1 spectrum to the foo.* files and start targeted deconvolution, but
% let it and the user find the peaks.


% Set default value for num_spectra
if nargin < 1
    num_spectra = 1;
end

% Set default value for use_pristine_peaks
if nargin < 2
    use_pristine_peaks = 0;
end

% Generate the collection
[collection, bin_map, deconvolved, ~, peak_obj] = ...
    compute_test_collection(num_spectra,0.3); 

% Write it to the files for later auditing
save_collection('foo.xy.txt', collection);
save_binmap('foo.bins.csv',bin_map);
save_collection('foo.dec.correct.xy.txt', deconvolved);

%Pass the new data to the figure
setappdata(0, 'collection', collection);
setappdata(0, 'bin_map', bin_map);

if use_pristine_peaks
    pristine_peak_xs = cell(1,num_spectra);
    for spec_idx =1:num_spectra
        objs = peak_obj(:, spec_idx);
        if isempty(objs)
            xs = [];
        else
            xs = [objs.location];
        end
        pristine_peak_xs{spec_idx} = xs;
    end

    setappdata(0, 'peaks', pristine_peak_xs);
end

targeted_identify;
