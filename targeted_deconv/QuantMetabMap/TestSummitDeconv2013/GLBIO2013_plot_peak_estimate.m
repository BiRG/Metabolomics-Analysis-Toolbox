function GLBIO2013_plot_peak_estimate( datum, deconv_idx, deconv_peak_idx, show_others )
% Generates a plot showing the relationship between a deconvolved peak and its aligned original
% Usage: GLBIO2013_plot_peak_estimate( datum, deconv_idx, deconv_peak_idx, show_others )
%
% The plot is made on the current axes.
%
% -------------------------------------------------------------------------
% Input parameters
% -------------------------------------------------------------------------
%
% datum - a ExpDatum object
%
% deconv_idx - (array index) the index of the deconvolution object whose 
%      peak will be compared to its aligned original.  That is
%      datum.deconvolutions(deconv_idx) will be compared.
%
% deconv_peak_idx - (array index) the index of the peak within the 
%      deconvolution object to be compared. That is, 
%      datum.deconvolutions(deconv_idx).peaks(deconv_peak_idx) will be
%      compared.
%
% show_others - (logical) if true, the other peaks are displayed along with the
%      corresponding pair
%
% -------------------------------------------------------------------------
% Output parameters
% -------------------------------------------------------------------------
%
% -------------------------------------------------------------------------
% Examples
% -------------------------------------------------------------------------
%
% >> GLBIO2013_plot_peak_estimate( datum, 1, 2)
%
% Generates a plot for comparing datum.deconvolutions(1).peaks(2) with its
% aligned original in context.
%
% -------------------------------------------------------------------------
% Authors
% -------------------------------------------------------------------------
%
% Eric Moyer (eric_moyer@yahoo.com) May 2013

handles = zeros(5,1);
deconv = datum.deconvolutions(deconv_idx);
dec_other_peaks = deconv.peaks(1:length(deconv.peaks) ~= deconv_peak_idx);
dec_peak = deconv.peaks(deconv_peak_idx);
ali = deconv.aligned_indices;
match = ali(2,:) == deconv_peak_idx;
if sum(match) ~= 1
    warning('plot_peak_estimate:no_correspondence',['Datum %s Deconv %d ' ...
        'Peak %d either more or less than one corresponding peaks in the ' ...
        'original. The alignment was: %s'], datum.id, deconv_idx, ...
        deconv_peak_idx, to_str(ali));
    return;
end

orig_peak_idx = ali(1,match);    
orig_other_peaks = datum.spectrum_peaks(1:length(datum.spectrum_peaks) ~= orig_peak_idx);
orig_peak = datum.spectrum_peaks(orig_peak_idx);
x = datum.spectrum.x;

handles(1) = plot(x, datum.spectrum.Y, 'color', [0.33,0.33, 0.33]);
was_hold = ishold;
hold on;
if show_others
    h = plot(x, orig_other_peaks.at(x),'b-');
    handles(3) = h(1);
    h = plot(x, dec_other_peaks.at(x),'m--');
    handles(5) = h(1);
end
handles(2) = plot(x, orig_peak.at(x),'g-');
handles(4) = plot(x, dec_peak.at(x),'r--');
if show_others
    legend(handles, 'Spectrum','Original peak', 'Other original','Deconvolved peak', 'Other deconvolved');
else
    legend(handles([1,2,4]), 'Spectrum','Original peak','Deconvolved peak');
end

if ~was_hold
    hold off;
end

end

