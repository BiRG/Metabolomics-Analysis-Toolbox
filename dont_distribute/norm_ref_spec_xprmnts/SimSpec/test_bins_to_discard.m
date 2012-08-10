function test_suite = test_bins_to_discard%#ok<STOUT>
%matlab_xUnit tests excercising bins_to_discard
%
% Usage:
%   runtests test_bins_to_discard
initTestSuite;

function test0ToDiscard4Bins %#ok<DEFNU>
% Ensure correct output when 0 samples to discard and 4 bins to put them
% in.
f.x = [10,20,30,40];
assertEqual(bins_to_discard( f, []), [false, false, false, false]);

function test1ToDiscard4Bins %#ok<DEFNU>
% Ensure correct output when 1 sample to discard and 4 bins to put them
% in.
f.x = [10,20,30,40];
assertEqual(bins_to_discard( f, 21), [false, true, false, false]);

function test2ToDiscard4BinsSame %#ok<DEFNU>
% Ensure correct output when 2 samples to discard and 4 bins to put them
% in (the two are in the same bin).
f.x = [10,20,30,40];
assertEqual(bins_to_discard( f, [19, 21]), [false, true, false, false]);

function test2ToDiscard4BinsDiffA %#ok<DEFNU>
% Ensure correct output when 2 samples to discard and 4 bins to put them
% in (the two are in different bins).
f.x = [10,20,30,40];
assertEqual(bins_to_discard( f, [19, 36]), [false, true, false, true]);

function test2ToDiscard4BinsDiffB %#ok<DEFNU>
% Ensure correct output when 2 samples to discard and 4 bins to put them
% in (the two are in different bins).
f.x = [10,20,30,40];
assertEqual(bins_to_discard( f, [25, 26]), [false, true, true, false]);

function test3ToDiscard4Bins %#ok<DEFNU>
% Ensure correct output when 3 samples to discard and 4 bins to put them
% in 
f.x = [10,20,30,40];
assertEqual(bins_to_discard( f, [-100,26,500]), [true, false, true, true]);

function testExceptionStruct %#ok<DEFNU>
% Ensure exception thrown when the collection passed is not a struct
f.x = [10,20,30,40];
assertExceptionThrown(@() bins_to_discard( {f}, [-100,26,500]), ...
    'bins_to_discard:struct');

function testExceptionXField %#ok<DEFNU>
% Ensure exception thrown when the collection passed lacks an x field
f.Y = [10,20,30,40];
assertExceptionThrown(@() bins_to_discard( f, [-100,26,500]), ...
    'bins_to_discard:x_field');

function testExceptionXFieldVec %#ok<DEFNU>
% Ensure exception thrown when the x field of the collection passed is not
% a vector
f.x = [10,20,30,40; 10,20,30,40];
assertExceptionThrown(@() bins_to_discard( f, [-100,26,500]), ...
    'bins_to_discard:x_field_vec');

function testExceptionNonEmptyXField %#ok<DEFNU>
% Ensure exception thrown when the collection's x field is empty
f.x = [];
assertExceptionThrown(@() bins_to_discard( f, [-100,26,500]), ...
    'bins_to_discard:x_field_nonempty');

function testExceptionDiscardXIsVec %#ok<DEFNU>
% Ensure exception thrown when discard_x is not a vector
f.x = [10,20,30,40];
assertExceptionThrown(@() bins_to_discard( f, [-100,26;500,10]), ...
    'bins_to_discard:discard_x_is_vector');
