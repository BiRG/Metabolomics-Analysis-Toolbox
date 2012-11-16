function quick_plot_bin( bx, by, peaks)
% Plot bin with deconvolved peaks - quick and dirty for testing
% 
% This is a quick and dirty function for plotting peaks in a bin along with 
% the actual data during testing of the deconvolution code.
%
% bx - the x values in the bin
%
% by - the y values in the bin
%
% peaks - an array of GaussLorentzPeak objects to plot

plot_handles(1) = plot(bx, by, 'b-');

% Now plot the peaks and their sum
hold on;
bp = zeros(size(bx)); %sum of the peak values in the bin

for i = 1:length(peaks)
    py = peaks(i).at(bx);
    bp = bp + py;
    plot_handles(2)=plot(bx, py, 'g-');
end
plot_handles(3)=plot(bx, bp, 'r--');

legend(plot_handles, 'Raw data','Individual Peaks','Peak sum');
hold off;

end

