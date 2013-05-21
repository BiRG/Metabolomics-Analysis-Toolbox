function samples = GLBIO2013_sample_from_kl_divergence_of_dirichlet_belief( probs, dirichlet_belief, num_samples )
% Transforms samples from dirichlet_belief into their divergences from true_probs
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

dirichlet_samples = arrayfun(@(x) dirichlet_sample(dirichlet_belief), zeros(num_samples, 1), ...
    'UniformOutput',false);

samples = cellfun(@(s) kl_divergence(probs, s), dirichlet_samples);

end

