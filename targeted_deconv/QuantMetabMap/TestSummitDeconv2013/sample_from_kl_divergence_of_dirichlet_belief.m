function samples = sample_from_kl_divergence_of_dirichlet_belief( probs, dirichlet_belief, num_samples, zero_behavior )
% Transforms samples from dirichlet_belief into their divergences from true_probs
%
% Usage: samples = sample_from_kl_divergence_of_dirichlet_belief( probs, dirichlet_belief, num_samples, zero_behavior )
%
% Someone's uncertainties beliefs about the parameters of a categorical
% distribution are frequently modeled as a Dirichlet distribution. If there
% is a known set of probabilities for those same categories, samples from
% the uncertain beliefs distribution will have different Kullback-Leibler
% divergences from the known set of probabilities. These divergences will
% have a particular distribution fixed by the belief and the known
% probabilities.
%
% The distribution of the divergences is hard to calculate analytically, so
% this code samples from that distribution and returns a collection of
% num_samples independent samples.
%
% The samples are produced by sampling from the Dirichlet distribution 
% whose parameters are dirichlet_belief and then calculating the divergence
% of each sample from probs.
%
% -------------------------------------------------------------------------
% Input parameters
% -------------------------------------------------------------------------
%
% probs - (row vector) the probabilities of a categorical distribution.
%
%      The following constraints must hold:
%
%      probs >= 0
%      sum(probs) == 1 
%      length(probs) == length(dirichlet_belief)
%
% dirichlet_belief - (row vector) the parameters of the dirichlet
%      distribution being compared to probs. Must be valid inputs to
%      sample_dirichlet
%
% num_samples - (scalar) the number of samples to generate
%
% zero_behavior - (optional string) what to do when the sample from the
%      dirichlet are 0's. Can be:
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
% Eric Moyer (eric_moyer@yahoo.com) May 2013

if ~exist('zero_behavior','var')
    zero_behavior = 'nothing';
end

dirichlet_samples = arrayfun(@(x) dirichlet_sample(dirichlet_belief), zeros(num_samples, 1), ...
    'UniformOutput',false);

if strcmp(zero_behavior, 'nothing')
    % do nothing
elseif strcmp(zero_behavior, 'zero=epsilon')
    epsilon = nextAfter(0);
    for i = 1:length(dirichlet_samples)
        x = dirichlet_samples{i};
        x(x==0) = epsilon;
        dirichlet_samples{i} = x;
    end
else
   error('sample_from_kl_divergence:unknown_zero_behavior',...
       [zero_behavior ' is not a valid value for the zero_behavior ' ...
       ' variable.']);
end

samples = cellfun(@(s) kl_divergence(probs, s), dirichlet_samples);

end

