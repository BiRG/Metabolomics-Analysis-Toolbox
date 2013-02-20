function height=calc_height(inxs,I)
% Return the estimated height of a peak over the region specified by inxs in the intensity vector I
%
% Returns the difference between the maximum I value and the minimum I 
% value over the indices specified by inxs.
%
% These documentation comments are being put-in after the fact for code
% written by Paul Anderson.
%
% -------------------------------------------------------------------------
% Input arguments
% -------------------------------------------------------------------------
% 
% inxs - the indices over which the heights will be examined
%
% I - an vector of intensites
%
% -------------------------------------------------------------------------
% Output arguments
% -------------------------------------------------------------------------
% 
% height - the difference between the maximum I value and the minimum I
%          value over the indices specified by inxs.

mn = min(I(inxs));
mx = max(I(inxs));
height = mx-mn;