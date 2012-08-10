function test_suite = test_horzcat_structs%#ok<STOUT>
%matlab_xUnit tests excercising horzcat_structs
%
% Usage:
%   runtests test_horzcat_structs
initTestSuite;

function testSimpleCase %#ok<DEFNU>
% The case I used in bench-testing

f.a='abc';
f.b=1;
f.c=[1,2,3];

g.a='xyz';
g.x=26;
g.c=[24,25,26];

expected.a='abcxyz';
expected.b=1;
expected.c=[1,2,3,24,25,26];
expected.x=26;

assertEqual(horzcat_structs(f,g), expected);
