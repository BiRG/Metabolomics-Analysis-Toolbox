function image = reconstruct_image( in, width, returnUint8 )
%Reconstructs an image from the 8x8 strip representation in break_up_image
%
% If returnUint8 is absent, it is treated as true.
% If returnUint8 is true, then the result is rounded and truncated to
% 0..255 and converted to unsigned integers. Otherwise, the raw double
% array is returned.

if ~exist('returnUint8','var')
    returnUint8 = true;
end


xsize = width;
ysize = size(in,1)*64/width;
image = zeros(ysize,xsize);
ytop = 1;
xleft = 1;
for row = 1:size(in,1)
    offset = 1;
    for y=0:7
        for x=0:7
            image(ytop+y, xleft+x)=in(row, offset);
            offset = offset + 1;
        end
    end
    xleft = xleft + 8;
    if xleft >= width
        xleft = 1;
        ytop = ytop + 8;
    end
end

% Round and truncate before converting back to 8-bit
if returnUint8
    image = round(image);
    image(image < 0) = 0;
    image(image > 255) = 255;
    image = uint8(image);
end

end

