function match_ids = match_peaks_R2(answer_maxs,calc_maxs,width,xwidth,G,sigma)
x = -width/2:xwidth:width/2;

match_ids = {};
for c = 1:length(calc_maxs)
    cxmax = calc_maxs(c);
    left = cxmax + width/2;
    right = cxmax - width/2;
    cinxs = find(left >= calc_maxs & calc_maxs >= right);
    cBETA = zeros(length(cinxs)*4,1);
    cBETA(1:4:end) = weight(cxmax - calc_maxs(cinxs),sigma);
    cBETA(2:4:end) = G;
    cBETA(3:4:end) = 1.0; % All Lorentzian
    cBETA(4:4:end) = cxmax - calc_maxs(cinxs);
    cy = global_model(cBETA,x,length(cBETA)/4);
    
    % Match to these peaks
    ainxs = find(left >= answer_maxs & answer_maxs >= right);
    if ~isempty(ainxs)
        R2s = zeros(1,length(ainxs));
        for i = 1:length(ainxs)
            a = ainxs(i);        
            axmax = answer_maxs(a);
            left = axmax + width/2;
            right = axmax - width/2;
            match_ainxs = find(left >= answer_maxs & answer_maxs >= right);
            aBETA = zeros(length(match_ainxs)*4,1);
            aBETA(1:4:end) = weight(axmax - answer_maxs(match_ainxs),sigma);
            aBETA(2:4:end) = G;
            aBETA(3:4:end) = 1.0; % All Lorentzian
            aBETA(4:4:end) = axmax - answer_maxs(match_ainxs);
            ay = global_model(aBETA,x,length(aBETA)/4);

            R2s(i) = 1 - sum((ay - cy).^2)/sum((mean(ay) - ay).^2);
            %figure; plot(x,cy,x,ay);
        end
        [v,ix] = max(R2s);
        match_ids{end+1} = [ainxs(ix),c];
    else
        match_ids{end+1} = [0,c];
    end
end

function w = weight(x,sigma)
w = exp(-x.^2/(2*sigma^2));