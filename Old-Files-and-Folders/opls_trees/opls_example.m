% % Create example data set
% X1 = [10 + 2*randn(1,100);5 + 2*randn(1,100);15 + 5*randn(1,100)]';
% X2 = [15 + 2*randn(1,100);4 + 2*randn(1,100);30 + 5*randn(1,100)]';
% Y = [ones(100,1);ones(100,1)+1];
% 
% hold on
% plot3(Xres(1:100,1),Xres(1:100,2),Xres(1:100,3),'k*');
% hold on
% plot3(Xres(101:end,1),Xres(101:end,2),Xres(101:end,3),'r*');
% hold off
% hold on
% plot3([0,10*p(1)],[0,10*p(2)],[0,10*p(3)],'-c');
% hold off
% hold on
% plot3([0,10*p_ortho(1)],[0,10*p_ortho(2)],[0,10*p_ortho(3)],'-b');
% hold off

%% First run OPLS and the permutation test without clustering
[CV_array,accuracy,mean_class_numbers,W,b,C,R2_X,R2_Y,class_numbers0,P, ...
    means_data,T_ortho,stdev_class_numbers,data0,stdevs_data,T,U, ...
    num_opls_fact,press,q2,SE,P_ortho,Y_pred,Q2s] = opls_script_strat_splot([X1;X2],Y,10);

