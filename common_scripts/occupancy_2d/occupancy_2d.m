function [ dmap ] = occupancy_2d( x, y, width, height, limits)
%DATADENSITY Get a data density image of data 
%   x, y - two vectors of equal length giving scatterplot x, y co-ords
%   width, height - dimensions of the data density plot, in pixels
%   limits - [xmin xmax ymin ymax] - defaults to data max/min
%
% Originally by Malcolm McLean
%
% Radically modified by Eric Moyer in March 2013
%
    if(nargin == 4)
        limits(1) = min(x);
        limits(2) = max(x);
        limits(3) = min(y);
        limits(4) = max(y);
    end
    
    % dmap(i,j) is the number of entries in bin i,j 
    dmap = zeros(height, width);
    
    % Calculate the edges of the bins
    x_edges = linspace(limits(1), limits(2), width+1);
    y_edges = linspace(limits(3), limits(4), height+1);
    
    % Find out which bin each point will fall into
    [~, xbin] = histc(x, x_edges);
    [~, ybin] = histc(y, y_edges);
    assert(length(xbin) == length(ybin));
    
    % Make the last bin include points equal to its upper bound
    xbin(xbin > size(dmap,1)) = size(dmap,1);
    ybin(ybin > size(dmap,2)) = size(dmap,2);
    
    % Count the values in each bin
    for i = 1:length(xbin)
        binx = xbin(i); biny = ybin(i); % Index of dest for current point
        if binx > 0 && biny > 0
            dmap(biny, binx) = dmap(biny, binx) + 1;
        end
    end
    

end

