function tree = split_cluster(data,Y,orig_inxs,A,B,CV,min_num_samples_in_cluster)
%first run OPLS
[CV_array,accuracy,mean_class_numbers,W,b,C,R2_X,R2_Y,class_numbers0,P, ...
    means_data,T_ortho,stdev_class_numbers,data0,stdevs_data,T,U, ...
    num_opls_fact,press,q2,SE,P_ortho,Y_pred] = opls_script_strat_splot(data,Y,CV);
    
% Now try to split clusters
tree = {};
tree.Y_pred = Y_pred;
tree.Y = Y;
tree.q2 = q2;
tree.P = P;
[sorted_Y_pred,sorted_Y_pred_inxs] = sort(Y_pred);
tree.orig_inxs = orig_inxs;
tree.inxs = sorted_Y_pred_inxs;
min_score = Inf;
min_inx = 0;
for s = 1:length(Y_pred)
    G1_inxs = sorted_Y_pred_inxs(1:s);
    G2_inxs = sorted_Y_pred_inxs(s+1:end);
    N1 = length(G1_inxs);
    N2 = length(G2_inxs);
    Vy1 = std(Y(G1_inxs));
    Vy2 = std(Y(G2_inxs));
    Vy = std([Y(G1_inxs);Y(G2_inxs)]);
    Vt1 = std(Y_pred(G1_inxs));
    Vt2 = std(Y_pred(G2_inxs));
    Vt = std([Y_pred(G1_inxs);Y_pred(G2_inxs)]);
    score = B*(N1-N2)^2/(N1+N2)^2+(1-B)*(A*(Vy1+Vy2)/Vy+(1-A)*(Vt1+Vt2)/Vt);
    if score < min_score
        min_inx = s;
        min_score = score;
    end
end
tree.min_inx = min_inx;
tree.min_score = min_score;
fprintf('Found split: %d\n',min_inx);
%test group 1
data1 = data(1:min_inx,:);
Y1 = Y(1:min_inx);
inxs1 = sorted_Y_pred_inxs(1:min_inx);
tree.left = {};
if length(inxs1) > min_num_samples_in_cluster
    tree.left = split_cluster(data1,Y1,orig_inxs(inxs1),A,B,CV,min_num_samples_in_cluster);
end
%test group 1
data2 = data(min_inx+1:end,:);
Y2 = Y(min_inx+1:end);
inxs2 = sorted_Y_pred_inxs(min_inx+1:end);
tree.right = {};
if length(inxs2) > min_num_samples_in_cluster
    tree.right = split_cluster(data2,Y2,orig_inxs(inxs2),A,B,CV,min_num_samples_in_cluster);
end