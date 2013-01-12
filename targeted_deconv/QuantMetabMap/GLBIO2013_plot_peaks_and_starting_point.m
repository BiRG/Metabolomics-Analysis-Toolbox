function [handles, element_names]=GLBIO2013_plot_peaks_and_starting_point( title_text, x, peaks, peak_num, starting_params, lower_bounds, upper_bounds )
% Plots the given peaks on the current axes and plots the starting point for the peak at index peak_num
%
% Usage: GLBIO2013_plot_peaks_and_starting_point( title_text, x, peaks, peak_num, beta0, lb, ub )
%
% -------------------------------------------------------------------------
% Input parameters
% -------------------------------------------------------------------------
%
% title_text - (string) containing the title of the plot
%
% x - (vector) the sorted list of x coordinates (in ppm) to plot
%
% peaks - (vector of GaussLorentzPeak) the peaks whose sum makes up the
%         spectrum
%
% peak_num - (scalar) the index of the peak whose starting point will be
%            plotted
%
% starting_params - (vector) the array of peak parameters giving the
%                   starting point of the search. Must be suitable for
%                   passing to GaussLorentzPeak
%
% lower_bounds - (vector) lower_bounds(i) is the lower bound on the
%                parameter in starting_params(i)
%
% upper_bounds - (vector) upper_bounds(i) is the upper bound on the
%                parameter in starting_params(i)
%
% -------------------------------------------------------------------------
% Output parameters
% -------------------------------------------------------------------------
% handles - (row vector) the handles to the plot elements to be used in the
%           legend
%
% element_names - (row vector string cell array) element_names{i} is the 
%                 name that should be used in the legend for handles(i)
%           
hold_was_on = ishold;

handles = zeros(1,4);
element_names = {'Spectrum','Initial peak params','Loc & height bnds','Width bounds'};

handles(1) = plot(x, sum(peaks.at(x),1),'k');
hold('on');
title(title_text);
starting_peaks = GaussLorentzPeak(starting_params);
param_idxs = 4*(peak_num-1)+1:4*(peak_num);
lb = lower_bounds(param_idxs);
ub = upper_bounds(param_idxs);
handles(2) = plot(x, starting_peaks(peak_num).at(x),'r--');
handles(3) = plot([lb(4),lb(4),ub(4),ub(4)],[lb(1),ub(1),ub(1),lb(1)],'b-');
xloc = starting_peaks(peak_num).location;
handles(4) = plot([xloc-ub(2),xloc-ub(2),xloc+ub(2),xloc+ub(2)],[max(ylim), 0, 0, max(ylim)],'g--');
ylabel('Intensity');
xlabel('ppm');
set(gca,'XDir','reverse');

if ~hold_was_on
    hold('off');
end

end

