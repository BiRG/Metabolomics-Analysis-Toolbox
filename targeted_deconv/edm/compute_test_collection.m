function [ collection, bin_map, deconvolved, peak_objects, bin_ids ] = compute_test_collection( num_spectra, noise_amplitude )
%Computes a test spectral collection and its correct deconvolution
%   Computes a spectral collection for testing region deconvolution with a
%   given amplitude of Gaussian white noise.  The correct bin_map and
%   deconvolution are included in the output.
%
% -------------------------------------------------------------------------
% Input arguments
% -------------------------------------------------------------------------
%
% num_spectra      The number of spectra generated
%
% noise_amplitude  The amplitude of the Gaussian white noise added to the
%                  signal after generation
%
% -------------------------------------------------------------------------
% Output parameters
% -------------------------------------------------------------------------
%
% collection   The spectral collection object generated
%
% bin_map      An array of CompoundBin objects for use in deconvolving the
%              spectrum
%
% deconvolved  A spectral collection containing the deconvolved peaks
%
% peak_objects The GaussLorentzPeak objects used to generate the spectrum.
%              This is a matrix accessed as: 
%              peak_objects(peak_number, spectrum_idx)
%
%              Within a bin, all peak objects are sorted by their location 
%              parameter
%
% bin_ids      A parallel matrix to peak_objects giving the bin for each
%              peak.  A bin of 0 means that this peak should not be
%              identified
%
% -------------------------------------------------------------------------
% Examples
% -------------------------------------------------------------------------
%
% [collection, bin_map, deconvolved, peak_objects] =
%         compute_test_collection(1,0.3)
%
% Will generate a collection with 1 spectrum with and noise of 0.3 units

%First compound - a lorentzian singlet smack-dab in the middle of the first 100 x values
bin_map=CompoundBin({1000000,'Unobtanium 0001',1,100,'s','clean','U01', ...
    'TestSpectrum'});

peak_num = 1;
for i=1:num_spectra
    peak_objects(peak_num,i)=GaussLorentzPeak( [5+3*rand(1),10,1,50] ); %#ok<AGROW>
    bin_ids(peak_num, i)=1000000;  %#ok<AGROW>
end

%Create the collection
collection.filename = 'not_yet_saved_to_a_file.txt';
collection.input_names= {'Collection ID'    'Type'    'Description' ...
    'Processing log'};
collection.x=1:65536;
collection.num_samples = num_spectra;
collection.collection_id = '-101';
collection.type = 'SpectraCollection';
collection.description = ['Artificially generated spectrum ' ...
    'collection for testing targeted deconvolution'];
collection.processing_log = 'Generated.';

total_peaks = size(bin_ids)(1);
for spec=1:num_spectra
    peak = 1;
    
    while peak <= total_peaks
        
        
    end
end

%Create the deconvolved collection
collection.filename = 'not_yet_saved_to_a_file.txt';
collection.input_names= {'Collection ID'    'Type'    'Description' ...
    'Processing log'};
collection.x=1:65536;
collection.num_samples = num_spectra;
collection.collection_id = '-102';
collection.type = 'SpectraCollection';
collection.description = ['Deconvolved artificially generated spectrum ' ...
    'collection for testing targeted deconvolution'];
collection.processing_log = 'Generated. Deconvolved.';
end