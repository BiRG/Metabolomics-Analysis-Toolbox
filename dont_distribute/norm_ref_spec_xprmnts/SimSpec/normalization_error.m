function [rmse, rmse_log] = normalization_error( d1, d2 )
% Calculates the error between two sets of dilution coefficients using two different error metrics
%
% d1 and d2 are the dilution constants calculated by two different methods.
% One of them is the true set of dilution factors. Sets of dilution factors
% are unique only up to a constant multiple. So normalization_error will 
% regress d2 as a linear function of d1 (with 0 intercept) then calculate 
% the rmse (root mean squared error) of the estimate. 
%
% Then because dilution error is really better measured on a log/log scale, 
% the code next regresses log(d2) as constant+log(d1) and calculates the  
% rmse of that estimate as rmse_log
% 
% -------------------------------------------------------------------------
% Input arguments
% -------------------------------------------------------------------------
% 
% d1 - row vector of scalars. Each dilution factor must be greater than 0. 
%      Same size as d2
%
% d2 - row vector of scalars. Each dilution factor must be greater than 0. 
%      Same size as d1
%
% -------------------------------------------------------------------------
% Output parameters
% -------------------------------------------------------------------------
% 
% rmse     - the minimum rmse between d1 and d2 when adjusting for the
%            constant of proportionality. See the description for more
%            details.
%
% rmse_log - the minimum rmse between log(d1) and log(d2) when adjusting
%            for the (now additive) constant of proportionality. See the
%            description for more details.
%
% -------------------------------------------------------------------------
% Examples
% -------------------------------------------------------------------------
%
% >> [a,b]=normalization_error([1,2,3,4,5],[10,20,30,40,50])
%
% a == 0
% 
% b == 8.8818e-16
%
% >> [a,b]=normalization_error([1,2,3,4,5],[11,29,31,49,51])
%
% a == 9.6352 % TODO: This output needs to be fixed
% 
% b == 0.2923 % TODO: This output needs to be fixed
% 
% -------------------------------------------------------------------------
% Authors
% -------------------------------------------------------------------------
%
% Eric Moyer (July-August 2012) eric_moyer@yahoo.com
%
assert(size(d1,1) == 1 && size(d2,1) == 1,'normalization_error:row_vec', ...
    'The values passed to normalization_erro must be row vectors');

assert(size(d1,2) == size(d2,2), 'normalization_error:same_size', ...
    ['The two vectors passed to normalization_error must have the' ...
    'same size.']);
   
% Make a variable for the number of spectra
num_spec = size(d1,2);

% Calculate minimum squared error coefficient for regression between d1 and
% d2. (a' x = b'    =>   a a' x = a b'    =>    x = a b' / a a' )
coef = (d1*d1') \ (d1*d2');

% Use the coefficient to calculate the error
est = d1' * coef;
rmse = sqrt(sum((est-d2').^2)/num_spec); 

% Calculate the minimum squared error coefficient for regression between
% log(d1) and log(d2):
%
% log(d1 x) = log d2   =>  log(d1) + log x = log(d2)  => log x = log(d2) - log(d1)
pf=polyfit(log(d1),log(d2)-log(d1),0);
est=log(d1)+polyval(pf, log(d1));
rmse_log = sqrt(sum((est-log(d2)).^2)/num_spec); 

end

