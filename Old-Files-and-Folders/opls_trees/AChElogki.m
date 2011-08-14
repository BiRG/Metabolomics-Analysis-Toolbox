addpath('../common_scripts');
load('AChElogki-999.mat');

% QSAR data analysis
DescriptorsAutoScaled = Descriptors;
DescriptorsAutoScaled = bsxfun(@minus, DescriptorsAutoScaled, mean(DescriptorsAutoScaled));
DescriptorsAutoScaled = bsxfun(@rdivide, DescriptorsAutoScaled, std(DescriptorsAutoScaled));
data = DescriptorsAutoScaled;
class_numbers = ExpLogki;
Y = class_numbers;

%% Defaults are recommended from PLS-Trees manuscript
A = 0.3; % A value of 1 is fully focused on Y, a value of 0 focues on X
B = 0.3; % A value of 0 splits off small clusters, a value of 1 ensures clusters are balanced
CV = [100,100,300]; % 100 times, cross validation set size between 100 and 300
permutations = 100;
talpha = 0.01;
min_num_samples_in_cluster = 40;

%% First run OPLS and the permutation test without clustering
[CV_array,accuracy,mean_class_numbers,W,b,C,R2_X,R2_Y,class_numbers0,P, ...
    means_data,T_ortho,stdev_class_numbers,data0,stdevs_data,T,U, ...
    num_opls_fact,press,q2,SE,P_ortho,Y_pred,Q2s] = opls_script_strat_splot(data,Y,CV);

% Plot the results
addpath('../matlab_scripts');

% Figure properties
set(0,'DefaultAxesFontName','arial');
set(0,'DefaultTextFontName','arial');
% set(0,'DefaultTextFontSize',8);
% set(0,'DefaultAxesFontSize',8);
set(0,'DefaultFigurePaperPositionMode', 'manual');
set(0,'DefaultFigurePaperUnits', 'inches');
set(0,'DefaultFigurePaperPosition', [2,1,6,6.5]);
set(0,'DefaultFigureUnits','inches');
defaultpos = get(0,'DefaultFigurePaperPosition');
figure('Position',defaultpos);
subplot1(2,2,'Gap',[0.1 0.08],'Min',[0.1 0.08],'Max',[0.99 1.03],'FontS',8,'XTickL','All','YTickL','All');

subplot1(1);
plot(Y,Y_pred,'ok');
hold on
fplot('x',[0,10],'Color','k');
hold off
xlabel('$Y$','Interpreter','Latex');
ylabel('\^{Y}','Interpreter','Latex');

subplot1(2);
diff = Y-Y_pred;
[vs,inxs] = sort(diff);
plot(diff(inxs),'ok');
xlabel('Sample','Interpreter','Latex');
ylabel('Residual','Interpreter','Latex');

%run perm test
CV = 10; % To save time
[P_all,P_all_idxs,perm_sorted_weights,perm_weights,correct_q2,perm_q2s] ...
    = perm_test(data,class_numbers,permutations,CV);

subplot1(3);
ksdensity(perm_q2s);
hold on
ksdensity(Q2s);
xl = xlim;
xlim([-0.1,1]);
h = arrow([q2,max(ylim)],[q2,min(ylim)],'LineWidth',1,'Width',0.2);
set(h,'EdgeColor','k');
hold off
xlabel('$Q^2$','Interpreter','Latex');
legend('Randomized distribution','Actual distribution');
R2 = 1 - sum((Y-Y_pred).^2)/sum((mean(Y)-Y).^2);
hold on
h = arrow([R2,max(ylim)],[R2,min(ylim)],'LineWidth',1,'Width',0.2);
set(h,'EdgeColor','r');
hold off

%loadings plot
subplot1(4);
[sorted_abs_P,inxs] = sort(abs(P),'descend');
plot(1:length(inxs),abs(P(inxs)),'k');
ylabel('$|P|$ (Loadings)','Interpreter','Latex');
xlabel('Descriptor','Interpreter','Latex');
% set(gca,'XTickLabel',{DescriptorNames{inxs}});
% view(-90,90) % swap the x and y axis

%% Now run OPLS-Trees
tree = {};
if is_sig_q2(q2,perm_q2s,talpha) && length(Y_pred) > min_num_samples_in_cluster
    tree = split_cluster(data,Y,1:length(Y),A,B,CV,min_num_samples_in_cluster);
end
save('tree','tree');

[maximizing_tree,max_q2] = build_maximizing_tree(tree);

%% Now plot the dendrogram
figure
hold on
width = 1;
xlim([-1,1.5]);
create_plot_from_tree(maximizing_tree,width,0);
ylabel('$Q^2$','Interpreter','Latex');
ylim([0.42,0.9]);
hold off