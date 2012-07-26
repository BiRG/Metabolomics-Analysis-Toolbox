function test_suite = test_subset_indices%#ok<STOUT>
%matlab_xUnit tests excercising subset_indices
%
% Usage:
%   runtests test_subset_indices
initTestSuite;

function oldRandStr = setRepeatableGen()
oldRandStr = RandStream.getDefaultStream;
randStr=RandStream('mt19937ar','Seed',3720541374);
RandStream.setDefaultStream(randStr);

function test_template_function %#ok<DEFNU>
% Description here
oldRandStr = setRepeatableGen;
RandStream.setDefaultStream(oldRandStr);


function test1Spec %#ok<DEFNU>
% Works with 1 spectrum
oldRandStr = setRepeatableGen;
f.Y=[1;2;3;4;5];
assertEqual(subset_indices(1,f), 1);
RandStream.setDefaultStream(oldRandStr);

function test2Spec1Index %#ok<DEFNU>
% Works with 2 spectra and 1 selected
oldRandStr = setRepeatableGen;
f.Y=[[1;2;3;4;5],[2;4;6;8;10]];
assertEqual(subset_indices(1,f), 1);
RandStream.setDefaultStream(oldRandStr);

function test2Spec0Index %#ok<DEFNU>
% Works with 2 spectra and 1 selected
oldRandStr = setRepeatableGen;
f.Y=[[1;2;3;4;5],[2;4;6;8;10]];
assertEqual(length(subset_indices(0,f)), 0);
RandStream.setDefaultStream(oldRandStr);

function test3Spec1Index %#ok<DEFNU>
% Works with 3 spectra and one selected
oldRandStr = setRepeatableGen;
f.Y=[[1;2;3;4;5],[2;4;6;8;10],[3;6;9;12;15]];
assertEqual(subset_indices(1,f), 3);
RandStream.setDefaultStream(oldRandStr);

function test3Spec2Indices %#ok<DEFNU>
% Works with 3 spectra and two selected
oldRandStr = setRepeatableGen;
f.Y=[[1;2;3;4;5],[2;4;6;8;10],[3;6;9;12;15]];
assertEqual(subset_indices(2,f), [3,1]);
RandStream.setDefaultStream(oldRandStr);

function testExceptionStruct %#ok<DEFNU>
% Throws exception when not passed a struct
oldRandStr = setRepeatableGen;
f.Y=[[1;2;3;4;5],[2;4;6;8;10],[3;6;9;12;15]];
assertExceptionThrown(@() subset_indices(2,{f}), ...
    'subset_indices:struct');
RandStream.setDefaultStream(oldRandStr);

function testExceptionHasYField %#ok<DEFNU>
% Throws exception when passed a struct without a field named Y
oldRandStr = setRepeatableGen;
f.z=[[1;2;3;4;5],[2;4;6;8;10],[3;6;9;12;15]];
assertExceptionThrown(@() subset_indices(2,f), ...
    'subset_indices:hasYField');
RandStream.setDefaultStream(oldRandStr);

function testExceptionHasNonNegSize %#ok<DEFNU>
% Throws exception when passed a negative size
oldRandStr = setRepeatableGen;
f.Y=[[1;2;3;4;5],[2;4;6;8;10],[3;6;9;12;15]];
assertExceptionThrown(@() subset_indices(-1,f), ...
    'subset_indices:non_neg_size');
RandStream.setDefaultStream(oldRandStr);

function testExceptionValidSubsetSize %#ok<DEFNU>
% Throws exception when passed a size that is greater than the number of 
% spectra in the original
oldRandStr = setRepeatableGen;
f.Y=[[1;2;3;4;5],[2;4;6;8;10],[3;6;9;12;15]];
assertExceptionThrown(@() subset_indices(4,f), ...
    'subset_indices:too_large_subset');
RandStream.setDefaultStream(oldRandStr);

