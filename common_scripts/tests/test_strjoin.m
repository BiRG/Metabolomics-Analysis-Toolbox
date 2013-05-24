function test_suite = test_strjoin%#ok<STOUT>
%matlab_xUnit tests excercising strjoin
%
% Usage:
%   runtests test_strjoin
initTestSuite;

function b=only_called_to_generate_exception(a)
    b=a+1;

function id = too_many_inputs_id
% Returns the id of the matlab too many inputs exception. I wrote this
% function to provide cross-version compatibility since Matlab occasionally
% changes its exception identifiers.
try
    only_called_to_generate_exception(1,2,3);
catch ME
    id = ME.identifier;
end


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

f = @() strjoin({'Foo','Bar','Baz'},{', '});
assertExceptionThrown(f, 'strjoin:wrong_length_delim_array');

f = @() strjoin({'Foo','Bar','Baz'},92);
assertExceptionThrown(f, 'strjoin:delimiter_type');


f = @() strjoin({'Foo','Bar','Baz'},', ',': ');
assertExceptionThrown(f, too_many_inputs_id);
