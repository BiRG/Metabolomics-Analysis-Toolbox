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

function testDistribution %#ok<DEFNU>
% Ensure that my distribution assumptions hold
oldRandStr = setRepeatableGen;
v = rand_dilutions(1000000,[0.1,10]);
full_counts = histc(v,[0.1,1,10]);
part_counts = histc(v,[0.1,0.2,5,10]);
assertEqual(full_counts([1,2]), [499399; 500601]); %These probabilities are close to equal
assertEqual(part_counts([1,3]), [277281; 278144]); %These probabilities are also close to equal
RandStream.setDefaultStream(oldRandStr);

function testPositiveException %#ok<DEFNU>
oldRandStr = setRepeatableGen;
f = @() rand_dilutions(100,[0,10]);
assertExceptionThrown(f, 'rand_dilutions:only_pos_dilutioons');
g = @() rand_dilutions(10,[-1,10]);
assertExceptionThrown(g, 'rand_dilutions:only_pos_dilutioons');
RandStream.setDefaultStream(oldRandStr);
