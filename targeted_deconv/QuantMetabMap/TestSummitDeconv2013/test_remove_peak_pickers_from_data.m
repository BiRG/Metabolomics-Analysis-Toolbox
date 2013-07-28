function test_suite = test_remove_peak_pickers_from_data %#ok<STOUT>
% matlab_xUnit tests excercising remove_peak_pickers_from_data
%
% Usage:
%   runtests test_remove_peak_pickers_from_data 
initTestSuite;

function str=filename_for_test_data
% Return the name of the file in which the test data is stored
str = 'test_remove_peak_pickers_from_data_test_data_1.mat';

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
fields = {'spectrum_peaks','spectrum_width','deconvolutions' ...
    'resolution','spectrum_interval', 'spectrum', ...
    'spectrum_snr', 'id'};
for i = 1:length(fields)
    f = fields{i};
    assertEqual(d1.(f),d2.(f),sprintf('Field %s should be equal',f));
end


function idxs = indices_without_peak_pickers(picker_names)

expected_max_indices = ...
    length(ExpDeconv.deconvolution_starting_point_method_names) * ...
    length(ExpDeconv.peak_picking_method_names);
assertEqual(expected_max_indices, 20, 'Wrong number of deconvolutions. Need to revise test for remove_peak_pickers_From_data to use correct indices.');
all_idxs = 1:20;
excluded_idxs = [];
for picker_idx = 1:length(picker_names)
    peak_picker_name = picker_names{picker_idx};
    switch(peak_picker_name)
        case ExpDeconv.pp_gold_standard
            excluded_idxs = [excluded_idxs 1:5]; %#ok<AGROW>
        case ExpDeconv.pp_noisy_gold_standard
            excluded_idxs = [excluded_idxs 6:10]; %#ok<AGROW>
        case ExpDeconv.pp_smoothed_local_max
            excluded_idxs = [excluded_idxs 11:15]; %#ok<AGROW>
        case ExpDeconv.pp_gold_std_aligned_with_local_max
            excluded_idxs = [excluded_idxs 16:20]; %#ok<AGROW>
        otherwise
            % Detects additional methods having been added and no case
            % added to the switch statement
            error('GLBIO2013:unknown_pp_method', ...
                'Unknown peak picking method "%s" specified.',...
                peak_picker_name);
    end
end
excluded_idxs = sort(excluded_idxs);
idxs = setdiff(all_idxs, excluded_idxs);


function test_correctly_removes_deconvolutions %#ok<DEFNU>
% Check that requested deconvolutions are correctly removed from the given
% data
ensure_test_data_file_exists;
load(filename_for_test_data);


pickers = ExpDeconv.peak_picking_method_names;
orig_data = {datum1, datum2, [datum1 datum2]};
for picker1 = 1:length(pickers)
    for picker2 = 1:(picker1)
        if picker1 == picker2
            to_exclude = pickers(picker1);
        else
            to_exclude = pickers([picker2 picker1]);
        end
        included_idxs = indices_without_peak_pickers(to_exclude);
        for orig_data_idx = 1:length(orig_data)
            data = orig_data{orig_data_idx};
            expected = data;
            for i = 1:length(data)
                edited_deconvs = data(i).deconvolutions(included_idxs);
                expected(i) = ExpDatum.dangerous_constructor( ...
                    data(i).spectrum_peaks, data(i).spectrum_width, ...
                    edited_deconvs, data(i).resolution, ...
                    data(i).spectrum_interval, data(i).spectrum, data(i).spectrum_snr, ...
                    data(i).id);
            end
            actual = remove_peak_pickers_from_data(to_exclude, data);
            
            
            assertEqual(length(expected), length(actual));
            for i = 1:length(expected)
                assertDatumObjectsEqual(expected(i), actual(i));
            end
        end
    end
end

function test_has_error_on_bad_peak_picker %#ok<DEFNU>
% Check that throws an exception when an unknown peak picker is passed as the
% picker to remove
ensure_test_data_file_exists;
load(filename_for_test_data);

f = @() remove_peak_pickers_from_data({'not a valid peak picker'}, datum1);
assertExceptionThrown(f, 'GLBIO2013:unknown_pp_method');
