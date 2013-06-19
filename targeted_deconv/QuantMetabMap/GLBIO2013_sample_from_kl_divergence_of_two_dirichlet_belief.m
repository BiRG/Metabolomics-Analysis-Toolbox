function samples = GLBIO2013_sample_from_kl_divergence_of_two_dirichlet_belief( dirichlet_1, dirichlet_2, num_samples, zero_behavior )
% Transforms pairs of samples from dirichlet_belief_* into their divergences from one another
%
% Someone's uncertainties beliefs about the parameters of a categorical
% distribution are frequently modeled as a Dirichlet distribution. We can
% derive our beliefs about the KL divergences of two categorical
% distributions by sampling from our beliefs of each one and taking the KL
% divergence of the two samples.
%
% -------------------------------------------------------------------------
% Input parameters
% -------------------------------------------------------------------------
%
% dirichlet_1 - (row vector) the parameters of the first dirichlet distribution.
%      Must be valid inputs to sample_dirichlet
%
% dirichlet_2 - (row vector) the parameters of the second dirichlet
%      distribution. Must be valid inputs to sample_dirichlet
%
% num_samples - (scalar) the number of samples to generate
%
% zero_behavior - (optional string) what to do when the sample from
%      dirichlet_belief_2 are 0's. Can be:
%
%      'nothing' - (the default) allow zeros in the sampled distributions
%           to pass unchanged into the KL calculation and hope that the
%           corresponding probs are non-zero
%
%      'zero=epsilon' - replaces zero probabilities with epsilon (
%           the result of nextAfter(0) ) before calculating the k-l
%           divergence
%
% -------------------------------------------------------------------------
% Output parameters
% -------------------------------------------------------------------------
%
% samples - (column vector) the samples from the KL-divergence transformed
%     Dirichlet
% -------------------------------------------------------------------------
% Examples
% -------------------------------------------------------------------------
%
% -------------------------------------------------------------------------
% Authors
% -------------------------------------------------------------------------
%
% Eric Moyer (eric_moyer@yahoo.com) June 2013

if ~exist('zero_behavior','var')
    zero_behavior = 'nothing';
end

dirichlet_samples_1 = arrayfun(@(x) dirichlet_sample(dirichlet_1), zeros(num_samples, 1), ...
    'UniformOutput',false);
dirichlet_samples_2 = arrayfun(@(x) dirichlet_sample(dirichlet_2), zeros(num_samples, 1), ...
    'UniformOutput',false);

if strcmp(zero_behavior, 'nothing')
    % do nothing
elseif strcmp(zero_behavior, 'zero=epsilon')
    epsilon = nextAfter(0);
    for i = 1:length(dirichlet_samples_2)
        x = dirichlet_samples_2{i};
        x(x==0) = epsilon;
        dirichlet_samples_2{i} = x;
    end
else
   error('sample_from_kl_divergence:unknown_zero_behavior',...
       [zero_behavior ' is not a valid value for the zero_behavior ' ...
       ' variable.']);
end

samples = cellfun(@(a,b) kl_divergence(a, b), dirichlet_samples_1, ...
    dirichlet_samples_2);

end

