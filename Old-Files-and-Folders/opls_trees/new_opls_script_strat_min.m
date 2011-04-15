function [P,Q2] = new_opls_script_strat_min(X,Y,CV);

 X_ori=X;
 Y_ori=Y;

M_X=mean(X);
M_Y=mean(Y);
S_X=std(X);
S_Y=std(Y);

%%%%%
% start of cross validation
%%%%%
CV_array = {};
if length(CV) > 1 % Random bootstrap with replacement
    num_times = CV(1);
    min_num_samples = CV(2);
    max_num_samples = CV(3);
    num_samples_in_each_test_set = round(min_num_samples + (max_num_samples-min_num_samples).*rand(num_times,1));
    for i = 1:length(num_samples_in_each_test_set)
        num_samples_in_test_set = num_samples_in_each_test_set(i);
        CV_array{i} = round(1 + (length(Y)-1).*rand(num_samples_in_test_set,1));
    end
else
    fold = CV;
    if fold == -1
       fold = length(Y); 
    end
    
    j=1;
    while(1)
        for i=1:fold
            fold_array(j) = i;
            j=j+1;
            if j > length(Y)
                break;
            end
        end
        if j > length(Y)
            break;
        end
    end
    CV_array = {};
    for i = 1:fold
        CV_array{i} = find(fold_array == i);
    end
end


[prev_press, prev_num_OPLS_fact] = rem_opls_fact_strat(X_ori,Y_ori,CV_array,0);
[press, num_OPLS_fact] = rem_opls_fact_strat(X_ori,Y_ori,CV_array,1);
R = press/prev_press;

while ((R < 1) && (num_OPLS_fact < length(X(1,:))))
    prev_press = press;
    prev_num_OPLS_fact = num_OPLS_fact;
    [press, num_OPLS_fact] = rem_opls_fact_strat(X,Y,CV_array,prev_num_OPLS_fact+1);
    R = press/prev_press;        
end

  
[CV_array,accuracy,W,B_pls,C,R2_X,R2_Y,Y,P,T_ortho,X,T,U,nOPLSfact,press,Q2,P_ortho] = rem_opls_fact_all_strat(X_ori,Y_ori,CV_array,prev_num_OPLS_fact);


    

