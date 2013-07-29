function test_suite = test_regularized_model %#ok<STOUT>
% matlab_xUnit tests excercising some parts of regularized_model
%
% Usage:
%   runtests test_regularized_model 
initTestSuite;

function test_zero_peaks_and_baselines %#ok<DEFNU>
% Check that error is error for a flat response when 0 peaks requested.
% Also checks that 'v', 'line_up', 'line_down', 'constant', and spline
% baselines work.

peak_BETA = [];
x_baseline_BETA=[0 0.05 0.1];
x=(0:0.01:0.1)';

% V baseline
baseline_BETA=[0.5 0.5 4];
model = RegionalSpectrumModel('v', 0, 0, 0.0052, 0.04, false, 'Summit-Focused'); 
expected_v_baseline = [0.5000    0.4500    0.4000    0.3500    0.3000    0.2500    0.4000    0.5500    0.7000    0.8500    1.0000]'; % just a v

% Eval V baseline
BETA = [peak_BETA baseline_BETA];
[errors, y_baseline] = regularized_model(BETA, x, 0, x_baseline_BETA, expected_v_baseline, model);
assertElementsAlmostEqual(errors, zeros(size(errors)));
assertElementsAlmostEqual(y_baseline, expected_v_baseline);

% Line up baseline
baseline_BETA=[1 2];
model = RegionalSpectrumModel('line_up', 0, 0, 0.0052, 0.04, false, 'Summit-Focused'); 
expected_line_up_baseline = 2*x+1; % a line with positive slope

% Eval line_up baseline
BETA = [peak_BETA baseline_BETA];
[errors, y_baseline] = regularized_model(BETA, x, 0, x_baseline_BETA, expected_line_up_baseline, model);
assertElementsAlmostEqual(errors, zeros(size(errors)));
assertElementsAlmostEqual(y_baseline, expected_line_up_baseline);

% Line down baseline
baseline_BETA=[1 -2];
model = RegionalSpectrumModel('line_down', 0, 0, 0.0052, 0.04, false, 'Summit-Focused'); 
expected_line_down_baseline = -2*x+1; % a line with positive slope

% Eval line_down baseline
BETA = [peak_BETA baseline_BETA];
[errors, y_baseline] = regularized_model(BETA, x, 0, x_baseline_BETA, expected_line_down_baseline, model);
assertElementsAlmostEqual(errors, zeros(size(errors)));
assertElementsAlmostEqual(y_baseline, expected_line_down_baseline);

% Constant baseline
baseline_BETA=6;
model = RegionalSpectrumModel('constant', 0, 0, 0.0052, 0.04, false, 'Summit-Focused'); 
expected_constant_baseline = 6*ones(size(x)); % a constant

% Eval constant baseline
BETA = [peak_BETA baseline_BETA];
[errors, y_baseline] = regularized_model(BETA, x, 0, x_baseline_BETA, expected_constant_baseline, model);
assertElementsAlmostEqual(errors, zeros(size(errors)));
assertElementsAlmostEqual(y_baseline, expected_constant_baseline);


% spline baseline
baseline_BETA=[10 0 5];
model = RegionalSpectrumModel('spline', 0, 0, 0.0052, 0.04, false, 'Summit-Focused'); 
expected_spline_baseline = interp1(x_baseline_BETA, baseline_BETA, x, 'pchip'); % a cubic spline

% Eval spline baseline
BETA = [peak_BETA baseline_BETA];
[errors, y_baseline] = regularized_model(BETA, x, 0, x_baseline_BETA, expected_spline_baseline, model);
assertElementsAlmostEqual(errors, zeros(size(errors)));
assertElementsAlmostEqual(y_baseline, expected_spline_baseline);

% bad baseline type
baseline_BETA=[10 0 5];
model = RegionalSpectrumModel('constant', 0, 0, 0.0052, 0.04, false, 'Summit-Focused'); 
model.baseline_type = 'not_a_baseline_type';
expected_spline_baseline = interp1(x_baseline_BETA, baseline_BETA, x, 'pchip'); % a cubic spline

% Eval spline baseline
BETA = [peak_BETA baseline_BETA];
should_throw = @() regularized_model(BETA, x, 0, x_baseline_BETA, expected_spline_baseline, model);
assertExceptionThrown(should_throw, 'regularized_model:bad_baseline_type');

function test_single_x %#ok<DEFNU>
% Check that correct values are returned when there is a single x value -
% including the peak area error regularization

peak_BETA = [];
x_baseline_BETA=[0 0.05 0.1];
x=1;

% Constant baseline with 0 peaks ane 1 x
baseline_BETA=6;
model = RegionalSpectrumModel('constant', 1, 0, 0.0052, 0.04, false, 'Summit-Focused'); 
expected_constant_baseline = 6*ones(size(x)); % a constant

% Eval constant baseline
BETA = [peak_BETA baseline_BETA];
[errors, y_baseline] = regularized_model(BETA, x, 0, x_baseline_BETA, expected_constant_baseline, model);
assertElementsAlmostEqual(errors, [zeros(size(errors)-[2,0]);6;0]);
assertElementsAlmostEqual(y_baseline, expected_constant_baseline);

function test_single_peak %#ok<DEFNU>
% Check that correct values are returned when there is a single peak
% including the peak width variance regularization

peak_BETA = [2, 0.01, 1, 0.05];
x_baseline_BETA=[0 0.05 0.1];
x=(0:0.01:0.1)';
expected_peak_values = [0.0198019801980197988, 0.0307692307692307675, 0.0540540540540540501, 0.117647058823529368, 0.399999999999999856, 2, 0.399999999999999856, 0.117647058823529368, 0.054054054054054064, 0.0307692307692307571, 0.0198019801980197988]';

% Constant baseline with 0 peaks ane 1 x
baseline_BETA=6;
model = RegionalSpectrumModel('constant', 0, 1, 0.0052, 0.04, false, 'Summit-Focused'); 
expected_constant_baseline = 6*ones(size(x)); % a constant

% Eval constant baseline
BETA = [peak_BETA baseline_BETA];
[errors, y_baseline] = regularized_model(BETA, x, floor(length(peak_BETA)/4), x_baseline_BETA, expected_constant_baseline+expected_peak_values, model);
assertElementsAlmostEqual(errors, zeros(size(errors)))
assertElementsAlmostEqual(y_baseline, expected_constant_baseline);

function test_double_peak %#ok<DEFNU>
% Check that correct values are returned when there are two peaks
% including the peak width variance regularization

peak_BETA = [2, 0.01, 1, 0.01, 1, 0.001, 1, 0.09];
x_baseline_BETA=[0 0.05 0.1];
x=(0:0.01:0.1)';
expected_peak_values = [0.400030863244961621, 2.00003906097418049, 0.400051017805214015, 0.117716498445777903, 0.0541540440550539667, 0.0309254563589823686, 0.0200796808367312667, 0.0144177130672639934, 0.0126460498499943053, 1.00778210116731515, 0.00864761173988106042]';

% Constant baseline with 0 peaks ane 1 x
baseline_BETA=6;
model = RegionalSpectrumModel('constant', 0, 1, 0.0052, 0.04, false, 'Summit-Focused'); 
expected_constant_baseline = 6*ones(size(x)); % a constant

% Eval constant baseline
BETA = [peak_BETA baseline_BETA];
[errors, y_baseline] = regularized_model(BETA, x, floor(length(peak_BETA)/4), x_baseline_BETA, expected_constant_baseline+expected_peak_values, model);
assertElementsAlmostEqual(errors, [zeros(size(errors)-[1,0]);0.00636396103067892772]);
assertElementsAlmostEqual(y_baseline, expected_constant_baseline);
