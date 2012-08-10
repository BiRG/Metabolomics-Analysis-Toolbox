function test_suite = test_noise_samples%#ok<STOUT>
%matlab_xUnit tests excercising noise_samples
%
% Usage:
%   runtests test_noise_samples
initTestSuite;

function test3Spectra %#ok<DEFNU>
% Test using 3 spectra
f.Y=[1,1,1;2,2,2;1,1,1;4,5,6;7,8,9;2,3,4;4,3,2;5,5,5]; 
assertEqual(noise_samples(f,3,5), ...
    [true;true;true; false;false; true;true ;false]);

function test2Spectra %#ok<DEFNU>
% Test using 2 spectra
f.Y=[1,1;2,2;1,1;4,5;7,8;2,3;4,3;5,5]; 
assertEqual(noise_samples(f,3,5), ...
    [true;true;true; false;false; true;false ;false]);

function test1Spectrum %#ok<DEFNU>
% Test using 1 spectrum
f.Y=[1;2;1;5;8;3;3;5]; 
assertEqual(noise_samples(f,3,5), ...
    [true;true;true; false;false; false;false ;false]);

function testExceptionNotStruct %#ok<DEFNU>
% Test that exception thrown when the collection passed is not a struct
f.Y=[1;2;1;5;8;3;3;5]; 
assertExceptionThrown(@() noise_samples({f},3,5), ...
    'noise_samples:struct');

function testExceptionNoYField %#ok<DEFNU>
% Test that exception thrown when the collection passed has no Y field
f.z=[1;2;1;5;8;3;3;5]; 
assertExceptionThrown(@() noise_samples(f,3,5), ...
    'noise_samples:Y_field');

function testExceptionAtLeast1BaselinePt %#ok<DEFNU>
% Test that exception thrown when fewer than 1 baseline point is given
f.Y=[1;2;1;5;8;3;3;5]; 
assertExceptionThrown(@() noise_samples(f,0,5), ...
    'noise_samples:num_baseline_pts');

function testExceptionNoMoreBaselinePtsThanSamples %#ok<DEFNU>
% Test that exception thrown when more noise points are requested for the
% noise estimate than there are points in the spectrum.
f.Y=[1;2;1;5;8;3;3;5]; 
assertExceptionThrown(@() noise_samples(f,9,5), ...
    'noise_samples:num_baseline_pts_too_large');

function testExceptionNonNegStdDev %#ok<DEFNU>
% Test that exception thrown when the number of standard deviations above
% 0 is negative.
f.Y=[1;2;1;5;8;3;3;5]; 
assertExceptionThrown(@() noise_samples(f,3,-1), ...
    'noise_samples:num_std_dev');
