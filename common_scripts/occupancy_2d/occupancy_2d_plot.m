function occupancy_2d_plot( x, y, levels, width, height, limits)
%Plot the number of points in each square
%   Makes a contour map of data density
%   x, y - data x and y coordinates
%   levels - number of contours to show
%   limits - [xmin xmax ymin ymax] - defaults to data max/min
%   width  - width in pixels - number of horizontal bins - defaults to 256
%   height - height in pixels - number of vertical bins - defaults to 256
%
% By Eric Moyer
%
% Derived from DataDensityPlot by Malcolm Mclean
%

    if ~exist('limits', 'var')
        limits(1) = min(x);
        limits(2) = max(x);
        limits(3) = min(y);
        limits(4) = max(y);
    end
    
    if ~exist('width','var')
        width = 256;
    end

    if ~exist('height','var')
        height = 256;
    end
    
    map = occupancy_2d(x, y, width, height, limits);
    map = flipud(map);

    density_min = min(min(map));
    density_max = max(max(map));
    map = map - min(min(map));
    map = floor(map ./ max(max(map)) * (levels-1));
    
    image(map);
    colormap(jet(levels));
    set(gca, 'XTick', [1 width]);
    set(gca, 'XTickLabel', limits(1:2));
    set(gca, 'YTick', [1 height]);
    set(gca, 'YTickLabel', limits(4:-1:3));
end

