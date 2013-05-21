function test_suite = test_dirichlet_sample%#ok<STOUT>
%matlab_xUnit tests excercising dirichlet_sample
%
% Usage:
%   runtests test_dirichlet_sample
initTestSuite;

function testExamples %#ok<DEFNU>
% Test the examples from the documentation
old_rng = RandStream.getGlobalStream();
RandStream.setGlobalStream(RandStream('mt19937ar','Seed',3676226565));
first = @(x) x(1);

% Check that you can't rule out the dirichlet uniform being uniform
uniform_sample = arrayfun(@(x) first(dirichlet_sample([1,1])), zeros(1000,1));
known_uniform = rand(size(uniform_sample));
assertFalse(kstest2(uniform_sample, known_uniform, 0.05, 'unequal'));

% Check that you can't rule out the dirichlet beta being beta
beta_sample = arrayfun(@(x) first(dirichlet_sample([0.5,0.5])), zeros(1000,1));
known_beta = betarnd(0.5, 0.5, size(beta_sample));
assertFalse(kstest2(beta_sample, known_beta, 0.05, 'unequal'));

beta_sample = arrayfun(@(x) first(dirichlet_sample([5,10])), zeros(1000,1));
known_beta = betarnd(5, 10, size(beta_sample));
assertFalse(kstest2(beta_sample, known_beta, 0.05, 'unequal'));

beta_sample = arrayfun(@(x) first(dirichlet_sample([10,5])), zeros(1000,1));
known_beta = betarnd(10, 5, size(beta_sample));
assertFalse(kstest2(beta_sample, known_beta, 0.05, 'unequal'));

RandStream.setGlobalStream(old_rng);

