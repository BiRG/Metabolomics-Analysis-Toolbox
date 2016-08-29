function score = show_minima(spectrum_idx)
    
    collections = getappdata(gcf, 'collections');
    [x, Y] = combine_collections(collections);
    y = Y(:, spectrum_idx)';
    
    % Find local minima
    [raw_minima, raw_locs] = findpeaks(0 - y);
    raw_minima = 0 - raw_minima;
    raw_locs = x(raw_locs);
    
    % Calculate prominence
    raw_proms = zeros(1, numel(raw_minima));
    for i = 2:numel(raw_minima) - 1
        raw_proms(i) = abs(mean([raw_minima(i - 1), raw_minima(i + 1)]) - raw_minima(i));
    end
    
    % Sort prominences and remove top and bottom percentile (20%)
    [sorted_proms, sort_indices] = sort(raw_proms);
    sorted_locs = raw_locs(sort_indices);
    sorted_minima = raw_minima(sort_indices);
    elements_to_remove = round(numel(sorted_proms) * 0.20);
    %proms = sorted_proms(1 + elements_to_remove:end - elements_to_remove);
    locs = sorted_locs(1 + elements_to_remove:end - elements_to_remove);
    minima = sorted_minima(1 + elements_to_remove:end - elements_to_remove);
    
    % Spline and score (How far points are below the spline)
    yspline = spline(locs, minima, x);
    score = 0;
    for i = 1:numel(y)
        if y(i) < yspline(i)
            score = score + (yspline(i) - y(i));
        end
    end
    
    % Plot the whole thing
    hold on;
    scatter(locs, minima, 'b');
    plot(x, yspline, 'r');
    hold off;
    
end
