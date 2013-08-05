function p = dirichlet_sample(alphas)
% Returns a sample from a Dirichlet distribution with parameters alphas
%
% I used the method in http://docs.scipy.org/doc/numpy/reference/generated/numpy.random.dirichlet.html
% This references Wikipedia ( http://en.wikipedia.org/wiki/Dirichlet_distribution#Gamma_distribution ) 
% but there may be a cross-dependence.
% 
% Wikipedia's python code is:
%
% params = [a1, a2, ..., ak]
% sample = [random.gammavariate(a,1) for a in params]
% sample = [v/sum(sample) for v in sample]
%
% -------------------------------------------------------------------------
% Input arguments
% -------------------------------------------------------------------------
% 
% alphas - (a row vector) The parameters of the Dirichlet distribution. All 
%      alphas must be greater than 0
%
% -------------------------------------------------------------------------
% Output parameters
% -------------------------------------------------------------------------
% 
% p - a single sample drawn from Dir(alphas(1), alphas(2), ...)
%
% -------------------------------------------------------------------------
% Examples
% -------------------------------------------------------------------------
%
% >> p = dirichlet_sample([1,1])
%
% p(1) will be uniformly distributed
%
% >> p = dirichlet_sample([0.5,0.5])
%
% p(1) will be distributed as Beta(1/2,1/2)
%
% -------------------------------------------------------------------------
% Authors
% -------------------------------------------------------------------------
%
% Eric Moyer 2013 (eric_moyer@yahoo.com)
y = gamrnd(alphas,ones(size(alphas)));
p = y/sum(y);
end