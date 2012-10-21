function out = green_red_image( real_im )
% Returns an image red for negative areas and green for positive areas of real_im
%
% real_im = 2d matrix of doubles
%
% out = 3d matrix of uint8

% Set the red and green components to be copies of the image and blue to 0
out(:,:,1)=real_im;
out(:,:,2)=real_im;
out(:,:,3)=zeros(size(real_im));

% Remove portions that have the wrong sign from their respective layers
pos = out > 0;
pos_and_red = pos; pos_and_red(:,:,2) = false;
neg_and_green = ~pos; neg_and_green(:,:,1) = false;
out(pos_and_red) = 0;
out(neg_and_green) = 0;

% Convert to uint8
out = abs(out);
out = out * 256 / max(max(max(out))) - 0.5; % This makes 0 and 255 come from bins equal in area to the bins that hold the rest of the numbers
out = round(out);
out(out < 0) = 0;
out(out > 255) = 255;
out = uint8(out);

end

