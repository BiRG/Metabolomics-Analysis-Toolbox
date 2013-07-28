function test_suite = test_width_for_collision_prob %#ok<STOUT>
% matlab_xUnit tests excercising width_for_collision_prob
%
% Usage:
%   runtests test_width_for_collision_prob 
initTestSuite;

function test_results %#ok<DEFNU>
mean_peak_width = 0.00453630122481774988;
assertEqual(width_for_collision_prob(1),5.75*mean_peak_width);
assertEqual(width_for_collision_prob(0.5),86.66187912294609*mean_peak_width);
f=@() width_for_collision_prob(0.01);
assertExceptionThrown(f, 'width_for_collision_prob:unknown_prob');
