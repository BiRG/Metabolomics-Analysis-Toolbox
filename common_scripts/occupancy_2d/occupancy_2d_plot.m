function occupancy_2d_plot( x, y, levels, width, height, limits, colormap_vals)
% Plot the number of points in each square
% Usage: occupancy_2d_plot( x, y, levels, width, height, limits, colormap_vals)
%
% -------------------------------------------------------------------------
% Input arguments
% -------------------------------------------------------------------------
% 
% x - (vector) horizontal coordinates of points. Must be same length as y
%
% y - (vector) vertical coordinates of points. Must be same length as x
%
% levels - (integer >= 1) number of colors to show
%
% width - (integer >= 1) number of bins in occupancy plot horizontally
%     defaults to 64
%
% height - (integer >= 1) number of bins in occupancy plot vertically
%     defaults to 64
%
% limits - (optional 4x1 vector) - [xmin xmax ymin ymax]. All points that
%     are outside of these closed intervals are not counted. Points
%     are counted if xmin <= point.x <= xmax and 
%     ymin <= point.y <= ymax
%
%     defaults to smallest rectangle that includes all points - the
%     maxima and minima of the data in each dimension independently
%
%     Passing [] will also set to default
%
% colormap_vals - (optional m x 3 matrix) - the values to pass to the 
%     colormap function - defaults to jet(levels-1) (or jet(1) when levels
%     is 1)
%
% -------------------------------------------------------------------------
% Output parameters
% -------------------------------------------------------------------------
% 
% None
%
% -------------------------------------------------------------------------
% Examples
% -------------------------------------------------------------------------
%
% >> occupancy_2d_plot([1,3,5],[1,1,5],2,4,4)
%
% Makes a plot with cyan squares for each 1 and blue squares for each 0
%
%     0     0     0     1
%     0     0     0     0
%     0     0     0     0
%     1     0     1     0
%
% >> occupancy_2d_plot([1,3,5],[1,1,5],1,4,4)
%
% Gives a plot which is all cyan
%
% >> occupancy_2d_plot([1,3,5],[1,1,5],6,1,3)
%
% Makes a plot striped yellow, blue, and burnt-orange
%
% >> occupancy_2d_plot([2,3,6,7,2,3,6,7,4,5,2,4,5,7,2,7,3,4,5,6],[7, 7, 7, 7, 6, 6, 6, 6, 5, 5, 4, 4, 4, 4, 3, 3, 2, 2, 2, 2],10,8,8,[1,8,1,8],hot(5))
%
% Gives a white smiling face with a red border.
%
% >> occupancy_2d_plot([2,3,6,7,2,3,6,7,4,5,2,4,5,7,2,7,3,4,5,6],[7, 7, 7, 7, 6, 6, 6, 6, 5, 5, 4, 4, 4, 4, 3, 3, 2, 2, 2, 2],50,8,1,[1,8,1,8],hot(49))
%
% Gives 5 vertical stripes. Colors: black, white, yellow, white, black
% The yellow stripe is 4 units wide. The other stripes are 1 unit wide.
%
% -------------------------------------------------------------------------
% Authors
% -------------------------------------------------------------------------
%
% Eric Moyer (March-April 2013) eric_moyer@yahoo.com
%
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
        if(levels > 2)
            colormap_vals = jet(levels-1);
        elseif (levels >= 1)
            colormap_vals = jet(levels);
        else
            error('occupancy_2d_plot:at_least_one_level','The levels parameter must be at least 1');
        end
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
    if (max(max(map)) > 0)
        map = round(map ./ max(max(map)) * (levels-1));
    end
    
    colormap(colormap_vals);
    if (levels > 1)
        caxis([1,levels]);
    end
    image(map+1);
    if(width > 1)
        set(gca, 'XTick', [1 width]);
        set(gca, 'XTickLabel', limits(1:2));
    else
        set(gca, 'XTick', 1);
        set(gca, 'XTickLabel', sprintf('%.1g-%.1g',limits(1:2)));
    end
    if(height > 1)
        set(gca, 'YTick', [1 height]);
        set(gca, 'YTickLabel', limits(4:-1:3));
    else
        set(gca, 'YTick', 1);
        set(gca, 'YTickLabel', sprintf('%.1g-%.1g',limits(3:4)));
    end
end

