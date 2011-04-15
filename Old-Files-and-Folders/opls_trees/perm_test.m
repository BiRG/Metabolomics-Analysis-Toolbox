function [P_all,P_all_idxs,perm_sorted_weights,perm_weights,correct_q2,q2_perm] = perm_test(X,Y,numPerm,fold);
% opls permutation test
%

perm_weights = [];
perm_sorted_weights = [];

%run opls with correct labels
[P,correct_q2] = new_opls_script_strat_min(X,Y,fold);
P = P/sqrt(sum(P.^2));
%save weights and indicies
[P_all, P_all_idxs] = sort(abs(P'),'descend');

%permutation
q2_perm = zeros(numPerm,1);
for i=1:numPerm
    %permute labels
    Y_rand_idx = randperm(length(Y));
    Y_rand = Y(Y_rand_idx);

    %run OPLS on permuted data
    [P,q2] = new_opls_script_strat_min(X,Y_rand,fold);
    P = P/sqrt(sum(P.^2));
    perm_weights = [perm_weights; P'];
    [temp_weights] = sort(abs(P'),'descend');                           % rank weights for this permutation
    perm_sorted_weights = [perm_sorted_weights; temp_weights];                            % save weights 
    q2_perm(i) = q2;
end;
