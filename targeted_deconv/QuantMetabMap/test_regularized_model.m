function test_suite = test_regularized_model %#ok<STOUT>
% matlab_xUnit tests excercising some parts of regularized_model
%
% Usage:
%   runtests test_regularized_model 
initTestSuite;

function id = assert_id
% Return the identifier used for assertion failures - this is different
% between different Matlab versions, so I calculate it here
try
    assert(false);
catch ME
    id = ME.identifier;
end

function test_num_peaks_less_than_0 %#ok<DEFNU>
% Check that gives error when less than 0 peaks requested

f=@() random_spec_from_nssd_data(-1,-1,1,100,1);
assertExceptionThrown(f, assert_id);

