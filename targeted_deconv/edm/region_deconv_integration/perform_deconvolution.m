function [BETA,EXITFLAG] = perform_deconvolution(x,y,BETA0,lb,ub,x_baseline_BETA)
model = @(PARAMS,x_) (global_model(PARAMS,x_,(length(BETA0)-length(x_baseline_BETA))/4,x_baseline_BETA));

options = optimset('lsqcurvefit');
%options = optimset(options,'MaxIter',10);
options = optimset(options,'Display','off');
%options = optimset(options,'MaxFunEvals',100);
[BETA,R,RESIDUAL,EXITFLAG] = lsqcurvefit(model,BETA0,x,y,lb,ub,options);

if EXITFLAG < 0
    BETA = BETA0;
    fprintf('EXITFLAG: %d',EXITFLAG);
end

% y_fit = global_model(BETA,x,y);

