function create_peak_finding_training_arff( out_filename, relation_name, window_width, noise_est_first, noise_est_last, equalize_has_peaks_prob)
% Writes training data based on '6_1.mat' to out_filename in arff format
%
% Creates (or overwrites) out_filename with training data for peak finding.
% The data is loaded from 6_1.mat.  Then for each spectrum, the sample 
% standard deviation of the y values from indexes noise_est_first to 
% nose_est_last is chosen as an estimate of the standard deviation of the
% noise for that spectrum.  
%
% The attributes output to the arff file are:
% 
% "noise std dev"
% "intensity 1"
% "delta intensity 2" %Intensity 2 after subtracting intensity 1
% ...
% "delta intensity n" where n is the window width
% "number of peaks" (an integer variable giving the number of peaks nearer to that point than to any other)
% "number of peaks class" (a NOMINAL variable "0 peaks" "1 peak" "2 peaks" ...)
% "has peaks" (a NOMINAL variable "false" "true", whether num peaks > 0)
%
% The intensities and number of peaks for each instance are determined by
% running a sliding window of window_width along the spectrum.
% window_width must be an odd integer.  The window starts with its lowest
% index at the lowest index in the spectrum and slides up.  The intensities
% are the intensities in the window and the number of peaks for that
% instance is the number of peaks for the center of the window.  This
% ensures that no filling needs to be done at the ends but also gets rid
% of potential peaks at the ends.  Since the ends are sparsely populated,
% this is an acceptable risk.
%
% If equalize_has_peaks_prob is true then, before writing the output
% randomly removes enough of the correct type of example so that there are
% the same number of has_peaks == true instances as there are has_peaks ==
% false instances.
%
% Finally the instances are written to the file, naming the relation
% relation_name


window_width = round(window_width);
if window_width < 1 || mod(window_width,2) ~= 1
    error('Window width must be a positive odd integer.');
end
input_filename = '~/Dropbox/NMR-Training-and-Testing-Data-Sets/Synthetic Data Sets/6/6_1.mat';
s=load(input_filename);
s.spectra = s.spectra(1:2); %TODO remove

% Calculate the noise estimates per spectrum
noise_ests=zeros(1,length(s.spectra));
for i=1:length(s.spectra)
    noise_ests(i)=std(s.spectra{i}.y(noise_est_first:noise_est_last));
end

% Calcuate the number of windows needed to cover all the spectra
num_windows=0;
for i=1:length(s.spectra)
    num_windows = num_windows + max(0,length(s.spectra{i}.x) - window_width);
end

% Add peak counts to the loaded spectra
counts = peak_counts(s.spectra);
s.spectra = add_peak_counts(counts, s.spectra);

% Set the contents of the windows
instances.window_contents=zeros(num_windows, window_width);
instances.window_noise=zeros(num_windows,1); %Noise estimate for the window
instances.num_peaks=zeros(num_windows,1); %Number of peaks at center of window
cur_window = 1; %Index of the current window
for spec_idx=1:length(s.spectra)
    spec = s.spectra{spec_idx};
    for window_first=1 : 1+length(spec.x)-window_width
        instances.window_contents(cur_window,:)=spec.y(window_first:window_first+window_width-1);
        instances.window_contents(cur_window,2:window_width) = ...
            instances.window_contents(cur_window,2:window_width) - ...
            instances.window_contents(cur_window,1);
        instances.window_noise(cur_window)=noise_ests(spec_idx);
        win_center = window_first+(window_width-1)/2;
        instances.num_peaks(cur_window)=spec.num_peaks_at_x(win_center);
        cur_window = cur_window + 1;
    end
end

% Equalize the number of instances
if equalize_has_peaks_prob
    % Sort by whether a window has peaks
    has_peaks = instances.num_peaks > 0;
    [~,sort_order] = sort(has_peaks);
    instances.window_contents = instances.window_contents(sort_order, :);
    instances.window_noise = instances.window_noise(sort_order);
    instances.num_peaks = instances.num_peaks(sort_order);
    
    % Count the number of windows with and without peaks
    num_with_peaks = length(find(has_peaks));
    num_without_peaks = length(has_peaks)-num_with_peaks;
    if num_with_peaks == 0 
        error('Cannot equalize peak counts because there are no peaks');
    elseif num_without_peaks == 0
        error('Cannot equalize peak counts because there are no points without peaks');
    end
    
    %Create a mask to randomly select the windows to delete
    num_to_delete = abs(num_with_peaks - num_without_peaks);
    num_to_leave = max(num_with_peaks, num_without_peaks)-num_to_delete;
    delete_this=[true(num_to_delete,1);false(num_to_leave,1)];
    delete_this=delete_this(randperm(length(delete_this)));
    if num_with_peaks > num_without_peaks
        delete_this=[false(num_without_peaks,1);delete_this];
    else
        delete_this=[delete_this;false(num_with_peaks,1)];
    end
    
    %Do the deletion
    instances.window_contents(delete_this, :)=[];
    instances.window_noise(delete_this)=[];
    instances.num_peaks(delete_this)=[];
end

% Write the file
fid = fopen(out_filename,'w');
if fid < 0
    error(['Cannot open file ' out_filename]);
end

fprintf(fid,'%% Training data for peak finding\n');
fprintf(fid,'%% \n');
fprintf(fid,'%% Synthetic spectra were broken up into equal-sized windows\n');
fprintf(fid,'%% \n');
fprintf(fid,'%% A noise estimate was made using a certain range of \n');
fprintf(fid,'%% indices from the original spectrum\n');
fprintf(fid,'%% \n');
if equalize_has_peaks_prob
    eq_has_peaks_text = 'true';
    fprintf(fid,'%% The number of examples with and without peaks was\n');
    fprintf(fid,'%% equalized by randomly deleting examples from the more\n');
    fprintf(fid,'%% common class.\n');
    fprintf(fid,'%% \n');
else
    eq_has_peaks_text = 'false';
end
fprintf(fid,'%% Parameters: \n');
fprintf(fid,'%%    Input file:                     %s\n', input_filename);
fprintf(fid,'%%    Output file:                    %s\n', out_filename);
fprintf(fid,'%%    Window size:                    %d\n', window_width);
fprintf(fid,'%%    Noise indices:                  [%d, %d]\n', noise_est_first, noise_est_last);
fprintf(fid,'%%    Equalize has_peaks probability: %s\n',eq_has_peaks_text);
fprintf(fid,'%% \n');
fprintf(fid,'%% \n');
fprintf(fid,'@relation "%s"\n', relation_name);
fprintf(fid,'\n');
fprintf(fid,'@attribute "noise std dev" real\n');
fprintf(fid,'@attribute "intensity 1" real\n');
for i=2:window_width
    fprintf(fid,'@attribute "delta intensity %d" real\n',i);
end
fprintf(fid,'@attribute "number of peaks" integer\n');
fprintf(fid,'@attribute "number of peaks class" {"0 peaks","1 peak"');
max_num_peaks = max(instances.num_peaks);
for i = 2:max_num_peaks
    fprintf(fid,',"%d peaks"',i);
end
fprintf(fid,'}\n');
fprintf(fid,'@attribute "has peaks" {false,true}\n');
fprintf(fid,'\n');


fprintf(fid,'@data\n');
for i=1:length(instances.num_peaks)
    fprintf(fid, '%f', instances.window_noise(i));
    fprintf(fid, ',%f', instances.window_contents(i,:));
    np = instances.num_peaks(i);
    if np > 0
        has_peaks_text='true';
    else
        has_peaks_text='false';
    end
    if np == 1
        pluralized_peaks = 'peak';
    else
        pluralized_peaks = 'peaks';
    end
    fprintf(fid, ',%d,"%d %s",%s\n', ...
        np, np, pluralized_peaks, has_peaks_text);
end

fclose(fid);
