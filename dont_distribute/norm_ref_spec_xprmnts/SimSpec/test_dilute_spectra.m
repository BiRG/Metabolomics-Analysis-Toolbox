function test_suite = test_dilute_spectra%#ok<STOUT>
%matlab_xUnit tests excercising dilute_spectra
%
% Usage:
%   runtests test_dilute_spectra
initTestSuite;

function testSimpleCase %#ok<DEFNU>
% The case I used in bench-testing
f.Y = [1,2,4; 2,4,8; 3,6,12]; 
d=dilute_spectra(f, [1,2,2]);

assertEqual(d.Y, [1,1,2; 2,2,4; 3,3,6]);
assertEqual(d.original_multiplied_by, [1, 0.5, 0.5]);

function testExceptionStruct %#ok<DEFNU>
sp.Y = [1,2,4; 2,4,8; 3,6,12]; 
assertExceptionThrown(@() dilute_spectra({sp}, [1,2,2]), ...
    'dilute_spectra:struct');

function testExceptionYField %#ok<DEFNU>
sp.x = [1,2,4; 2,4,8; 3,6,12]; 
assertExceptionThrown(@() dilute_spectra(sp, [1,2,2]), ...
    'dilute_spectra:y_field');

function testExceptionDilutionsIsVector %#ok<DEFNU>
sp.Y = [1,2,4; 2,4,8; 3,6,12]; 
assertExceptionThrown(@() dilute_spectra(sp, [1,2,2; 1,2,2]), ...
    'dilute_spectra:vector_dilutions');

function testExceptionDilutionsRightDim %#ok<DEFNU>
sp.Y = [1,2,4; 2,4,8; 3,6,12]; 
assertExceptionThrown(@() dilute_spectra(sp, [1,2,2]'), ...
    'dilute_spectra:vector_dim');

function testExceptionDilutionsPos %#ok<DEFNU>
sp.Y = [1,2,4; 2,4,8; 3,6,12]; 
assertExceptionThrown(@() dilute_spectra(sp, [1,-2,2]), ...
    'dilute_spectra:pos_dilutions');
assertExceptionThrown(@() dilute_spectra(sp, [1,2,0]), ...
    'dilute_spectra:pos_dilutions');
