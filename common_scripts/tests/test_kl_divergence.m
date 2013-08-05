function test_suite = test_kl_divergence%#ok<STOUT>
%matlab_xUnit tests excercising kl_divergence
%
% Usage:
%   runtests test_kl_divergence
initTestSuite;

function id = assert_id
% Return the identifier used for assertion failures - this is different
% between different Matlab versions, so I calculate it here
try
    assert(false);
catch ME
    id = ME.identifier;
end


function testExamples %#ok<DEFNU>
% Test the examples from the documentation

assertEqual(kl_divergence([0.25 0.25 0.5],[0.25 0.25 0.5]), 0);
assertEqual(kl_divergence([],[]), 0);
assertEqual(kl_divergence([0.25 0.25 0.5],[0.25 0.5 0.25]), 0.25);
assertEqual(kl_divergence([0.25 0.5 0.25 0],[0.25 0.25 0.25 0.25]), 0.5);
assertEqual(kl_divergence([0 0.25 0.25 0.5],[0.25 0.25 0.5 0.25]), 0.25);
assertEqual(kl_divergence([0.25 0.25 0.5 0],[0.25 0.5 0.25 0]), 0.25);
f=@() kl_divergence([0.25 0.25 0.5],[0 0.5 0.5]);
assertExceptionThrown(f, assert_id, 'Exception for q(1) 0 but p(1) not 0');
f=@() kl_divergence([0.25 0.25 0.5],[0 0.5]);
assertExceptionThrown(f, assert_id, 'Exception for q and p different lengths');
