function test_suite = test_regularized_model %#ok<STOUT>
% matlab_xUnit tests excercising some parts of regularized_model
%
% Usage:
%   runtests test_regularized_model 
initTestSuite;

function test_zero_peaks %#ok<DEFNU>
% Check that error is error between flat response when 0 peaks requested

peak_BETA = [];
baseline_BETA=[0.5 0.5 4];
BETA = [peak_BETA baseline_BETA];
x=(0:0.01:0.1)';
x_baseline_BETA=[0 0.05 0.1];
model = RegionalSpectrumModel('v', 0, 0, 0.0052, 0.04, false, 'Short Peak 1st'); 
orig_data = [0.5000    0.4500    0.4000    0.3500    0.3000    0.2500    0.4000    0.5500    0.7000    0.8500    1.0000]'; % just a v
             
[errors, y_baseline] = regularized_model(BETA, x, 0, x_baseline_BETA, orig_data, model);

assertElementsAlmostEqual(errors, zeros(size(errors)));
assertElementsAlmostEqual(y_baseline, orig_data);
