function [BETA,EXITFLAG] = perform_deconvolution(x,y,BETA0,lb,ub,x_baseline_BETA, model, progress_func)
%Helper function doing the curve fitting for region_deconvolution.
%
% Returns the best fit model starting at BETA0 given x_baseline_BETA, the
% x and y coordinates to fit, and the bounds on the parameters.
%
% Note: if upper bound is lower than lower bound, they are swapped
%
% As with region_deconvolution, these documentation comments are being
% put-in after the fact.
%
% -------------------------------------------------------------------------
% Input arguments
% -------------------------------------------------------------------------
%
% x                      The x values for the input spectrum (frequently 
%                        ppm)
%
% y                      The y values for the input spectrum
%
% BETA0                  A 1 dimensional array of doubles.
%
%                        Every 4 items are the starting parameters for one
%                        peak in the order M, G, P, x0.
%
%                        M  is the height parameter
%                        G  is the width parameter,
%                        P  is the proportion of Lorenzianness 
%                           (1=lorenzian, 0=gaussian)
%                        x0 is the location parameter, the location of 
%                           the peak.
%
% lb                     The lower bound on the corresponding entry in
%                        BETA0
%
% ub                     The upper bound on the corresponding entry in BETA0
%
% x_baseline_width       Not sure about this, probably the interval
%                        between the points that can be adjusted on the
%                        baseline.  Same as the parameter to
%                        region_deconvolution.
%
% model                  RegionalSpectrumModel giving the assumptions
%                        governing this deconvolution
%
% progress_func          (optional) Called every iteration of the
%                        optimization engine with a single parameter.
%                        progress_func(frac) where frac is the estimated
%                        fraction of completion.
%
% -------------------------------------------------------------------------
% Output parameters
% -------------------------------------------------------------------------
%
% BETA      The parameters of the peaks (see BETA0).  Will have the same
%           dimensions as BETA0
%
% EXITFLAG  The same as the exit flag from LSQNONLIN.  Quoting from 
%           there:
%
%                    
%
%           An integer identifying the reason the algorithm terminated. 
%           The following lists the values of exitflag and the 
%           corresponding reasons the algorithm terminated: 
%
%           1  Function converged to a solution x. 
%
%           2  Change in x was less than the specified tolerance.  
%
%           3  Change in the residual was less than the specified tolerance.
%
%           4  Magnitude of search direction smaller than the specified 
%              tolerance. 
%
%           0  Number of iterations exceeded options.  MaxIter or number 
%              of function evaluations exceeded options.FunEvals. 
%
%           -1 Output function terminated the algorithm. 
%
%           -2 Problem is infeasible: the bounds lb and ub are 
%              inconsistent.  
%
%           -3 Regularization parameter became too large 
%              (levenberg-marquardt algorithm). 
%
%           -4 Line search could not sufficiently decrease the residual 
%              along the current search direction.

% Deal with optional arguments
if ~exist('progress_func', 'var')
    progress_func = @do_nothing;
end

% Set up optimization

model_func = @(PARAMS) (regularized_model(PARAMS,x,(length(BETA0)-length(x_baseline_BETA))/4,x_baseline_BETA, y, model));

options = optimset('lsqnonlin');
%options = optimset(options,'MaxIter',10);
options = optimset(options,'Display','off');
%options = optimset(options,'MaxFunEvals',100);

% Wire up progress function to be called appropriately within the
% optimization
maxiter = optimget(options, 'MaxIter');
function stop = output_function(~, optimValues, ~)
    progress_func(optimValues.iteration/maxiter);
    stop = false;
end
options = optimset(options,'OutputFcn', @output_function);
    

% Swap bounds if they are inconsistent with their labels
to_swap = ub < lb;
tmp = ub(to_swap);
ub(to_swap)=lb(to_swap);
lb(to_swap)=tmp;

% Do the fit

[BETA,R,RESIDUAL,EXITFLAG] = lsqnonlin(model_func,BETA0,lb,ub,options); %#ok<ASGLU>

if EXITFLAG < 0
    BETA = BETA0;
    fprintf(['lsqnonlin had problems doing curve fit to find best ' ...
        'deconvolution. Using initial estimate as final fit. lsqnonlin '...
        'exit flag was: %d'],EXITFLAG);
end

end