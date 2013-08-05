function image = pca_reconstruct( num_components, score, comp, block_mean, width)
% Reconstruct image of given width using first num_components pca components
%
% Uses the first num_components components of comp to reconstruct 8x8
% windows from score and assemble those windows row-major order into an
% image of the given width.
%
% score = pca score for each component respectively (output of princomp)
% comp = pca component matrix (output of princomp)
% block_mean = mean of all blocks in the original

% Input error checking
assert(num_components > 0); % Must use at least one component
assert(num_components <= size(comp, 2)); % Can't use more components than there are
assert(round(num_components) == num_components); % num_components must be an integer
assert(mod(width,8) == 0); % Width must be a multiple of 8
assert(size(score, 1) >= width/8); % There must be at least one full row
assert(size(score, 2) == 64); % 8x8 windows flattened --> 64 pixels
assert(length(block_mean) == 64); % Should be mean of one block

% Reconstruct the blocks
blocks = score(:,1:num_components)*comp(:,1:num_components)'+repmat(block_mean,size(score,1),1);

% Assemble the blocks into an image
image=reconstruct_image(blocks,width,true);

end

