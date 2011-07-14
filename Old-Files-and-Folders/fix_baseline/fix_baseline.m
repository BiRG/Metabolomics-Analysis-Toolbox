function [y_fixed,y_baseline] = fix_baseline(x,y,regions,lambda)        
    xwidth = abs(x(1)-x(2));
    xmax = max(x);

    % Weights (0 = ignore this intensity)
    w = zeros(size(y));
    nm = size(regions);
    if nm(1) == 0
        error_no_regions_selected
    end
    for i = 1:nm(1)
        inx1 = max([1,round((xmax - regions(i,1))/xwidth) + 1,1]);
        inx2 = min([round((xmax - regions(i,2))/xwidth) + 1,length(w)]);
        w(inx1:inx2) = 1;
    end
    % Matrix version of W
    W = sparse(length(y),length(y));
    for i = 1:length(w)
        W(i,i) = w(i);
    end
    % Difference matrix (they call it derivative matrix, which a little
    % misleading)
    D = sparse(length(y),length(y));
    for i = 1:length(y)-1
        D(i,i) = 1;
        D(i,i+1) = -1;
    end

    A = W + lambda*D'*D;
    b = W*y;

    z = A\b; % Compute the baseline

    y_baseline = z;
    y_fixed = y - z;
    inxs = find(y == 0);
    y_fixed(inxs) = 0;
end