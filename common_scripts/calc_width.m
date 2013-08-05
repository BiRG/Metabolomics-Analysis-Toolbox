function width=calc_width(inxs,cs,I)
% Return the estimated width of a peak over the region specified by inxs in the intensity vector I
%
% These documentation comments are being put-in after the fact for code
% written by Paul Anderson.
%
% Finds the maximum in the interval and calls it a peak. Then finds the
% y-value closest to half the peak height and calls it one side of the
% peak. Returns the distance between this point and another the same
% number of samples from the peak in the opposite direction.
%
% -------------------------------------------------------------------------
% Input arguments
% -------------------------------------------------------------------------
% 
% inxs - the indices over which the heights will be examined.
%
% cs - cs(i) is the x value (ppm) at which the intensity I(i) is obtained.
%      Samples are assumed to be approximately evenly spaced.
%
% I - an vector of intensites.  Same length as cs.
%
% -------------------------------------------------------------------------
% Output arguments
% -------------------------------------------------------------------------
% 
% width - the estimate of the width of the peak lying in the interval specified
%         by inxs

% Find the location of the maximum in the interval - assumed to be the peak
[mx,loc] = max(I(inxs));
peak_loc = inxs(loc);

% Find the location of the point closest to half the peak height
dist_from_half_height = abs(I(inxs)-mx/2);
[unused,loc2]=sort(dist_from_half_height); %#ok<ASGLU>
half_height_loc = inxs(loc2(1));

% Choose the two points at that distance from the central peak as
% representatives of the width
half_width_in_samples = abs(peak_loc-half_height_loc);
inx1 = peak_loc-half_width_in_samples;
if inx1 <= 0
    inx1 = 1;
end
inx2 = peak_loc+half_width_in_samples;
if inx2 > length(cs)
    inx2 = length(cs);
end

% Calculate the difference between the x values for those two samples 
width = abs(cs(inx1)-cs(inx2));