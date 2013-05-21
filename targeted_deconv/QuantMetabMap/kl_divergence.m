function divergence = kl_divergence(p,q)
% Return D(p||q) the Kullback-Leibler divergence from distribution p to q 
%
% The divergence uses base 2, so it is measured in bits.
%
% -------------------------------------------------------------------------
% Input parameters
% -------------------------------------------------------------------------
%
% p - (row vector of double) p(i) is the probability of event i in 
%      distribution p. sum(p) == 1
%
%      Must be the same length as q
%
% q - (row vector of double) q(i) is the probability of event i in 
%      distribution q. sum(q) == 1 Note: if q(i) == 0 then p(i) == 0
%
%      Must be the same length as p
%
% -------------------------------------------------------------------------
% Output parameters
% -------------------------------------------------------------------------
%
% divergence = D(p||q) the Kullback-Leibler divergence from distribution p 
%      to q 
% -------------------------------------------------------------------------
% Examples
% -------------------------------------------------------------------------
%
% >> d = kl_divergence([0.25 0.25 0.5],[0.25 0.25 0.5])
%
% d == 0
%
% >> d = kl_divergence([],[])
%
% d == 0
%
% >> d = kl_divergence([0.25 0.25 0.5],[0.25 0.5 0.25])
%
% d == 0.25
%
% >> d = kl_divergence([0.25 0.5 0.25 0],[0.25 0.25 0.25 0.25])
%
% d == 0.5
%
% >> d = kl_divergence([0 0.25 0.25 0.5],[0.25 0.25 0.5 0.25])
%
% d == 0.25
%
% >> d = kl_divergence([0.25 0.25 0.5 0],[0.25 0.5 0.25 0])
%
% d == 0.25
%
% >> d = kl_divergence([0.25 0.25 0.5],[0 0.5 0.5])
%
% Error q(1) is 0 but p(1) is not 0
% -------------------------------------------------------------------------
% Authors
% -------------------------------------------------------------------------
%
% Eric Moyer (eric_moyer@yahoo.com) May 2013

assert(all(p(q == 0) == 0));
assert(length(p) == length(q));

% Remove the events where p is 0 - 0log0 is 0 so these terms dont figure in
% the sum (this should also remove the events where q is 0). Doing these
% removals avoids spurious divide-by-zero and log(0) errors.
q = q(p ~= 0);
p = p(p ~= 0);

% Calculate the divergence
divergence = sum(log2(p./q).*p);