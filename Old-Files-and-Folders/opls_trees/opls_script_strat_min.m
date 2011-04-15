function [P,Q2] = opls_script_strat_min(X,Y,fold)

 X_ori=X;
 Y_ori=Y;

M_X=mean(X);
M_Y=mean(Y);
S_X=std(X);
S_Y=std(Y);

%%%%%
% start of cross validation
%%%%%
if fold == -1
   fold = length(Y); 
end
% numPerFold(1:fold) = floor(length(Y) / fold);
% fold_idx=1;
% while sum(numPerFold(:)) ~= length(Y)
%    numPerFold(fold_idx) =  numPerFold(fold_idx) + 1;
%    fold_idx = fold_idx + 1;
% end         
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


[prev_press, prev_num_OPLS_fact] = rem_opls_fact_strat(X_ori,Y_ori,fold_array,0);
[press, num_OPLS_fact] = rem_opls_fact_strat(X_ori,Y_ori,fold_array,1);
R = press/prev_press;

while ((R < 1) && (num_OPLS_fact < length(X(1,:))))
    prev_press = press;
    prev_num_OPLS_fact = num_OPLS_fact;
    [press, num_OPLS_fact] = rem_opls_fact_strat(X,Y,fold_array,prev_num_OPLS_fact+1);
    R = press/prev_press;        
end

  
[fold,accuracy,W,B_pls,C,R2_X,R2_Y,Y,P,T_ortho,X,T,U,nOPLSfact,press,Q2,P_ortho] = rem_opls_fact_all_strat(X_ori,Y_ori,fold_array,prev_num_OPLS_fact);


    

