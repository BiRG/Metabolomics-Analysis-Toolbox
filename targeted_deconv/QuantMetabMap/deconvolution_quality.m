function [ quality ] = deconvolution_quality( residual )
% Estimate deconvolution quality from its residual
% 
% Returns a quality score from 0..100 with higher numbers being better.
% 
% Right now, that quality is based on the correlation between successive 
% points in the residual - a perfect deconvolution would leave only 
% uncorrelated noise. 
%
% Formula: 100*(1-abs(correlation))
%
%
%
% An aside about the Durbin-Wilson statistic for autocorrelation
%
% I may want to change to using the Durbin-Wilson statistic - which was
% created specifically to detect autocorrelation and always lies between 
% 0 and 4. This would have the advantages of allowing someone to understand
% exactly what the quality score is measuring and of allowing easy
% computation of which pairs have the most influence on the final score
% (since the statistic doesn't involve the mean, standard deviation, or any
% other global statistics in the calculation of the individual error
% contributions.
%
% Unfortunately, the DW statistic can be quite small for non-normal but
% independent numbers: when I did: r=randi(1000,1,10000) I got a DW
% statistic of 0.5130 (which is quite small and indicates strong evidence
% for correlation). But when I used normally distributed random numbers, 
% r=randn(1,10000) I got: 2.025. Maybe it still would be useful as a
% quality score, but it would take more testing.
% 
% -------------------------------------------------------------------------
% Input parameters
% -------------------------------------------------------------------------
%
% residual - (vector of scalar) Must have at least 4 elements.
%
% -------------------------------------------------------------------------
% Output parameters
% -------------------------------------------------------------------------
%
% quality - (scalar) The quality score assigned to the given residual. Will
%     range from 0..100 inclusive
%
% -------------------------------------------------------------------------
% Examples
% -------------------------------------------------------------------------
%
% >> d = deconvolution_quality([ 1 100 2 99 3 98 ])
% 
% d == 0
%
% >> d = deconvolution_quality([3     3     1     8     8     9    10])
% 
% d == 37.9903
%
% >> d = deconvolution_quality([3     3     1     8  ]) % Smallest possible residual to which a quality can be assigned.
% 
% d == 3.9231
%
% >> d = deconvolution_quality([[577; 864; 366; 152; 385; 149; 748; 401; 593; 701]]) 
% 
% d == 99.9993
%
% -------------------------------------------------------------------------
% Authors
% -------------------------------------------------------------------------
%
% Eric Moyer (eric_moyer@yahoo.com) July 2013

assert(length(residual) >= 4);
assert(isvector(residual));

if isrow(residual)
    quality = corr(residual(1:end-1)',residual(2:end)');
else
    quality = corr(residual(1:end-1),residual(2:end));
end

quality = 100*(1-abs(quality));

end

