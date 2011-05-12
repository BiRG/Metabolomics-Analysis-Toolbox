function [press, num_OPLS_fact] = rem_opls_fact_strat(X,Y,CV_array,num_OPLS_fact)

press = 0;
%y_sum = 0;
Y = zscore(Y);
    
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
    Yres = Ytemp -m_Y;   
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
    
    %%%%%%
    % calc partial press
    %%%%%%
    X_leftOut = X(CV_array{CV_count},:);
    X_leftOut = bsxfun(@minus,X_leftOut, m);
    Y_leftOut = Y(CV_array{CV_count},:)-m_Y;
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
        press = press + (Y_pred - Y_leftOut(cpp))^2;
        %y_sum = y_sum + ((Y_leftOut(cpp)-m_Y)/s_Y)^2;
    end;

end
