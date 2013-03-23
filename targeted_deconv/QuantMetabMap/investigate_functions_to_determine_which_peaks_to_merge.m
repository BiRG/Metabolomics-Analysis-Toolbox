function mins=investigate_functions_to_determine_which_peaks_to_merge( )
% My work investigating which peaks I should in the noiseless_merged peak picker
% I have this as a separate function so that I can run it and set
% breakpoints

%% Calculate raw data
% Examine minimum between the 
num_widths = 80;
if num_widths <= 10
    widths = exp(linspace(log(1/3),log(3),num_widths)); % Use geometric progression when few widths
else
    widths = linspace(log(1/3),log(3),num_widths); %Otherwise use linear progression
end
ds=linspace(0,2,1024); ds = ds(2:end);  % 1023 distances from 0 to 2, excluding 0

mins=zeros(size(ds,2),size(widths,2)); 
num_maxes = mins;
for w_index = 1:length(widths)
    width = widths(w_index);
    for d_index = 1:length(ds); 
        d=ds(d_index); 
        g = GaussLorentzPeak([1,1,0,0,  2,width,0,d]); 
        x=linspace(0,d,1024); x = x(2:end-1);
        a=g(1).at(x); b=g(2).at(x); s=a+b;
        local_maxes = [true, s(1:end-1) < s(2:end)] & [s(1:end-1) > s(2:end),true];
        num_maxes(d_index, w_index) = sum(local_maxes);
        mins(d_index, w_index)=min(s); 
    end; 
end

%% Plot width vs distance
figure(1); clf;
legend(plot(ds, mins), arrayfun(@(x) sprintf('Width of larger peak %f', x), widths, 'UniformOutput', false));
title('Minimum between peaks versus distance for peaks of height 1 and 2')
xlabel('Distance apart');
ylabel('Height of minimum between peaks');

fprintf([...
    'The wider the larger peak, the farther apart the two peaks are '...
    'before the lowest point is at the location of the smaller peak.'...
    ]);

%% Plot tansition indices
figure(2); clf;
% legend(plot(ds, num_maxes), arrayfun(@(x) sprintf('Width of larger peak %f', x), widths, 'UniformOutput', false));
% title('Number of local maxima versus distance')
% xlabel('Distance apart');
% ylabel('Number of local maxima');

% Calculate d_index (distance index) at which we switch from 1 maximum to
% two maxima - assumes that the transition does not occur at the first or
% last distance examined.
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

%% Look at width, distance combinations with multiple transitions
% There are several widths where there is more than one transition between 
% 1 and 2 peaks when distance is changed. Here I plot the spectra for those 
% widths where there is more than one transition
width_has_more_than_one_transition = cellfun(@(x) length(x), transition_widths) > 1;
doubled_width_indices = find(width_has_more_than_one_transition);
transition_distance_indices = cell2mat(...
    arrayfun(...
        @(doubled_width_index) ...
            find(is_transition(:, doubled_width_index))', ...
        doubled_width_indices, 'UniformOutput',false ...
    )...
);
distance_indices = unique([transition_distance_indices, 1:4:length(ds)]);
for doubled_width_index = doubled_width_indices
    doubled_width = widths(doubled_width_index);
    figure(doubled_width_index);
    clf;
    x = linspace(0, max(ds), 1024);
    z = zeros(length(distance_indices), length(x));
    fprintf('%s %s %s %s\n', to_str(size(x)), to_str(size(ds(distance_indices))), to_str(size(z)), to_str(size(c)));
    c = zeros(size(z));
    for d_index = distance_indices
        d = ds(d_index);
        g = GaussLorentzPeak([1,1,0,0,  2, doubled_width,0,d]); 
        a=g(1).at(x); b=g(2).at(x); s=a+b;
        z(d_index, :) = s;
        c(d_index, :) = s;
    end
    for d_index = distance_indices
        if is_transition(d_index, doubled_width_index)
            c(d_index, :) = max(max(z));
        end
    end
    fprintf('%s %s %s %s\n', to_str(size(x)), to_str(size(ds(distance_indices))), to_str(size(z)), to_str(size(c)));
    surf(x, ds(distance_indices), z, c);
    title(sprintf('Width %f', doubled_width));
    xlabel('PPM');
    ylabel('Distance');
    zlabel('Intensity');
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

