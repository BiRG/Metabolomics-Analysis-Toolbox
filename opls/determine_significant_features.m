function [sig_inxs,not_sig_inxs,significant,p_permuted] = determine_significant_features(X,Y,orig_model,num_permutations,talpha,variables)
[num_samples,num_variables] = size(X);
if ~exist('variables')
    variables = 1:num_variables;
end
%% Determine the significant features for a model
P_original = orig_model.p; % Grab the original P
% for each variable, permute the labels N times and recalculate P
fprintf('Maximum number of permutations is %d\n',factorial(num_samples));
N = min([num_permutations,factorial(num_samples)]);
fprintf('The number of permutations is %d\n',N);
fprintf('The test alpha is %f\n',talpha);
P_permuted = NaN*ones(N,num_variables);
for v = variables
    v_P_permuted = NaN*ones(N,1);
    parfor n = 1:N
        X_permuted = X;
        inxs = randperm(num_samples);
        X_permuted(:,v) = X(inxs,v);
        [model,stats] = opls(X_permuted,Y,orig_model.num_OPLS_fact);
        v_P_permuted(n) = model.p(v);
        % Make sure the direction of the vector is the same
        model.p(v) = 0; % Remove from calculation
        P_test = P_original;
        P_test(v) = 0;
        err1 = sum((P_test - model.p).^2);
        err2 = sum((P_test - (-1*model.p)).^2);
        if err2 < err1
            v_P_permuted(n) = -1 * v_P_permuted(n);
        end
    end
    P_permuted(:,v) = v_P_permuted;
    %fprintf('Finished %d\n',v);
end
P_permuted = P_permuted';

% Determine the significant bins
significant = ones(1,num_variables)*false;
sig_inxs = [];
not_sig_inxs = [];
for v = 1:num_variables
    sorted = sort(P_permuted(v,:),'descend');
    ix = max([1,round(N*talpha/2)]); % Two tailed
    thres1 = sorted(ix);
    thres2 = sorted(end-ix+1);
    if P_original(v) >= thres1
        significant(v) = true;
        sig_inxs(end+1) = v;
    elseif P_original(v) <= thres2
        significant(v) = true;
        sig_inxs(end+1) = v;
    else
        not_sig_inxs(end+1) = v;
    end
end

p_permuted = P_permuted;

% % Graph each significant distribution
% for v = 1:num_variables
%     if significant(v)
%         figure;
%         [f,xi] = ksdensity(P_permuted(v,:));
%         plot(xi,f,'k-');
%         yl = ylim;
%         arrow([P_original(v),yl(2)/4],[P_original(v),0]);
%         xlabel(['P_{',num2str(v),'}']);
%     end
% end
% 
% % Graph the distributions that are not significant
% for v = 1:num_variables
%     if ~significant(v)
%         figure;
%         [f,xi] = ksdensity(P_permuted(v,:));
%         plot(xi,f,'k-');
%         yl = ylim;
%         arrow([P_original(v),yl(2)/4],[P_original(v),0]);
%         xlabel(['P_{',num2str(v),'}']);
%     end
% end