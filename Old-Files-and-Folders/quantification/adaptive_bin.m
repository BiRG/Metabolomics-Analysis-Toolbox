function [bins,stats] = adaptive_bin(x,Y,L)
 addpath('rwt');
% Compute the composite reference spectrum
composite_ref_spectrum = zeros(size(x));
nm = size(Y);
num_spectra = nm(2);
for s = 1:num_spectra
    composite_ref_spectrum = max([composite_ref_spectrum;Y(:,s)']);
end

% Smooth with the undecimated wavelet transform
h = daubcqf(4);

remainder = rem(length(composite_ref_spectrum),2^L);
add_len = 0;
if remainder ~= 0
    add_len = 2^L - remainder;
end
new_composite_ref_spectrum = zeros(1,length(composite_ref_spectrum)+add_len);
new_composite_ref_spectrum(1:length(composite_ref_spectrum)) = composite_ref_spectrum;
composite_ref_spectrum = new_composite_ref_spectrum;
[yl,yh,L] = mrdwt(composite_ref_spectrum,h,L);

% Use hard thresholding with a threshold of sigma*sqrt(2*log10(N)), where N
% is the number of data points and sigma is:
% sigma = median{|w11|,...,|w1N/2|}/0.6745
% where w1,i represents the ith wavelet coefficent for the first level of
% details

N = length(yl);
h_lev1 = yh(:,1:round(N/2));
%l_lev1 = yh(:,N+1:2*N);
%      lh_lev2 = yh(:,3*N+1:4*N); 
%      hl_lev2 = yh(:,4*N+1:5*N); 
%      hh_lev2 = yh(:,5*N+1:6*N);
sigma = median(abs(h_lev1))/0.6745;
thres = sigma*sqrt(2*log10(length(yl)));
yh = HardTh(yh,thres);
yl = HardTh(yl,thres);
smooth_composite_ref_spectrum = mirdwt(yl,yh,h,L);
% Remove the padding
smooth_composite_ref_spectrum = smooth_composite_ref_spectrum(1:length(x));

smoothed_maxs = find_maxs(smooth_composite_ref_spectrum);
smoothed_mins = find_mins(smooth_composite_ref_spectrum,smoothed_maxs);

bins = x(smoothed_mins);
length(bins)

stats = {};