function [ dmap ] = dataDensity( x, y, width, height, limits)
%DATADENSITY Get a data density image of data 
%   x, y - two vectors of equal length giving scatterplot x, y co-ords
%   width, height - dimensions of the data density plot, in pixels
%   limits - [xmin xmax ymin ymax] - defaults to data max/min
%
% By Malcolm McLean
%
% Radically modified by Eric Moyer on 11 March 2013
%
    if(nargin == 4)
        limits(1) = min(x);
        limits(2) = max(x);
        limits(3) = min(y);
        limits(4) = max(y);
    end
    deltax = (limits(2) - limits(1)) / width;
    deltay = (limits(4) - limits(3)) / height;
    dmap = zeros(height, width);
    for ii = 0: height - 1
        ymin = limits(3) + ii * deltay;
        ymax = limits(3) + ii * deltay + deltay;
        include_ymax = ii == height - 1;
        for jj = 0 : width - 1
            xmin = limits(1) + jj * deltax;
            xmax = limits(1) + jj * deltax + deltax;
            include_xmax = jj == width -1;
            dd = 0;
            for kk = 1: length(x)
                curx = x(kk);
                cury = y(kk);
                if xmin <= curx && ...
                   (curx < xmax || (include_xmax && curx == xmax)) && ...
                   ymin <= cury && cury < ymax && ...
                   (cury < ymax || (include_ymax && cury == ymax))
                    dd = dd + 1; 
                end
            end
            dmap(ii+1,jj+1) = dd;
        end
    end
            

end

