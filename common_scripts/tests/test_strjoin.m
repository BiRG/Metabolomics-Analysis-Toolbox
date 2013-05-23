function test_suite = test_strjoin%#ok<STOUT>
%matlab_xUnit tests excercising strjoin
%
% Usage:
%   runtests test_strjoin
initTestSuite;

function testExamples %#ok<DEFNU>
% Test the examples from the documentation
assertEqual(strjoin({}), '');
assertEqual(strjoin({},'asdf'), '');
assertEqual(strjoin({'Foo'},', '), 'Foo');
assertEqual(strjoin({'Foo','Bar'},', '), 'Foo, Bar');
assertEqual(strjoin({'Foo','Bar'}), 'Foo Bar');
assertEqual(strjoin({'Foo','Bar','Baz'},', '), 'Foo, Bar, Baz');
assertEqual(strjoin({'Foo','Bar'},{', '}), 'Foo, Bar');
assertEqual(strjoin({'Foo','Bar','Baz'},{', ',': '}), 'Foo, Bar: Baz');

f = @() strjoin({'Foo','Bar'},{', '});
assertExceptionThrown(f, 'strjoin:wrong_length_delim_array');



