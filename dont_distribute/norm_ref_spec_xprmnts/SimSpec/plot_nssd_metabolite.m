function plot_nssd_metabolite( NSSD_dir, metabolite_dir, exp_dir, peak_window, plot_imaginary )
% Plot a metabolite from the MetAssimulo NSSD
%
% plot_nssd_metabolite( NSSD_dir, metabolite_dir, exp_dir, plot_imaginary )
%
% where: 
%
% NSSD_dir is the directory in which the NSSD is stored
%
% metabolite_dir is the directory in which the metabolite's experiments are
% stored
% 
% exp_dir is the directory under which the particular experiment to be
% plotted lies
%
% peak_window (optional) integer is the width (in samples) of the window for 
% detecting peaks. A peak is only considered to be a peak if it is greater
% than all samples from peak_loc-peak_window to peak_loc+peak_window. If
% zero or less, then no peaks are detected. If omitted treated like it was
% 0.
%
% plot_imaginary (optional) is a logical that is true if should plot the
% imaginary axis. If omitted, it is considered false.
%
%
%
% MetAssimulo uses a database of spectra of standards as the basic
% ingredient from which to construct its simulated spectra. This database
% is called the NSSD (NMR Standard Spectral Database). This code plots the
% data used for one metabolite.
%
% The location of the processed data should be in the directory:
% fullfile(NSSD_dir, metabolite_dir, exp_dir, 'pdata', '1');

if ~exist('plot_imaginary','var')
    plot_imaginary = false;
end

if ~exist('peak_window','var')
    peak_window = 0;
end



spec=metassimulo_specread(fullfile(NSSD_dir, metabolite_dir), exp_dir, '1');
if strcmp(spec, 'empty')
    error('plot_nssd_metabolite:no_spectrum',...
        'No spectrum to plot in the given directory');
end
if size(spec,2) ~= 3
    error('plot_nssd_metabolite:not_one_dim',...
        'The spectrum returned is not a 1D spectrum. Cannot plot it.');
end

if plot_imaginary
    plot(spec(:,1),spec(:,2),spec(:,1),spec(:,3));
    legend('Real','Imaginary');
else
    plot(spec(:,1),spec(:,2));
end
xlabel('ppm');
set(gca,'xdir','reverse');
ylabel('Intensity');

if peak_window > 0
    y=spec(:,2);
    window_rad = peak_window; % Only accept a maximum if it is greater than all pixels +/- window rad
    potential_max=window_rad+1:length(y)-window_rad;
    noise_std = std(spec(1:100,2));
    local_max = y(potential_max) > 10*noise_std;
    for window=-window_rad:1:window_rad
        local_max = local_max & y(potential_max) >= y(potential_max+window);
    end
    max_idx = potential_max(local_max);
    hold on;
    min_y = min(spec(:,2));
    max_y = max(spec(:,2));
    for i = 1:length(max_idx)
        x = spec(max_idx(i),1);
        y = spec(max_idx(i),2);
        fprintf('%g ppm: %g\n', x, y);
        line_handle = line([x,x],[min_y,max_y]);
        set(line_handle,'Color','r');
    end
    hold off;
end

end

