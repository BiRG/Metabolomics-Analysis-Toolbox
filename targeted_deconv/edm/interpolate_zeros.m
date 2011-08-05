function y_without_zeros = interpolate_zeros(x,y)
% Construct a special y where the zero regions are interpolated.  
%
% Used for calculating the baseline function in region_deconvolution.
%
% Minor bugs:
%
% If the first value is zero then it will be left unchanged.  If the last 
% values are a string of zeros, they will be left as is.
%
% -------------------------------------------------------------------------
% Input arguments
% -------------------------------------------------------------------------
%
% x   The x values for the input spectrum (frequently ppm)
%
% y   The y values for the input spectrum
%
% -------------------------------------------------------------------------
% Output parameters
% -------------------------------------------------------------------------
%
% y_without_zeros  Identical to y except that all regions with zeros have
%                  been replaced by a line drawn between the non-zeros at
%                  the end-points.


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
