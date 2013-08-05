function y = nextAfter(x,d)
% NEXTAFTER Increment last bit of a floating point number.
% NEXTAFTER(X) adds one unit to the last place of X.
% NEXTAFTER(X,D) for positive D does the same thing.
% NEXTAFTER(X,D) for negative D subtracts one unit ("Next Before")
% Examples:
% nextafter(1) is 1 + eps
% nextafter(1,-1) is 1 - eps/2
% nextafter(0) is the smallest floating point number.
%
% This code was taken from http://www.mathworks.com/matlabcentral/newsreader/view_thread/192
%
% The author was given as: moler@mathworks.com (Cleve Moler)
   
   [f,e] = log2(abs(x));
   u = pow2(2,e-54);
   if x == 0, u = eps*realmin; end
   if nargin < 2, d = 1; end
   if d < 0, u = -u; end
   if f == 1/2 & sign(x) ~= sign(d), u = u/2; end
   y = x + u; 