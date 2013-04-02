function test_suite = test_GLBIO2013_peak_loc_vs_param_errs %#ok<STOUT>
% matlab_xUnit tests excercising GLBIO2013_peak_loc_vs_param_errs
%
% Usage:
%   runtests test_GLBIO2013_peak_loc_vs_param_errs 
initTestSuite;

% Fields used of the GLBIO2013Datum
% spectrum_peaks, spectrum_width, deconvolutions, id
%
% Fields used of the GLBIO2013Deconv
% peak_picker_name, picked_locations, starting_point_name,
% peaks, aligned_indices, datum_id 

% result_idx - (row vector) the index (in results) of the result from
%     which the peak,parameter pair came
%
% deconv_idx - (row vector) the index of the deconvolution in
%     results(result_idx).deconvolutions from which the peak,parameter pair
%     came
%
% orig_pk_idx - (row vector) the index in 
%     results(result_idx).spectrum_peaks from which the original peak came.
%
% deconv_pk_idx - (row vector) the index in
%     results(result_idx).deconvolutions(deconv_idx).peaks which holds the
%     estimated peak from which the peak,parameter pair came
%
% picked_loc - (row vector) original location picked by the peak-picker for
%     this peak,parameter pair

function out = lpe(peak_loc_error, peak_width, param_error, ...
    result_idx, deconv_idx, orig_pk_idx, deconv_pk_idx, picked_loc)
% Shorthand for creating an loc_param_errs structure (see
% GLBIO2013_peak_loc_vs_param_errs docs for details) - used to save typing
% on creating the output
out = struct('peak_loc_error', peak_loc_error, 'peak_width', peak_width, ...
    'param_error', param_error, 'result_idx', result_idx, ...
    'deconv_idx', deconv_idx, 'orig_pk_idx', orig_pk_idx, ...
    'deconv_pk_idx', deconv_pk_idx, 'picked_loc', picked_loc);

function test_1_datum_2_deconv_same_order_noisy_gold %#ok<DEFNU>
%

% Create test input
orig_peak_matrix = [...
    1.0, 0.5, 0.00, 1, ... height width lor x0
    0.9, 0.5, 0.05, 2, ... height width lor x0
    0.8, 0.5, 0.10, 3, ... height width lor x0
    0.7, 0.5, 0.15, 4, ... height width lor x0
    0.6, 0.5, 0.20, 5, ... height width lor x0
    0.5, 0.5, 0.25, 6, ... height width lor x0
    0.4, 0.5, 0.30, 7
    ];
orig_peaks = GaussLorentzPeak(orig_peak_matrix);
orig_peak_widths = orig_peak_matrix(2:4:end);

anderson_deconv_loc_err = [0.01, -0.01, 0.02, -0.02, 0.03, -0.03, 0.04];
anderson_deconv_wid_err = [0.04, -0.04, 0.03, -0.03, 0.02, -0.02, 0.01];
anderson_deconv_lor_err = [0.00, -0.01, 0.01, -0.02, 0.03, -0.05, 0.08];
anderson_deconv_hei_err = [0.08, -0.04, 0.02, -0.01, 0.005, -0.0025, 0.00125];
anderson_deconv_err_matrix =  reshape([anderson_deconv_hei_err', anderson_deconv_wid_err', ...
    anderson_deconv_lor_err', anderson_deconv_loc_err']', 1, 4*7);

anderson_deconv_peaks = GaussLorentzPeak(orig_peak_matrix + anderson_deconv_err_matrix);

anderson_aligned_indices = [1:7; 1:7]; % Identity alignment

summit_deconv_loc_err = [0.01, -0.01, 0.02, -0.02, 0.03, -0.03, 0.04]/2;
summit_deconv_wid_err = [0.04, -0.04, 0.03, -0.03, 0.02, -0.02, 0.01]/2;
summit_deconv_lor_err = [0.00, -0.01, 0.01, -0.02, 0.03, -0.05, 0.08]/2;
summit_deconv_hei_err = [0.08, -0.04, 0.02, -0.01, 0.005, -0.0025, 0.00125]/2;

summit_deconv_err_matrix =  reshape([summit_deconv_hei_err', summit_deconv_wid_err', ...
    summit_deconv_lor_err', summit_deconv_loc_err']', 1, 4*7);

summit_deconv_peaks = GaussLorentzPeak(orig_peak_matrix + summit_deconv_err_matrix);

summit_aligned_indices = [1:7; 1:7]; % Identity alignment

picked_locs_err = [-0.03, 0.05, 0.05, 0.00, 0.03, -0.04, -0.01];
picked_locs = [orig_peaks.location]+picked_locs_err;

test_datum_id = 'test datum id';
anderson_deconv = GLBIO2013Deconv.dangerous_constructor( ...
    GLBIO2013Deconv.pp_noisy_gold_standard, ...
    picked_locs, GLBIO2013Deconv.dsp_anderson, [], [], [], ... % I don't set the 3 fields passed a [] because they are unused
    anderson_deconv_peaks, anderson_aligned_indices, test_datum_id);

summit_deconv = GLBIO2013Deconv.dangerous_constructor( ...
    GLBIO2013Deconv.pp_noisy_gold_standard, ...
    picked_locs, GLBIO2013Deconv.dsp_smallest_peak_first, [], [], [], ... % I don't set the 3 fields passed a [] because they are unused
    summit_deconv_peaks, summit_aligned_indices, test_datum_id);


datum = GLBIO2013Datum.dangerous_constructor(orig_peaks, ... % I don't set the 4 fields passed a [] because they are unused
            0.121507450820750054, [summit_deconv,anderson_deconv], [], ...
            [], [], [], test_datum_id);

% Create expected output

% lpe function is defined in this file - shorthand for declaring member of
% desired output

% Preallocate the array
expected(10, 4, 2) = lpe([],[],[],  [],[],[],[],[]); 

%function out = lpe(peak_loc_error, peak_width, param_error, ...
%    result_idx, deconv_idx, orig_pk_idx, deconv_pk_idx, picked_loc)


% Define errors for the anderson deconvolution
s = size(orig_peak_widths);
expected(9, 1, 1) = lpe(abs(picked_locs_err), orig_peak_widths, ...
    abs(anderson_deconv_hei_err), 1*ones(s), 2*ones(s), 1:7, 1:7, ...
    picked_locs);
expected(9, 2, 1) = lpe(abs(picked_locs_err), orig_peak_widths, ...
    abs(anderson_deconv_wid_err), 1*ones(s), 2*ones(s), 1:7, 1:7, ...
    picked_locs);
expected(9, 3, 1) = lpe(abs(picked_locs_err), orig_peak_widths, ...
    abs(anderson_deconv_lor_err), 1*ones(s), 2*ones(s), 1:7, 1:7, ...
    picked_locs);
expected(9, 4, 1) = lpe(abs(picked_locs_err), orig_peak_widths, ...
    abs(anderson_deconv_loc_err), 1*ones(s), 2*ones(s), 1:7, 1:7, ...
    picked_locs);

% Define errors for the summit deconvolution
expected(9, 1, 2) = lpe(abs(picked_locs_err), orig_peak_widths, ...
    abs(summit_deconv_hei_err), 1*ones(s), 1*ones(s), 1:7, 1:7, ...
    picked_locs);
expected(9, 2, 2) = lpe(abs(picked_locs_err), orig_peak_widths, ...
    abs(summit_deconv_wid_err), 1*ones(s), 1*ones(s), 1:7, 1:7, ...
    picked_locs);
expected(9, 3, 2) = lpe(abs(picked_locs_err), orig_peak_widths, ...
    abs(summit_deconv_lor_err), 1*ones(s), 1*ones(s), 1:7, 1:7, ...
    picked_locs);
expected(9, 4, 2) = lpe(abs(picked_locs_err), orig_peak_widths, ...
    abs(summit_deconv_loc_err), 1*ones(s), 1*ones(s), 1:7, 1:7, ...
    picked_locs);


% Get actual output

actual = GLBIO2013_peak_loc_vs_param_errs(datum);

% Compare actual and expected
assertEqual(size(actual),size(expected));
field_names = {'peak_loc_error', 'peak_width', 'param_error', ...
    'result_idx', 'deconv_idx', 'orig_pk_idx', 'deconv_pk_idx', ...
    'picked_loc'};
for prob = 1:10
    for param = 1:4
        for start_pt = 1:2
            for field_idx = 1:length(field_names)
                field_name = field_names{field_idx};
                assertElementsAlmostEqual(...
                    actual  (prob, param, start_pt).(field_name), ...
                    expected(prob, param, start_pt).(field_name), ...
                    sprintf('%s differs for entry (%d, %d, %d)', ...
                    field_name, prob, param, start_pt));
            end
        end
    end
end