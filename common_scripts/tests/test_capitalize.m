function test_suite = test_capitalize%#ok<STOUT>
%matlab_xUnit tests excercising capitalize
%
% Usage:
%   runtests test_capitalize
initTestSuite;

function testExamples %#ok<DEFNU>
% Test the examples from the documentation
assertEqual('Foo',  capitalize('foo'));
assertEqual('Bar',  capitalize('Bar'));
assertEqual(' woo', capitalize(' woo'));
assertEqual('',     capitalize(''));

