function test_suite = test_ExpDatum %#ok<STOUT>
% matlab_xUnit tests excercising ExpDatum
%
% Usage:
%   runtests test_ExpDatum 
initTestSuite;

function str=filename_for_test_data
% Return the name of the file in which the test data is stored
str = 'test_ExpDatum_test_data_1.mat';

function ensure_test_data_file_exists
% This function is here to regenerate the test data if necessary. Does
% nothing if the test data file exists. Otheriwse does the calculations to
% create the test data file
if ~exist(filename_for_test_data,'file')
    old_rng = RandStream.getGlobalStream();
    RandStream.setGlobalStream(RandStream('mt19937ar','Seed',1288700692));
    datum1 = ExpDatum(1); %#ok<NASGU>
    datum2 = ExpDatum(1.5); %#ok<NASGU>
    save(filename_for_test_data,'datum1','datum2');
    RandStream.setGlobalStream(old_rng);
end

function assertDatumObjectsEqual(d1,d2)
fields = {'spectrum_peaks','spectrum_width', ...
    'resolution','spectrum_interval', 'spectrum', ...
    'spectrum_snr', 'id'};
for i = 1:length(fields)
    f = fields{i};
    assertEqual(d1.(f),d2.(f),sprintf('Field %s should be equal',f));
end

decs1 = d1.deconvolutions;
decs2 = d2.deconvolutions;
assertEqual(length(decs1), length(decs2));
for i = 1:length(decs1)
    dec1 = decs1(i);
    dec2 = decs2(i);
    fields = fieldnames(dec1);
    for j = 1:length(fields)
        f = fields{j};
        if strcmp(f,'peaks')
            f1 = dec1.peaks.property_array; % Comparing the peak property array will produce better error messages
            f2 = dec2.peaks.property_array;
        else
            f1 = dec1.(f);
            f2 = dec2.(f);
        end
        assertEqual(f1,f2,...
            sprintf('Field %s should be equal in deconvolution %d',f,i));
    end
end


function assertDatumObjectsApproxEqual(d1,d2)
fields = {'spectrum_peaks','spectrum_width',...
    'resolution','spectrum_interval', 'spectrum', ...
    'spectrum_snr', 'id'};
for i = 1:length(fields)
    f = fields{i};
    assertEqual(d1.(f),d2.(f),sprintf('Field %s should be equal',f));
end

decs1 = d1.deconvolutions;
decs2 = d2.deconvolutions;
assertEqual(length(decs1), length(decs2));
for i = 1:length(decs1)
    dec1 = decs1(i);
    dec2 = decs2(i);
    approx_eq_fields = {'starting_point','starting_point_lb','starting_point_ub','peaks'};
    fields = fieldnames(dec1);
    for j = 1:length(fields)
        f = fields{j};
        if strcmp(f,'peaks')
            f1 = dec1.peaks.property_array; % Comparing the peak property array will produce better error messages
            f2 = dec2.peaks.property_array;
        else
            f1 = dec1.(f);
            f2 = dec2.(f);
        end
        if any(strcmp(f,approx_eq_fields))
            assertElementsAlmostEqual(f1,f2,sprintf(...
                'Field %s should be almost equal in deconvolution %d',f,i));
        else
            assertEqual(f1,f2,...
                sprintf('Field %s should be equal in deconvolution %d',f,i));
        end
    end
end


function idx = picker_idx(str)
% Usage: idx = picker_idx(str)
%
% Returns a unique index for str in the list of peak-picker names. If str
% is not in the list, returns [].
idx = find(strcmp(str, ExpDeconv.peak_picking_method_names));

function disabled_test_deconv_with_same_picker_have_same_picked_peaks %#ok<DEFNU>
% Check that deconvolutions in the same datum with the same picker have the
% same picked peaks.
old_rng = RandStream.getGlobalStream();
RandStream.setGlobalStream(RandStream('mt19937ar','Seed',1288700689));

datum = ExpDatum(1);
deconvolutions = datum.deconvolutions;

% Picked peaks{i} holds a list in which each element is a cell containing 
% either the name of the i'th peak picker or the first lists of peak 
% locations picked by that picker.
picked_peaks = ExpDeconv.peak_picking_method_names;
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

assertEqual(length(datum1.deconvolutions),20,'The permutations for reordering the deconvolutions need to be the same size for the test to work. Use randperm(length(datum1.deconvolutions)) to fix and do the same for datum2, then set this line to have the correct expected number of deconvolutions');
reordered_deconvs = datum1.deconvolutions([10 20 8 3 2 1 16 17 12 18 9 14 15 5 4 6 11 13 19 7]);
reordered1 = ExpDatum.dangerous_constructor(datum1.spectrum_peaks, ...
    datum1.spectrum_width, reordered_deconvs, datum1.resolution, ...
    datum1.spectrum_interval, datum1.spectrum, datum1.spectrum_snr, ...
    datum1.id);
updated_reordered1 = reordered1.updateDeconvolutions;

assertDatumObjectsEqual(datum1, updated_reordered1);

reordered_deconvs = datum2.deconvolutions([14 1 17 11 12 4 10 8 20 5 3 13 16 18 9 7 2 6 15 19]);
reordered2 = ExpDatum.dangerous_constructor(datum2.spectrum_peaks, ...
    datum2.spectrum_width, reordered_deconvs, datum2.resolution, ...
    datum2.spectrum_interval, datum2.spectrum, datum2.spectrum_snr, ...
    datum2.id);
updated_reordered2 = reordered2.updateDeconvolutions;

assertDatumObjectsEqual(datum2, updated_reordered2);

function test_update_correctly_restores_missing_picked_peaks %#ok<DEFNU>
% Check that when all deconvolutions for a particular peak picker have been
% removed, updateDeconvolutions creates the missing deconvolutions and
% picked peaks
%
% NOTE: the datum objects generated are different on 32 bit and 64 bit
% platforms (or more precisely on my home and work computers, so you need
% to delete the test data file and regenerate it when switching computers)
%
% Also note: you can't speed this up by removing some of the deconvolutions
% - if any with the same peak picker are there, the peak picker will not be
% regenerated and so the regeneration will not be properly tested
ensure_test_data_file_exists;
load(filename_for_test_data);

old_rng = RandStream.getGlobalStream();
RandStream.setGlobalStream(RandStream('mt19937ar','Seed',128870068));

gold_standard_deconvs = arrayfun(@(dec) strcmp(dec.peak_picker_name,ExpDeconv.pp_gold_standard), datum1.deconvolutions);
censored_deconvs = datum1.deconvolutions(~gold_standard_deconvs);
censored1 = ExpDatum.dangerous_constructor(datum1.spectrum_peaks, ...
    datum1.spectrum_width, censored_deconvs, datum1.resolution, ...
    datum1.spectrum_interval, datum1.spectrum, datum1.spectrum_snr, ...
    datum1.id);
updated_censored1 = censored1.updateDeconvolutions;

% If this is failing, check the note in the test description above
assertDatumObjectsEqual(datum1, updated_censored1);

smoothed_max_deconvs = arrayfun(@(dec) strcmp(dec.peak_picker_name,ExpDeconv.pp_smoothed_local_max), datum2.deconvolutions);
censored_deconvs = datum2.deconvolutions(~smoothed_max_deconvs);
censored2 = ExpDatum.dangerous_constructor(datum2.spectrum_peaks, ...
    datum2.spectrum_width, censored_deconvs, datum2.resolution, ...
    datum2.spectrum_interval, datum2.spectrum, datum2.spectrum_snr, ...
    datum2.id);
updated_censored2 = censored2.updateDeconvolutions;

assertDatumObjectsEqual(datum2, updated_censored2);

RandStream.setGlobalStream(old_rng);
