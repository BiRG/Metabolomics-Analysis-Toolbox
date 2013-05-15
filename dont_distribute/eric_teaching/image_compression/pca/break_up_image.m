function out = break_up_image( image )
%Each row of the result is an 8x8 section of the original
%
% Breaks input grayscale image into 8x8 blocks, puts them in row-major
% order. If the original is not a multiple of 8 in both dimensions, throws
% an error.

xsize = size(image,2);
ysize = size(image,1);

assert(mod(xsize, 8) == 0 && mod(ysize, 8) == 0);
out = zeros(xsize*ysize/64,64);
row = 1;
for i = 1:8:ysize
    for j = 1:8:xsize
        offset = 1;
        for y=0:7
            for x=0:7
                out(row, offset) = image(i+y,j+x);
                offset = offset+1;
            end
        end
        row = row + 1;
    end
end


end

