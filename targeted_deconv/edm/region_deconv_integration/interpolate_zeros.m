function y_without_zeros = interpolate_zeros(x,y)
% Construct a special y for the baseline function, where the zero regions
% are interpolated
xs = [];
ys = [];
xi = [];
inxs = [];
y_without_zeros = y;
for i = 2:length(y) % assume first is not zero
    if y(i) == 0
        xi(end+1) = x(i);
        inxs(end+1) = i;
        if isempty(xs)
            xs(end+1) = x(i-1);
            ys(end+1) = y(i-1);
        end
    elseif ~isempty(xi)
        xs(end+1) = x(i);
        ys(end+1) = y(i);
        y_without_zeros(inxs) = interp1(xs,ys,xi,'linear');
        xi = [];
        inxs = [];
        ys = [];
        xs = [];
    end
end
