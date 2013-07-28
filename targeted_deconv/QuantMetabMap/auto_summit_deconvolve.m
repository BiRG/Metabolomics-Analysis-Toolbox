function peaks = auto_summit_deconvolve( x, y, num_neighbors, snr )
% Does a summit-focused deconvolution of region given by x,y
% 
% Does a greedy fit, starting with the highest peak x's of 1 peak at a
% time, looking only at the points near the x location of that peak. Stops
% when the largest residual is less than the snr (calculated as a fraction
% of the height of the largest point in the spectrum.
%
% x - the x coordinates of the spectrum segment to deconvolve 
%
% y - the y coordinates of the spectrum segment to deconvolve - correspond
% to the xs
%
% num_neighbors - the number of samples to use for the neighbors of the
% peak that will be looked at in doing the optimization. The closest
% num_neighbors neighbors will be used (or if num_neighbors is greater than
% the number of available points in the interval, all points will be used)
%
% snr - Stops adding peaks when the maximum residual is max_y/snr. So if
% a noise peak is 1% of the signal, you would use snr=100.
%
% Returns an array of GaussLorentzPeak objects


% Sort x (and put y in the same order)
if all(size(x) ~= size(y))
    y = y';
end
assert(all(size(x) == size(y)));

[x, order] = sort(x);
y = y(order);

max_y = max(y);
residuals = y; % With no peaks, the residual is just the original values
pass = 1;
while(max(residuals)*snr >= max_y)
    % Add a new peak at the current residual maximum
    peak_x(pass) = x(residuals == max(residuals)); %#ok<AGROW>
    peaks(pass) = GaussLorentzPeak([0,0.5,0.5,peak_x(end)]); %#ok<AGROW>
    
    % Calculate the neighborhood of that peak (which is now the last peak)
    distances = abs(x-peak_x(end));
    [~, order] = sort(distances);
    peak_neighborhood_x{pass} = x(order); %#ok<AGROW>
    peak_neighborhood_y{pass} = y(order); %#ok<AGROW>
    if(length(peak_neighborhood_x{pass}) > num_neighbors) 
        peak_neighborhood_x{pass} = peak_neighborhood_x{pass}(1:num_neighbors); %#ok<AGROW>
        peak_neighborhood_y{pass} = peak_neighborhood_y{pass}(1:num_neighbors); %#ok<AGROW>
    end
    [peak_neighborhood_x{pass},order] = sort(peak_neighborhood_x{pass}); %#ok<AGROW>
    peak_neighborhood_y{pass} = peak_neighborhood_y{pass}(order); %#ok<AGROW>
    
    % Refit all the peaks, starting and ending with the newly added one
    for peak_idx = [length(peak_x):-1:1,length(peak_x)]
        local_x = peak_neighborhood_x{peak_idx};
        local_y = peak_neighborhood_y{peak_idx};
        local_sum = sum(peaks.at(local_x),1)-peaks(peak_idx).at(local_x); % Sum of all peaks but this one (really sum of all peaks - value of this peak)
        local_rem = local_y - local_sum; % Remainder in the neighborhood
        % Error at a local point is the local remainder at that point minus
        % the current peak's value at that point
        p = peaks(peak_idx);
        M = interp1(local_x, local_rem, p.x0); %Start the peak at the peak value for its remainder
        err_fun=@(params) sum((abs(local_rem-(GaussLorentzPeak([params,p.x0]).at(local_x)))).^2);
        new_params = fminsearch(err_fun, [M, p.G, p.P],optimset('Display','off'));
        peaks(peak_idx)=GaussLorentzPeak([new_params, p.x0]); %#ok<AGROW>

        % *****************************************************************
        % Uncomment the following to get nice graphical plots of debugging
        % and current point each iteration
        % *****************************************************************
%         quick_plot_bin(local_x, local_y, peaks);
%         hold on; plot(local_x, local_rem, 'm'); hold off;
%         uiwait(msgbox(sprintf('Done with peak %d pass %d. Click to continue.', peak_idx, pass)));
%         p=peaks(peak_idx);
%         fprintf('Cur [M G P x0]: %g %g %g %g\n', p.M, p.G, p.P, p.x0);
    end
    residuals = y-sum(peaks.at(x),1);
    pass = pass + 1;
end

