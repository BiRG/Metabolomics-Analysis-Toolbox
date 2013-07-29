function test_suite = test_RegionalSpectrumModel %#ok<STOUT>
% matlab_xUnit tests excercising some parts of RegionalSpectrumModel
%
% Usage:
%   runtests test_RegionalSpectrumModel 
initTestSuite;

function test_baseline_types %#ok<DEFNU>
% Ensure that baseline_types returns the correct list of acceptable baseline types
assertEqual(RegionalSpectrumModel.baseline_types, {'spline','constant','line_up','line_down','v'});

function test_rough_deconv_methods %#ok<DEFNU>
% Ensure that rough_deconv_methods returns the correct list of acceptable baseline types
assertEqual(RegionalSpectrumModel.rough_deconv_methods, {'Anderson','Summit-Focused'});

function test_constructor_default %#ok<DEFNU>
% Ensure that default constructor creates the expected object
model = RegionalSpectrumModel;
assertEqual(model.baseline_type, 'spline');
assertEqual(model.baseline_area_penalty, 0);
assertEqual(model.linewidth_variation_penalty, 0);
assertEqual(model.rough_peak_window_width, 0.0052);
assertEqual(model.max_rough_peak_width, 0.05);
assertEqual(model.only_do_rough_deconv, false);
assertEqual(model.rough_deconv_method, 'Summit-Focused');

function test_constructor_normal %#ok<DEFNU>
% Ensure a valid call to the normal constructor creates the expected object
model = RegionalSpectrumModel('v', 1, 2, 3, 4, true, 'Anderson'); 
assertEqual(model.baseline_type, 'v');
assertEqual(model.baseline_area_penalty, 1);
assertEqual(model.linewidth_variation_penalty, 2);
assertEqual(model.rough_peak_window_width, 3);
assertEqual(model.max_rough_peak_width, 4);
assertEqual(model.only_do_rough_deconv, true);
assertEqual(model.rough_deconv_method, 'Anderson');

function test_constructor_bad_baseline %#ok<DEFNU>
% Ensure that a call to the constructor with an invalid baseline throws an
% exception
fails = @() RegionalSpectrumModel('not_a_valid_baseline', 1, 2, 3, 4, true, 'Anderson'); 
assertExceptionThrown(fails, 'RegionalSpectrumModel:bad_baseline');

function test_constructor_bad_start_pt %#ok<DEFNU>
% Ensure that a call to the constructor with an invalid rough deconvolution
% method thros an exception
fails = @() RegionalSpectrumModel('v', 1, 2, 3, 4, true, 'not a valid method'); 
assertExceptionThrown(fails, 'RegionalSpectrumModel:bad_method');
