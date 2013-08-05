function mins=investigate_functions_to_determine_which_peaks_to_merge( )
% My work investigating which peaks I should in the noiseless_merged peak picker
%
% This will eventually be merged with Analysis.m
%
% I have this as a separate function so that I can run it and set
% breakpoints.

%% Calculate raw data
% Examine height of local minimum between two peaks as a function of the
% distance between them and their width. Also calculate the local maxima
% detected. If num_widths is small I use geometric progression to ensure
% symmetry in the ratios of the widths.
num_widths = 96;
max_width = 3;
min_width = 1/max_width;
assert(max_width > min_width);
if num_widths <= 10
    % Use geometric progression
    widths = exp(linspace(log(min_width),log(max_width),num_widths)); % Use geometric progression when few widths
else
    % Otherwise use linear progression modified to focus on the discontinuity in number of transitions
    non_function_start_width = 1.7;
    non_function_end_width = 2.1;
    num_non_function_widths = ceil(num_widths/3);
    num_function_widths = num_widths - num_non_function_widths;
    start_widths_length = non_function_start_width - min_width;
    end_widths_length = max_width - non_function_end_width;
    function_widths_length = start_widths_length + end_widths_length;
    num_start_widths = round(num_function_widths * start_widths_length/function_widths_length);
    num_end_widths = round(num_function_widths * end_widths_length/function_widths_length);
    
    widths = unique([...
        linspace(min_width, non_function_start_width, num_start_widths + 1) ... % +1 takes care of the fact that duplicate end-point with the following will be eliminated by unique
        linspace(non_function_start_width, non_function_end_width, num_non_function_widths) ...
        linspace(non_function_end_width, max_width, num_end_widths + 1) ...     % see previous comment about +1
        ]);        
end
ds=linspace(0,2,2048); ds = ds(2:end);  % 2047 distances from 0 to 2, excluding 0

start_time = now;
wait_h = waitbar(0,'Calculating width 0 of 1000000');
mins=zeros(size(ds,2),size(widths,2)); 
num_maxes = mins;
for w_index = 1:length(widths)
    elapsed_time = now - start_time;
    time_per = elapsed_time / (w_index - 1);
    time_remaining = (length(widths) - w_index + 1) * time_per * 24 * 60;
    waitbar((w_index-1)/length(widths), wait_h, sprintf('Calculating width %d of %d. %g min remain', w_index, length(widths), time_remaining));
    width = widths(w_index);
    for d_index = 1:length(ds); 
        d=ds(d_index); 
        g = GaussLorentzPeak([1,1,0,0,  2,width,0,d]); 
        x=linspace(0,d,1024); x = x(2:end-1);
        a=g(1).at(x); b=g(2).at(x); s=a+b;
        is_local_max = [true, s(1:end-1) < s(2:end)] & [s(1:end-1) > s(2:end),true];
        num_maxes(d_index, w_index) = sum(is_local_max);
        mins(d_index, w_index)=min(s); 
    end; 
end
delete(wait_h);

%% Plot height of minimum vs width vs distance
% The minimum between the two peaks varies with their widths and the
% distance between them. This plot attempts to capture some of that.
%
% It seems that The wider the larger peak, the farther apart the two peaks
% are before the lowest point is at the location of the smaller peak. 
figure(1); clf;
if length(widths) > 14
    plotted_min_indices = unique(round(linspace(1, length(widths), 14)));
else
    plotted_min_indices = 1:length(widths);
end
plotted_min_indices = sort(plotted_min_indices, 'descend');
plotted_mins = mins(:, plotted_min_indices);
plotted_widths = widths(plotted_min_indices);
legend(plot(ds, plotted_mins), arrayfun(@(x) sprintf('Width of larger peak %f', x), plotted_widths, 'UniformOutput', false));
title('Minimum between peaks versus distance for peaks of height 1 and 2')
xlabel('Distance apart');
ylabel('Height of minimum between peaks');


%% Plot tansition distances
% Plot the distances at which a transition between 1 and 2 local maxima
% occurs as a relation between it and width. It can be observed that this
% relation is not a function (something which shocked me).
figure(2); clf;
is_transition = cell2mat(arrayfun(@(w_index) num_maxes(1:end-1, w_index) ~= num_maxes(2:end, w_index), ...
    1:size(widths,2),'UniformOutput',false));
transition_indices = arrayfun(@(w_index) find(is_transition(:, w_index))', ...
    1:size(widths,2)-1,'UniformOutput',false);
transition_widths = arrayfun(@(w_index) repmat(widths(1, w_index),size(transition_indices{w_index})), ...
    1:size(transition_indices,2), 'UniformOutput', false);
flat_transition_indices = cell2mat(transition_indices);
flat_transition_widths  = cell2mat(transition_widths);
plot(flat_transition_widths, ds(flat_transition_indices), '+');
title('Distance at which the peaks join for a given width')
xlabel('Width');
ylabel('Distance at which the peaks join');

%% Plot the number of peaks for given distance and width
% This is another view of the transition distances, but easier to plot and
% very obvious where the 2d shape comes from. I just plot an image.
figure(3); clf;
colormap(gray(2));
image(widths, ds, num_maxes)
set(gca, 'YDir','normal');
title('# of peaks for a given width and distance (black = 1 peak, white = 2)');
xlabel('Width');
ylabel('Distance');

%% Look at width, distance combinations with multiple transitions
% There are several widths where there is more than one transition between 
% 1 and 2 peaks when distance is changed. Here I plot the spectra for three 
% widths where there is more than one transition.
%
% What I want to see is how two peaks, when they have been close enough to
% merge into a single local maximum can then separate again into multiple
% maxima.
width_has_more_than_one_transition = cellfun(@(x) length(x), transition_widths) > 1;
doubled_width_indices = find(width_has_more_than_one_transition);
doubled_width_indices = doubled_width_indices(round(linspace(1, length(doubled_width_indices), 3)));
transition_distance_indices = cell2mat(...
    arrayfun(...
        @(doubled_width_index) ...
            find(is_transition(:, doubled_width_index))', ...
        doubled_width_indices, 'UniformOutput',false ...
    )...
);
distance_indices = unique([transition_distance_indices-1,transition_distance_indices,transition_distance_indices+1, round(linspace(1,length(ds)-1,50))]);
x = linspace(0, max(ds), 1024);
for doubled_width_index = doubled_width_indices
    doubled_width = widths(doubled_width_index);
    figure(doubled_width_index);
    clf;
    z = zeros(length(distance_indices), length(x));
    c = zeros(size(z));
    for d_index_index = 1:length(distance_indices)
        d_index = distance_indices(d_index_index);
        d = ds(d_index);
        g = GaussLorentzPeak([1,1,0,0,  2, doubled_width,0,d]); 
        a=g(1).at(x); b=g(2).at(x); s=a+b;
        is_local_max = [true, s(1:end-1) < s(2:end)] & [s(1:end-1) > s(2:end),true];
        z(d_index_index, :) = s;
        c(d_index_index, :) = s;
        c(d_index_index, is_local_max) = 0;
    end
    for d_index_index = 1:length(distance_indices)
        d_index = distance_indices(d_index_index);
        if is_transition(d_index, doubled_width_index)
            c(d_index_index, :) = max(max(z));
        end
    end    
    colormap(jet(256));
    caxis([min(min(c)) max(max(c))]);
    surf_h = surf(x, ds(distance_indices), z, c);
    set(surf_h, 'EdgeColor', 'none', 'FaceColor', 'interp');
    title(sprintf('Width %f', doubled_width));
    xlabel('PPM');
    ylabel('Distance');
    zlabel('Intensity');
end


%% Look at width, distance combinations with multiple transitions (as images)
% There are several widths where there is more than one transition between 
% 1 and 2 peaks when distance is changed. Here I plot the spectra for three 
% widths where there is more than one transition.
%
% This time, I plot the spectra as images (height maps) this is the same as
% doing the surface plots on the x-z axis only. Doing this, I can use all
% the calculated distances without bogging down the computer.
width_has_more_than_one_transition = cellfun(@(x) length(x), transition_widths) > 1;
doubled_width_indices = find(width_has_more_than_one_transition);
doubled_width_indices = doubled_width_indices(round(linspace(1, length(doubled_width_indices), 3)));
distance_indices = 1:length(ds);
x = linspace(0, max(ds), 1024);
for doubled_width_index = doubled_width_indices
    doubled_width = widths(doubled_width_index);
    figure(doubled_width_index);
    clf;
    c = zeros(size(z));
    for d_index_index = 1:length(distance_indices)
        d_index = distance_indices(d_index_index);
        d = ds(d_index);
        g = GaussLorentzPeak([1,1,0,0,  2, doubled_width,0,d]); 
        a=g(1).at(x); b=g(2).at(x); s=a+b;
        is_local_max = [true, s(1:end-1) < s(2:end)] & [s(1:end-1) > s(2:end),true];
        c(d_index_index, :) = s;
        c(d_index_index, is_local_max) = 0;
    end
    for d_index_index = 1:length(distance_indices)
        d_index = distance_indices(d_index_index);
        if d_index < length(ds) && is_transition(d_index, doubled_width_index)
            c(d_index_index, :) = max(max(c));
        end
    end
    minc = min(min(c));
    maxc = max(max(c));
    num_colors = 512;
    c = num_colors*(c - minc)/(maxc-minc);
    colormap(jet(num_colors));
    
    image(ds(distance_indices), x, c');
    title(sprintf('Width %f', doubled_width));
    set(gca, 'YDir', 'normal');
    xlabel('Distance');
    ylabel('PPM');
end

%% Look at details of what the peaks do in the 4 regions revealed above
%
% Here I look at the behavior of width 1.976923. It has behavior similar to
% the first plot above - which has 4 regions: 0 to first
% transition, first to second, second to third and third to infinity. The
% three transitions are: [1.07917888563049846, 1.18866080156402742, 1.3431085043988269]
%
% I plot the spectrum for two peaks 1 height 1 width 1 and the other
% height 2 width 1.97692307692307701 using one distance from each region.
% To make the peak height changes more visible, I only plot the top part of
% each spectrum.
%
% In the first region we have the peaks close enough to create a 
% shoulder. In the second, they are too far apart to merge, and have a
% valley in between. In the third, back to a single peak with a noticable
% shoulder. Finally, in the fourth, the peaks separate for good.
%
% Looking at the plots above, it seems that the second boundary moves
% faster than the other two separating from the first boundary at a
% critical width and then moving rightward as width increases to join the 
% third boundary at a second critical width.
interesting_distances = [1,1.15,1.3,1.4]; 
interesting_distance_titles = {'Merged (d=1)' ...
    'Two peaks not shoulder (d=1.15)' 'Shoulder (d=1.3)' ...
    'Two clear peaks (d=1.4)'};
for fig=1:length(interesting_distances); 
    figure(fig); 
    d = interesting_distances(fig); 
    width = 1.976923; 
    x=linspace(-0.5,2.5,1024); 
    g = GaussLorentzPeak([1,1,0,0,  2, width,0,d]); 
    a=g(1).at(x); b=g(2).at(x); s=a+b; 
    plot(x, s, 'b', x, a, 'm', x, b, 'm'); 
    ylim([1.60,2.196]); xlim([min(x) max(x)]); 
    title(interesting_distance_titles{fig});
end

%% Plot whether mins are monotonic
mins_are_sorted = zeros(1, size(mins,2)); 
for i = 1:size(mins,2); 
    mins_are_sorted(i)=issorted(flipud(mins(:,1))); 
end
if all(mins_are_sorted)
    fprintf('Monotonic mins: In the distances and widths examined, the minimum value between the two peaks is a decreasing function of distance.\n');
else
    fprintf('Nonmonotonic mins: In the distances and widths examined, there are some values for which the minimum value between the two peaks is not a decreasing function of distance.\n');
end

end

