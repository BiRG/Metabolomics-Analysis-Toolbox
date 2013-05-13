function [ dmap ] = occupancy_2d( x, y, width, height, limits)
% Counts points in an evenly spaced 2D rectanglular grid of bins
% Usage: occupancy_2d( x, y, width, height, limits)
%
% Divides the 2D rectangle limits into width x height bins. Every bin has
% the same dimensions. Then counts the number of points x(i),y(i) that fall
% into each bin and returns the matrix giving those counts.
%
% -------------------------------------------------------------------------
% Input arguments
% -------------------------------------------------------------------------
% 
% x - (vector) horizontal coordinates of scatter plot points. Must be same 
%     length as y
%
% y - (vector) vertical coordinates of scatter plot points. Must be same 
%     length as x
%
% width - (integer >= 1) number of bins in occupancy plot horizontally
%
% height - (integer >= 1) number of bins in occupancy plot vertically
%
% limits - (optional 4x1 vector) - [xmin xmax ymin ymax]. All points that
%          are outside of these closed intervals are not counted. Points
%          are counted if xmin <= point.x <= xmax and 
%          ymin <= point.y <= ymax
%
%          defaults to smallest rectangle that includes all points - the
%          maxima and minima of the data in each dimension independently
%
% -------------------------------------------------------------------------
% Output parameters
% -------------------------------------------------------------------------
% 
% dmap - (2d matrix) columns are the x bins and rows are the y bins, each
%        entry is the number of x,y elements that fell into the particular 
%        bin.
%
% -------------------------------------------------------------------------
% Examples
% -------------------------------------------------------------------------
%
% >> occupancy_2d([1,3,5],[1,1,5],4,4)
%
% ans =
%
%     1     0     1     0
%     0     0     0     0
%     0     0     0     0
%     0     0     0     1
%
% >> occupancy_2d([1,3,5],[1,1,5],4,4,[0,4,0,4])
%
% ans =
%
%     0     0     0     0
%     0     1     0     1
%     0     0     0     0
%     0     0     0     0
%
% -------------------------------------------------------------------------
% Authors
% -------------------------------------------------------------------------
%
% Eric Moyer (March-April 2013) eric_moyer@yahoo.com
%
%
% Derived from dataDensity.m by Malcolm McLean
%

    % Throw exception if width or height are not positive integers
    assert(width > 0, 'occupancy_2d:bad_num_bins', ...
        'The width passed to occupancy_2d must be one or more.');
    assert(width == round(width), 'occupancy_2d:bad_num_bins', ...
        'The width passed to occupancy_2d must an integer.');
    assert(height > 0, 'occupancy_2d:bad_num_bins', ...
        'The height passed to occupancy_2d must be one or more.');
    assert(height == round(height), 'occupancy_2d:bad_num_bins', ...
        'The height passed to occupancy_2d must an integer.');
    
    % dmap(i,j) is the number of entries in bin i,j 
    dmap = zeros(height, width);

    % Ensure x and y are equal length
    assert(length(x) == length(y), 'occupancy_2d:same_x_y_length', ...
        'x and y inputs to occupancy_2d must have the same length');
    
    % If empty x or y matrix just return matrix of zeros
    if isempty(x)
        return; end % end is written on same line so code coverage catches the "execution" of the "end"

    % Fill in limits
    if ~exist('limits','var')
        limits(1) = min(x);
        limits(2) = max(x);
        limits(3) = min(y);
        limits(4) = max(y);
    end
    
    
    % Calculate the edges of the bins
    x_edges = linspace(limits(1), limits(2), width+1);
    if limits(1) == limits(2) % Single point is the x bin
        x_edges = x_edges(1); % So: only one edge
    end
    y_edges = linspace(limits(3), limits(4), height+1);
    if limits(3) == limits(4) % Single point is the y bin
        y_edges = y_edges(1); % So: only one edge
    end
    
    % Find out which bin each point will fall into
    [~, xbin] = histc(x, x_edges);
    [~, ybin] = histc(y, y_edges);
    assert(length(xbin) == length(ybin));
    
    % Make the last bin include points equal to its upper bound
    xbin(xbin > size(dmap,2)) = size(dmap,2);
    ybin(ybin > size(dmap,1)) = size(dmap,1);
    
    % Count the values in each bin
    for i = 1:length(xbin)
        binx = xbin(i); biny = ybin(i); % Index of dest for current point
        if binx > 0 && biny > 0
            dmap(biny, binx) = dmap(biny, binx) + 1;
        end
    end
    

end

