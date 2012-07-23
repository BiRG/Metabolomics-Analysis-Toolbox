function test_suite = test_rand_dilutions%#ok<STOUT>
%matlab_xUnit tests excercising rand_dilutions
%
% Usage:
%   runtests test_rand_dilutions
initTestSuite;

function oldRandStr = setRepeatableGen()
oldRandStr = RandStream.getDefaultStream;
randStr=RandStream('mt19937ar','Seed',3720541374);
RandStream.setDefaultStream(randStr);


function template_function %#ok<DEFNU>
% Description here
oldRandStr = setRepeatableGen;
RandStream.setDefaultStream(oldRandStr);

function test2Entries0_1 %#ok<DEFNU>
% Description here
oldRandStr = setRepeatableGen;
assertElementsAlmostEqual(rand_dilutions(2,[0,1]),...
    [0.416920; 0.602142],...
    'absolute', 1e-6);
RandStream.setDefaultStream(oldRandStr);

function test3Entries0_1 %#ok<DEFNU>
% Description here
oldRandStr = setRepeatableGen;
assertElementsAlmostEqual(rand_dilutions(3,[0,1]),...
    [0.416920; 0.602142; 0.244945],...
    'absolute', 1e-6);
RandStream.setDefaultStream(oldRandStr);

function test3Entries10_11 %#ok<DEFNU>
% Description here
oldRandStr = setRepeatableGen;
assertElementsAlmostEqual(rand_dilutions(3,[10,11]),...
    [10.416920; 10.602142; 10.244945],...
    'absolute', 1e-6);
RandStream.setDefaultStream(oldRandStr);

function test3Entries10_20 %#ok<DEFNU>
% Description here
oldRandStr = setRepeatableGen;
assertElementsAlmostEqual(rand_dilutions(3,[10,20]),...
    [14.16920; 16.02142; 12.44945],...
    'absolute', 1e-5);
RandStream.setDefaultStream(oldRandStr);

function test3Entries10_10 %#ok<DEFNU>
% Description here
oldRandStr = setRepeatableGen;
assertElementsAlmostEqual(rand_dilutions(3,[10,10]),...
    [10; 10; 10], ...
    'absolute', 1e-5);
RandStream.setDefaultStream(oldRandStr);

function test0Entries10_20 %#ok<DEFNU>
% Description here
oldRandStr = setRepeatableGen;
assertTrue(isempty(rand_dilutions(0,[10,20])));
RandStream.setDefaultStream(oldRandStr);



