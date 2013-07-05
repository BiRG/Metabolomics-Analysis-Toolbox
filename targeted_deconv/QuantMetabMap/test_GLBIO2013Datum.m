function test_suite = test_GLBIO2013Datum %#ok<STOUT>
% matlab_xUnit tests excercising GLBIO2013Datum
%
% Usage:
%   runtests test_GLBIO2013Datum 
initTestSuite;

function str=filename_for_test_data
% Return the name of the file in which the test data is stored
str = 'test_GLBIO2013Datum_test_data_1.mat';

function ensure_test_data_file_exists
% This function is here to regenerate the test data if necessary. Does
% nothing if the test data file exists. Otheriwse does the calculations to
% create the test data file
if ~exist(filename_for_test_data,'file')
    old_rng = RandStream.getGlobalStream();
    RandStream.setGlobalStream(RandStream('mt19937ar','Seed',1288700689));
    datum1 = GLBIO2013Datum(1); %#ok<NASGU>
    datum2 = GLBIO2013Datum(1.5); %#ok<NASGU>
    save(filename_for_test_data,'datum1','datum2');
    RandStream.setGlobalStream(old_rng);
end

function assertDatumObjectsEqual(d1,d2)
fields = {'spectrum_peaks','spectrum_width','deconvolutions' ...
    'resolution','spectrum_interval', 'spectrum', ...
    'spectrum_snr', 'id'};
for i = 1:length(fields)
    f = fields{i};
    assertEqual(d1.(f),d2.(f),sprintf('Field %s should be equal',f));
end

function idx = picker_idx(str)
% Usage: idx = picker_idx(str)
%
% Returns a unique index for str in the list of peak-picker names. If str
% is not in the list, returns [].
idx = find(strcmp(str, GLBIO2013Deconv.peak_picking_method_names));

function disabled_test_deconv_with_same_picker_have_same_picked_peaks %#ok<DEFNU>
% Check that deconvolutions in the same datum with the same picker have the
% same picked peaks.
old_rng = RandStream.getGlobalStream();
RandStream.setGlobalStream(RandStream('mt19937ar','Seed',1288700689));

datum = GLBIO2013Datum(1);
deconvolutions = datum.deconvolutions;

% Picked peaks{i} holds a list in which each element is a cell containing 
% either the name of the i'th peak picker or the first lists of peak 
% locations picked by that picker.
picked_peaks = GLBIO2013Deconv.peak_picking_method_names;
for i = 1:length(deconvolutions)
    deconv = deconvolutions(i);
    idx = picker_idx(deconv.peak_picker_name);
    if ischar(picked_peaks{idx})
        picked_peaks{idx} = deconv.picked_locations;
    else
        assertEqual(picked_peaks{idx}, deconv.picked_locations, ...
            sprintf('Picker "%s" had picked different peaks in same datum', ...
            deconv.peak_picker_name));
    end
end

RandStream.setGlobalStream(old_rng);

function test_update_correctly_reorders_deconvs %#ok<DEFNU>
% Check that updateDeconvolutions correctly reorders deconvolutions into
% the current order 
ensure_test_data_file_exists;
load(filename_for_test_data);

reordered_deconvs = datum1.deconvolutions([6 3 7 8 5 1 2 4]);
reordered1 = GLBIO2013Datum.dangerous_constructor(datum1.spectrum_peaks, ...
    datum1.spectrum_width, reordered_deconvs, datum1.resolution, ...
    datum1.spectrum_interval, datum1.spectrum, datum1.spectrum_snr, ...
    datum1.id);
updated_reordered1 = reordered1.updateDeconvolutions;

assertDatumObjectsEqual(datum1, updated_reordered1);

reordered_deconvs = datum2.deconvolutions([5 4 1 8 3 2 6 7]);
reordered2 = GLBIO2013Datum.dangerous_constructor(datum2.spectrum_peaks, ...
    datum2.spectrum_width, reordered_deconvs, datum2.resolution, ...
    datum2.spectrum_interval, datum2.spectrum, datum2.spectrum_snr, ...
    datum2.id);
updated_reordered2 = reordered2.updateDeconvolutions;

assertDatumObjectsEqual(datum2, updated_reordered2);

function test_update_correctly_restores_missing_picked_peaks %#ok<DEFNU>
assertFalse(true); % not written