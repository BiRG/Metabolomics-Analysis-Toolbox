function plot_nssd_metabolite( NSSD_dir, metabolite_dir, exp_dir, plot_imaginary )
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
% plot_imaginary (optional) is a logical that is true if should plot the
% imaginary axis. If omitted, it is considered false.
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
end

