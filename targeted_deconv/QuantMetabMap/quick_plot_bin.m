function quick_plot_bin( session_data,  bin_number, peaks)
% Plot bin with deconvolved peaks - quick and dirty for testing
% 
% This is a quick and dirty function for plotting peaks in a bin along with 
% the actual data during testing of the deconvolution code.
%
% session_data - a session data object saved by "save session and exit" in
% the main gui ( load('my_session_data.session','-mat') to get the object 
% from the file )
%
% bin_number - the number of the bin to plot
%
% peaks - an array of GaussLorentzPeak objects to plot

all_x = session_data.collection.x;
all_y = session_data.collection.Y;

bin = session_data.metab_map(bin_number).bin;

x_in_bin = all_x <= bin.left & all_x >= bin.right;

bx = all_x(x_in_bin); % bx(i) is an x value that lies in the bin
by = all_y(x_in_bin); % by(i) is the y value corresponding to bx(i)

plot_handles(1) = plot(bx, by, 'b-');

% Now plot the peaks and their sum
hold on;
bp = zeros(size(by)); %sum of the peak values in the bin

for i = 1:length(peaks)
    py = peaks(i).at(bx);
    bp = bp + py';
    plot_handles(2)=plot(bx, py, 'g-');
end
plot_handles(3)=plot(bx, bp, 'r--');

legend(plot_handles, 'Raw data','Individual Peaks','Peak sum');
hold off;

end

