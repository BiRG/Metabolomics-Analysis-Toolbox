function results = GLBIO2013_run_experiment(num_spectra_per_width, instance_number, total_number_of_instances )
% Return an array of GLBIO2013Datum objects from processing num_spectra_per_width spectra for each of the desired widths
% 
% Usage: GLBIO2013_run_experiment( num_spectra_per_width, seed )
%
% num_spectra_per_width - the number of spectra to generate for each 
%        spectral width used in the experiment.
%
% instance_number - (integer valued scalar) the number of this instance 
%        within the set of all instances being used for the experiment. 
%        This is used to repeatably generate a stream of random numbers 
%        independent from the streams used by the other processors running
%        the experiment.
%
% total_number_of_instances - (integer valued scalar) the number of 
%        instances that will be running the experiment. Needed for 
%        generating the random number streams. May exceed but not 
%        undershoot the true number.
%
original_default_stream = RandStream.getDefaultStream;
seed = 925040534; % A 32 bit number from random.org
my_stream = RandStream.create('mrg32k3a', ...
    'NumStreams', total_number_of_instances, ...
    'StreamIndices', instance_number, 'Seed', seed);
RandStream.setDefaultStream(my_stream);



wait_h = waitbar(0,sprintf('Instance "%d"> initializing: MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM',instance_number));
widths_in_mean_peak_width = [5.75, 26.7855781172538272, 37.8140358572843098, 50.2757392223216968, 65.69707458955628, 86.6618791229460896, 116.956430245217931, 167.919406041352318, 267.692156378955815, 563.312931020470387];
widths_in_mean_peak_width = sort(widths_in_mean_peak_width, 2, 'descend'); % Do largest widths first so time estimate always errs on the side of overestimate
widths_in_ppm = widths_in_mean_peak_width .* 0.00453630122481774988;

final_num_spectra = num_spectra_per_width .* length(widths_in_ppm);
spectrum_times = [];
num_completed_spectra = 0;
results(final_num_spectra) = GLBIO2013Datum;
for rep = 1:num_spectra_per_width
    for width_idx = 1:length(widths_in_ppm)
        width = widths_in_ppm(width_idx);
        spectra_remaining = final_num_spectra - num_completed_spectra;
        waitbar(num_completed_spectra/final_num_spectra, wait_h, sprintf(...
            'Instance %d> rep: %d width: %6.4f (%d of %d) time remaining: %d +/- %d minutes, %d elapsed', ...
            instance_number, rep, width, width_idx, length(widths_in_ppm), ...
            round(spectra_remaining*mean(spectrum_times)), ...
            round(spectra_remaining*std(spectrum_times)), ...
            round(sum(spectrum_times))));
        cur_spectrum_time = tic;
        results(num_completed_spectra+1) = GLBIO2013Datum(width);
        num_completed_spectra = num_completed_spectra + 1;
        spectrum_times = [spectrum_times, toc(cur_spectrum_time)/60]; %#ok<AGROW>
    end
end
close(wait_h);


RandStream.setDefaultStream(original_default_stream);
end

