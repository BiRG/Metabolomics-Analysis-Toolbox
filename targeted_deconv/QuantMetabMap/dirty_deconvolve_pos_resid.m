function peaks = dirty_deconvolve_pos_resid( x, y, peak_x, num_neighbors, noise_std )
% Does a quick and dirty deconvolution of region given by x,y if the peaks have location parameters peak_x
% 
% Does a greedy fit, starting with the highest peak x's of 1 peak at a
% time, looking only at the points near the x location of that peak. Now
% includes a regularization that penalizes negative residuals for the rest
% of the spectrum. Negative residuals are assigned a score by dividing by
% the noise standard deviation, subtracting 4 and then raising to the 4'th 
% power if the result is still negative. 
%
% x - the x coordinates of the spectrum segment to deconvolve 
%
% y - the y coordinates of the spectrum segment to deconvolve - correspond
% to the xs
%
% peak_x - the x coordinates of the different peaks
%
% num_neighbors - the number of samples to use for the neighbors of the
% peak that will be looked at in doing the optimization. The closest
% num_neighbors neighbors will be used (or if num_neighbors is greater than
% the number of available points in the interval, all points will be used)
%
% noise_std - the standard deviation of the noise regions in the spectrum
%
% Returns an array of GaussLorentzPeak objects

function val=penalty(local_x, local_rem, global_x, global_rem, params, x0, noise_std)
    glp = GaussLorentzPeak([params, x0]);
    
    % Calculate the regularization - penalize negative values more than
    % num_std noise standard deviations below 0
    num_std = 4;
    val = (global_rem - glp.at(global_x)) + num_std*noise_std;
    val(val > 0) = 0;
    val = sum((val/noise_std).^4);
    
    % Add the penalty for misfit in the local neighborhood: the local 
    % remainder at that point minus the current peak's value at that point
    val = val + sum(abs(local_rem-(glp.at(local_x))).^2);
end

assert(noise_std > 0);

% Sort x (and put y in the same order)
if all(size(x) ~= size(y))
    y = y';
end
assert(all(size(x) == size(y)));

[x, order] = sort(x);
y = y(order);

% Also sort peak_x
peak_x = sort(peak_x);

% Calculate the nearest neighbors each peak
peak_neighborhood_x=cell(length(peak_x),1);
peak_neighborhood_y=cell(length(peak_x),1);
for i = 1:length(peak_x)
    distances = abs(x-peak_x(i));
    [~, order] = sort(distances);
    neighbors_x = x(order);
    neighbors_y = y(order);
    if(length(neighbors_x) > num_neighbors)
        neighbors_x = neighbors_x(1:num_neighbors);
        neighbors_y = neighbors_y(1:num_neighbors);
    end
    peak_neighborhood_x{i} = neighbors_x;
    peak_neighborhood_y{i} = neighbors_y;
end
clear i;

% Start with 0 height peaks at the correct x values
initial_peak_params = repmat([0, 0.5, 0.5, 0],1,length(peak_x));
initial_peak_params(4:4:4*length(peak_x))=peak_x;
peaks = GaussLorentzPeak(initial_peak_params);

% Find out the heights at the initial peak coordinates
peak_heights = interp1(x, y, peak_x);
[~, peak_fit_order] = sort(peak_heights,'descend');

for pass = 1:3
    for peak_to_fit_idx = 1:length(peak_x)
        peak_idx = peak_fit_order(peak_to_fit_idx);
        [local_x,order] = sort(peak_neighborhood_x{peak_idx});
        local_y = peak_neighborhood_y{peak_idx}(order);
        local_sum = sum(peaks.at(local_x))-peaks(peak_idx).at(local_x); % Sum of all peaks but this one (really sum of all peaks - value of this peak)
        local_rem = local_y - local_sum; % Remainder in the neighborhood
        
        % Compute the non-local x and y (called global here) for use in the
        % regularization term
        [global_x, global_x_idx] = setdiff(x, local_x);
        global_y = y(global_x_idx);
        global_rem = global_y - sum(peaks.at(global_x)) + peaks(peak_idx).at(global_x); 

        % Do the minimization
        p = peaks(peak_idx);
        M = interp1(local_x, local_rem, p.x0); %Start the peak at the peak value for its remainder
        err_fun=@(params) penalty(local_x, local_rem, global_x, global_rem, params, p.x0, noise_std);
        new_params = fminsearch(err_fun, [M, p.G, p.P],optimset('Display','off'));
        peaks(peak_idx)=GaussLorentzPeak([new_params, p.x0]);

        % *****************************************************************
        % Uncomment the following to get nice graphical plots of debugging
        % and current point each iteration
        % *****************************************************************
%         quick_plot_bin(x, y, peaks);
%         uiwait(msgbox(sprintf('Done with peak %d pass %d. Click to continue.', peak_idx, pass)));
%         p=peaks(peak_idx);
%         fprintf('Cur [M G P x0]: %g %g %g %g\n', p.M, p.G, p.P, p.x0);
    end
end

end