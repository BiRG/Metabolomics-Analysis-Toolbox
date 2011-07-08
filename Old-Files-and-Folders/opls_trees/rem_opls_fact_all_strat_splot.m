function[CV_array,accuracy,W,B_pls,C,R2_X,R2_Y,Y,P,T_ortho,X,T,U,num_OPLS_fact,press,Q2,SE,P_ortho,Y_pred,Q2s] = rem_opls_fact_all_strat_splot(X,Y,CV_array,num_OPLS_fact)

press = 0;
y_sum = 0;
errors = 0;
Q2s = [];
    
for CV_count=1:length(CV_array)
    %%%%
    % set up CV data
    %%%%        
    mask = ones(size(Y)); % Start with all
    mask(CV_array{CV_count}) = 0;
    inxs = find(mask == 1);
    Xtemp = X(inxs,:);
    Ytemp = Y(inxs,:);
    %zscore this CV data set
    m=mean(Xtemp);
    m_Y=mean(Ytemp);
    Xres = bsxfun(@minus,Xtemp, m);
    Yres = Ytemp - m_Y;
    s=std(Xtemp);
    m_Y=mean(Ytemp);
    s_Y=std(Ytemp);
    
    %%%%%%%%%%%%
    % OPLS 
    %%%%%%%%%%%%
    w_ortho = [];
    t_ortho = [];
    p_ortho = [];
    for iter=1:num_OPLS_fact
        %find PLS component
        w = (Yres'*Xres / (Yres'*Yres))';
        w = w / norm(w);
        t = Xres*w / (w'*w);
        p = (t'*Xres / (t'*t))';

        %run OSC filter on Xres
        w_ortho(:,iter) = p - (w'*p / (w'*w)) * w;
        w_ortho(:,iter) = w_ortho(:,iter) / norm(w_ortho(:,iter));
        t_ortho(:,iter) = Xres*w_ortho(:,iter) / (w_ortho(:,iter)'*w_ortho(:,iter));
        p_ortho(:,iter) = (t_ortho(:,iter)'*Xres / (t_ortho(:,iter)'*t_ortho(:,iter)))';
        Xres = Xres - t_ortho(:,iter)*p_ortho(:,iter)';
    end;
    
    %%%%%%%%%%
    % PLS 
    %%%%%%%%%%
    %find PLS component
    w = (Yres'*Xres / (Yres'*Yres))';
    w = w / norm(w);
    t = Xres*w / (w'*w);
    c = (t'*Yres / (t'*t))';
    u = Yres*c / (c'*c);
    p = (t'*Xres / (t'*t))';
    % b coef
    b_l=((t'*t)^(-1))*(u'*t);
    
    SE(CV_count,:) = p;
    
    %%%%%%
    % calc partial press
    %%%%%%
    X_leftOut = X(CV_array{CV_count},:);
    X_leftOut = bsxfun(@minus,X_leftOut, m);
    Y_leftOut = Y(CV_array{CV_count},:)-m_Y;
    temp_press = 0;
    temp_y_sum = 0;
    for cpp = 1:length(Y_leftOut)
        Wstar=w*inv(p'*w);
        B_pls=Wstar*diag(b_l)*c';
        z=(X_leftOut(cpp,:));
        % filter out OPLS components
        for filter=1:num_OPLS_fact
            z = (z - (z*w_ortho(:,filter)/(w_ortho(:,filter)'*w_ortho(:,filter)))*p_ortho(:,filter)');
        end
        %predict
        Y_pred = z*B_pls;
        temp_press = temp_press + (Y_pred - Y_leftOut(cpp))^2;
        temp_y_sum = temp_y_sum + (Y_leftOut(cpp))^2;
        correct_Y = Y_pred - (Y_leftOut(cpp));
        for k=1:length(Y)
            if (abs(Y_pred - (Y(k))) < abs(correct_Y))
                errors = errors+1;
                break;
            end;
        end;
    end;
    Q2s(end+1) = 1 - temp_press/temp_y_sum;
    press = press + temp_press;
    y_sum = y_sum + temp_y_sum;
end

%%%%%%%%%%%%
% OPLS on full data
%%%%%%%%%%%%
w_ortho = [];
t_ortho = [];
p_ortho = [];

Xres = bsxfun(@minus,X, mean(X));
Yres = (Y)-mean(Y);
SS_Y=sum(sum(Yres.^2));
SS_X=sum(sum(Xres.^2));

for iter=1:num_OPLS_fact
    %find PLS component
    w = (Yres'*Xres / (Yres'*Yres))';
    w = w / norm(w);
    t = Xres*w / (w'*w);
    p = (t'*Xres / (t'*t))';

    %run OSC filter on Xres
    w_ortho(:,iter) = p - (w'*p / (w'*w)) * w;
    w_ortho(:,iter) = w_ortho(:,iter) / norm(w_ortho(:,iter));
    t_ortho(:,iter) = Xres*w_ortho(:,iter) / (w_ortho(:,iter)'*w_ortho(:,iter));
    p_ortho(:,iter) = (t_ortho(:,iter)'*Xres / (t_ortho(:,iter)'*t_ortho(:,iter)))';
    Xres = Xres - t_ortho(:,iter)*p_ortho(:,iter)';
end;

%%%%%%%%%%
% PLS on full data
%%%%%%%%%%
%find PLS component
w = (Yres'*Xres / (Yres'*Yres))';
w = w / norm(w);
t = Xres*w / (w'*w);
c = (t'*Yres / (t'*t))';
u = Yres*c / (c'*c);
p = (t'*Xres / (t'*t))';
% b coef
b_l=((t'*t)^(-1))*(u'*t);

%save model params
b=b_l;
C=c;
P=p;
W=w;
T=t;
U = u;
T_ortho = t_ortho;
P_ortho = p_ortho;
% Original space
Wstar=w*inv(p'*w);
B_pls=Wstar*diag(b_l)*c';
m=mean(X);
Xres = bsxfun(@minus,X, m);
z=Xres;
% filter out OPLS components
for filter=1:num_OPLS_fact
  z = (z - (z*w_ortho(:,filter)/(w_ortho(:,filter)'*w_ortho(:,filter)))*p_ortho(:,filter)');
end
%predict
Y_pred = z*B_pls + mean(Y);

R2_X=(T'*T)*(P'*P)./SS_X;
R2_Y=(T'*T)*(b.^2)*(C'*C)./SS_Y;
Q2 = 1 - press/y_sum;
accuracy = (length(Y)-errors) / length(Y);



