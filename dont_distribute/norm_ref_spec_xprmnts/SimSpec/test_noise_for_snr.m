function test_suite = test_noise_for_snr%#ok<STOUT>
%matlab_xUnit tests excercising noise_for_snr
%
% Usage:
%   runtests test_noise_for_snr
initTestSuite;

function testSimpleCase %#ok<DEFNU>
% The case I used in bench-testing

f.Y=[1,2; 10,2; 1,20];

assertEqual(noise_for_snr(f, 1), [10, 20]);

function testSimpleCaseWithSNR2 %#ok<DEFNU>
% This time, a simple case with a target SNR of 2.

f.Y=[1,2,4; 10,2,4; 1,20,4];

assertEqual(noise_for_snr(f, 2), [5, 10, 2]);

function testExceptionStruct %#ok<DEFNU>
% Test that an exception is thrown when the collection passed is not a struct
f.Y=[1,2,4; 10,2,4; 1,20,4];

assertExceptionThrown(@() noise_for_snr({f}, 1), ...
    'noise_for_snr:struct');

function testExceptionYField %#ok<DEFNU>
% Test that an exception is thrown when the collection passed lacks a field
% named Y
f.x=[1,2,4; 10,2,4; 1,20,4];

assertExceptionThrown(@() noise_for_snr(f, 1), ...
    'noise_for_snr:Y_field');

function testExceptionPosSNR %#ok<DEFNU>
% Test that an exception is thrown when the snr passed is not positive
f.Y=[1,2,4; 10,2,4; 1,20,4];

assertExceptionThrown(@() noise_for_snr(f, 0), ...
    'noise_for_snr:pos_snr');

assertExceptionThrown(@() noise_for_snr(f, -1), ...
    'noise_for_snr:pos_snr');
