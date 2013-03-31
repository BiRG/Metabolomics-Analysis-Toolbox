function test_suite = test_random_spec_from_nssd_data %#ok<STOUT>
% matlab_xUnit tests excercising random_spec_from_nssd_data
%
% Usage:
%   runtests test_random_spec_from_nssd_data 
initTestSuite;

function test_num_peaks_less_than_0 %#ok<DEFNU>
% Check that gives error when less than 0 peaks requested
old_rng = RandStream.getGlobalStream();
RandStream.setGlobalStream(RandStream('mt19937ar','Seed',1288700689));


RandStream.setGlobalStream(old_rng);

function test_num_peaks_equal_to_0 %#ok<DEFNU>
% Check that gives flat spectrum when 0 peaks selected.
old_rng = RandStream.getGlobalStream();
RandStream.setGlobalStream(RandStream('mt19937ar','Seed',1288700689));


RandStream.setGlobalStream(old_rng);

