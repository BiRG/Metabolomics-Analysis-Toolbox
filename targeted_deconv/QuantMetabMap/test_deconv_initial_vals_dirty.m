function test_suite = test_deconv_initial_vals_dirty %#ok<STOUT>
%matlab_xUnit tests excercising deconv_initial_vals_dirty
%
% Usage:
%   runtests test_deconv_initial_vals_dirty 
initTestSuite;

function testTwoClosePeaks %#ok<DEFNU>
% Tests that outputs haven't changed for inputs of two close peaks and no
% noise

peaks = GaussLorentzPeak([1,.02,1,0.5,   1,.02,1,0.500000001]);
spec.x = 0:0.0001:1;
spec.Y = sum(peaks.at(spec.x),1)';
[b,lb,ub]=deconv_initial_vals_dirty(spec.x, spec.Y, 0,1,[0.5, 0.500000001], ...
    0.04, 12, @do_nothing);

expected_b  = [7.446009559292229e-15; 0.011741640299113645; 3.499735503745569e-05; 0.5; 2.0000000013449766; 0.019999990356467118; 1; 0.50000000099999997];
expected_lb = [0; 0; 0; 0.49999999950000001; 0; 0; 0; 0.50000000050000004];
expected_ub = [1.99999999999999; 0.044775040528527543; 1; 0.50000000050000004; 1.99999999999999; 0.044775040528527543; 1; 0.5000000014999999];

assertElementsAlmostEqual(b, expected_b);
assertElementsAlmostEqual(lb, expected_lb);
assertElementsAlmostEqual(ub, expected_ub);

function testOnePeak %#ok<DEFNU>
% Tests that outputs haven't changed for inputs of a single peak

peaks = GaussLorentzPeak([1,.02,1,0.5]);
spec.x = 0:0.0001:1;
spec.Y = sum(peaks.at(spec.x),1)';
[b,lb,ub]=deconv_initial_vals_dirty(spec.x, spec.Y, 0,1,0.5, ...
    0.04, 12, @do_nothing);

expected_b  = [1; 0.02; 1; 0.5];
expected_lb = [1; 0; 0; 0];
expected_ub = [1; 0.04; 1; 1];

assertElementsAlmostEqual(b, expected_b);
assertElementsAlmostEqual(lb, expected_lb);
assertElementsAlmostEqual(ub, expected_ub);

function testThreePeaks %#ok<DEFNU>
% Tests that outputs haven't changed for inputs of a three peaks (and use
% the default progress function of no function

peaks = GaussLorentzPeak([1,.005,1,0.25, 1,.005,1,0.5, 1,.005,1,0.75]);
spec.x = 0:0.0001:1;
spec.Y = sum(peaks.at(spec.x),1)';
[b,lb,ub]=deconv_initial_vals_dirty(spec.x, spec.Y, 0,1,[0.25,0.5,0.75], ...
    0.04, 12);

expected_b  = [1;.005;1;0.25;    1;.005;1;0.5;     1;.005;1;0.75];
expected_lb = [0; 0; 0; 0.125;   0; 0; 0; 0.375;   0; 0; 0; 0.625];
expected_ub = [1.0001249893760156; 0.0050000003087130734; 1; 0.375; ...
               1.0001999800019998; 0.0050000003087130734; 1; 0.625; ...
               1.0001249893760156; 0.0050000003087130734; 1; 0.875];

assertElementsAlmostEqual(b, expected_b);
assertElementsAlmostEqual(lb, expected_lb);
assertElementsAlmostEqual(ub, expected_ub);

function testSixPeaksTwoLoc %#ok<DEFNU>
% Tests that outputs haven't changed for inputs of a six peaks with two
% groups of three being at the same location.

peaks = GaussLorentzPeak([1,.005,1,0.5, 1,.005,1,0.5, 1,.005,1,0.5, 1,.005,1,0.75,   1,.005,1,0.75,   1,.005,1,0.75]);
spec.x = 0:0.0001:1;
spec.Y = sum(peaks.at(spec.x),1)';
[b,lb,ub]=deconv_initial_vals_dirty(spec.x, spec.Y, 0,1,[0.5, 0.5, 0.5, 0.75, 0.75, 0.75], ...
    0.04, 12);

expected_b  = [3; 0.00499996;  1; 0.5; 
               0; 0.000238014; 1; 0.5; 
               0; 0.000442323; 1; 0.5; 
               3; 0.005; 1; 0.75; 
               0; 0.000206562; 1; 0.75; 
               0; 0.00879698;  1; 0.75];


expected_lb = [0; 0; 0; 0.5; 
               0; 0; 0; 0.5; 
               0; 0; 0; 0.5; 
               0; 0; 0; 0.625; 
               0; 0; 0; 0.625; 
               0; 0; 0; 0.625];

expected_ub = [3.0003; 0.019286; 1; 0.625; 
               3.0003; 0.019286; 1; 0.625; 
               3.0003; 0.019286; 1; 0.625; 
               3.0003; 0.019286; 1; 0.75; 
               3.0003; 0.019286; 1; 0.75; 
               3.0003; 0.019286; 1; 0.75];


assertElementsAlmostEqual(b,  expected_b,  'absolute', 1e-4);
assertElementsAlmostEqual(lb, expected_lb, 'absolute', 1e-4);
assertElementsAlmostEqual(ub, expected_ub, 'absolute', 1e-4);

function testThreePeaksOneLoc %#ok<DEFNU>
% Tests that outputs haven't changed for inputs of a three peaks with all
% at 0.5

peaks = GaussLorentzPeak([1,.005,1,0.5, 1,.005,1,0.5, 1,.005,1,0.5]);
spec.x = 0:0.0001:1;
spec.Y = sum(peaks.at(spec.x),1)';
[b,lb,ub]=deconv_initial_vals_dirty(spec.x, spec.Y, 0,1,[0.5, 0.5, 0.5], ...
    0.04, 12);

expected_b  = [3; 0.00499996;  0.9997; 0.5; 
               0; 0.04; 0; 0.5; 
               0; 0.0139; 0.56; 0.5];


expected_lb = [0; 0; 0; 0.5; 
               0; 0; 0; 0.5; 
               0; 0; 0; 0.5];

expected_ub = [3.000; 0.1122; 1; .5;
               3.000; 0.1122; 1; .5;
               3.000; 0.1122; 1; .5];


assertElementsAlmostEqual(b,  expected_b,  'absolute', 1e-4);
assertElementsAlmostEqual(lb, expected_lb, 'absolute', 1e-4);
assertElementsAlmostEqual(ub, expected_ub, 'absolute', 1e-4);

function testNotEnoughPeaks %#ok<DEFNU>
% Tests that errors are thrown when the function is called without enough
% peaks

peaks = GaussLorentzPeak([1,.005,1,0.25]);
spec.x = 0:0.0001:1;
spec.Y = sum(peaks.at(spec.x),1)';

a=@() deconv_initial_vals_dirty(spec.x, spec.Y, 0,1,[], ...
    0.04, 12);
assertExceptionThrown(a, 'deconv_initial_vals_dirty:at_least_one_peak');
b=@() deconv_initial_vals_dirty(spec.x, spec.Y, 0.5,1,0.25, ...
    0.04, 12);
assertExceptionThrown(b, 'deconv_initial_vals_dirty:at_least_one_peak');

