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

function test2Entries1_2 %#ok<DEFNU>
% Simplest - just add 1 to the original values from the generator
oldRandStr = setRepeatableGen;
assertElementsAlmostEqual(rand_dilutions(2,[1,2]),...
    [1.416920; 1.602142],...
    'absolute', 1e-6);
RandStream.setDefaultStream(oldRandStr);

function test3Entries1_2 %#ok<DEFNU>
% Now make sure that deals with the number of entries correctl
oldRandStr = setRepeatableGen;
assertElementsAlmostEqual(rand_dilutions(3,[1,2]),...
    [1.416920; 1.602142; 1.244945],...
    'absolute', 1e-6);
RandStream.setDefaultStream(oldRandStr);

function test3Entries10_11 %#ok<DEFNU>
% Now, we add 10 to the original values from the generator
oldRandStr = setRepeatableGen;
assertElementsAlmostEqual(rand_dilutions(3,[10,11]),...
    [10.416920; 10.602142; 10.244945],...
    'absolute', 1e-6);
RandStream.setDefaultStream(oldRandStr);

function test3Entries10_20 %#ok<DEFNU>
% Now we add 10 to 10 times the original values
oldRandStr = setRepeatableGen;
assertElementsAlmostEqual(rand_dilutions(3,[10,20]),...
    [14.16920; 16.02142; 12.44945],...
    'absolute', 1e-5);
RandStream.setDefaultStream(oldRandStr);

function test3Entries10_10 %#ok<DEFNU>
% Ensure that an empty range produces the same values always
oldRandStr = setRepeatableGen;
assertElementsAlmostEqual(rand_dilutions(3,[10,10]),...
    [10; 10; 10], ...
    'absolute', 1e-5);
RandStream.setDefaultStream(oldRandStr);

function test0Entries10_20 %#ok<DEFNU>
% Ensure that a request for an empty vector is correctly fulfilled
oldRandStr = setRepeatableGen;
assertTrue(isempty(rand_dilutions(0,[10,20])));
RandStream.setDefaultStream(oldRandStr);

function testDistributionSymmetric %#ok<DEFNU>
% Ensure that my distribution assumptions hold when the range is symmetric
oldRandStr = setRepeatableGen;
v = rand_dilutions(1000000,[0.1,10]);
full_counts = histc(v,[0.1,1,10]);
part_counts = histc(v,[0.1,0.2,5,10]);
assertElementsAlmostEqual(full_counts(1),full_counts(2),'relative',0.005);
assertElementsAlmostEqual(part_counts(1),part_counts(3),'relative',0.005);
RandStream.setDefaultStream(oldRandStr);

function testDistributionAsymmetric %#ok<DEFNU>
% Ensure that my distribution assumptions hold when the range is asymmetric
oldRandStr = setRepeatableGen;
v = rand_dilutions(1000000,[0.1,20]);
full_counts = histc(v,[0.1,1,10]);
part_counts = histc(v,[0.1,0.2,5,10]);
assertElementsAlmostEqual(full_counts(1),full_counts(2),'relative',0.005);
assertElementsAlmostEqual(part_counts(1),part_counts(3),'relative',0.005);
RandStream.setDefaultStream(oldRandStr);

function testPositiveRangeException %#ok<DEFNU>
% Ensure that negative or 0 elements of the range are rejected with an
% exception
oldRandStr = setRepeatableGen;
f = @() rand_dilutions(100,[0,10]);
assertExceptionThrown(f, 'rand_dilutions:only_pos_dilutions');
g = @() rand_dilutions(10,[-1,10]);
assertExceptionThrown(g, 'rand_dilutions:only_pos_dilutions');
RandStream.setDefaultStream(oldRandStr);

function testRangeIs2Exception %#ok<DEFNU>
% Ensure that ranges that don't have two elements are rejected with an
% exception
oldRandStr = setRepeatableGen;
f = @() rand_dilutions(100,2);
assertExceptionThrown(f, 'rand_dilutions:two_element_range');
g = @() rand_dilutions(10,[5,10,20]);
assertExceptionThrown(g, 'rand_dilutions:two_element_range');
h = @() rand_dilutions(10,[]);
assertExceptionThrown(h, 'rand_dilutions:two_element_range');
RandStream.setDefaultStream(oldRandStr);

function testInOrderRangeException %#ok<DEFNU>
% Ensure that exception thrown when second element of range is less than 
% first
oldRandStr = setRepeatableGen;
f = @() rand_dilutions(10,[10,9]);
assertExceptionThrown(f, 'rand_dilutions:range_is_min_max');
RandStream.setDefaultStream(oldRandStr);

function testNonNegDilutionsException %#ok<DEFNU>
% Ensure that exception thrown when number of dilutions is negative
oldRandStr = setRepeatableGen;
f = @() rand_dilutions(-1,[10,11]);
assertExceptionThrown(f, 'rand_dilutions:non_neg_num_dilutions');
RandStream.setDefaultStream(oldRandStr);
