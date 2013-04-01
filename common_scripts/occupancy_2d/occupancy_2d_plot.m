function occupancy_2d_plot( x, y, levels, width, height, limits, colormap_vals)
% Plot the number of points in each square
%
% Usage: occupancy_2d_plot( x, y, levels, width, height, limits)
%
% Makes a contour map of data density
%   x, y - data x and y coordinates
%   levels - number of contours to show
%   limits - [xmin xmax ymin ymax] - defaults to data max/min. Passing []
%            will also set to default
%   width  - width in pixels - number of horizontal bins - defaults to 64
%   height - height in pixels - number of vertical bins - defaults to 64
%   colormap_vals - the values to pass to the colormap function - defaults
%                   to jet(levels)
%
% By Eric Moyer
%
% Derived from DataDensityPlot.m by Malcolm Mclean
%

    if ~exist('limits', 'var') || length(limits) ~= 4
        limits(1) = min(x);
        limits(2) = max(x);
        limits(3) = min(y);
        limits(4) = max(y);
    end
    
    
    if ~exist('colormap_vals', 'var')
        colormap_vals = jet(levels);
    end
    
    if ~exist('width','var')
        width = 64;
    end

    if ~exist('height','var')
        height = 64;
    end
    
    map = occupancy_2d(x, y, width, height, limits);
    map = flipud(map);

    map = map - min(min(map));
    map = floor(map ./ max(max(map)) * (levels-1));
    
    image(map);
    colormap(colormap_vals);
    set(gca, 'XTick', [1 width]);
    set(gca, 'XTickLabel', limits(1:2));
    set(gca, 'YTick', [1 height]);
    set(gca, 'YTickLabel', limits(4:-1:3));
end

