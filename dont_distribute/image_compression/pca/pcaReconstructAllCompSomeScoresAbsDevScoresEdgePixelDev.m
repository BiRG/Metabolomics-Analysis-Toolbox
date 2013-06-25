function image = pcaReconstructAllCompSomeScoresAbsDevScoresEdgePixelDev( comp, some_scores, block_mean, score_dev, min_score, max_score, edge_sum, width)
%Enhanced PCA reconstruction using background knowledge
%
% Reconstruct an image (that was broken into 8x8 blocks) from all PCA 
% components, the first n scores, the abolute deviation of each score,
% and the sum of the absolute differences between the edge pixels (that is,
% when adjacent pixels a,b are from different blocks, take the absolute
% value of their difference and add it to the sum)
%
% comp - the pca components returned by princomp
% some_scores - the scores of the first n components extracted from the
%              scores matrix returned by princomp
% block_mean - the mean of all the 8x8 blocks
% score_dev - score_dev(i) is the sum of absolute deviation (sum of abs(x-mean))
%             of the i'th column in the original scores matrix. Since the
%             first several scores are known, their deviations are ignored.
%             Must be 64x1 column vector
% min_score - the minimum score in the original scores matrix
% max_score - the maximum score in the original scores matrix
% edge_sum - The intensity of edges that correspond with block boundaries.
%            Shouldn't be very large.
%            for all pairs of adjacent pixels that are from different 
%            blocks (a,b), sum=sum+abs(a-b);
% width - the width of the image being reconstructed in pixels
%
% Works by finding the missing scores as a feasible point that matches all
% the constraints: the components are as given, the absolute deviations of
% the scores are as given, the edge intensities are as given, and pixel
% values are in the range 0..255

input_components = size(some_scores,2); % Number of components whose scores were used as input
total_components = 64;
box_side_size = 8;
pixels_per_box = box_side_size*box_side_size;

%%%%%%%%%%%%%%%%%%
%
% Input error checking
%
%%%%%%%%%%%%%%%%%%

assert(input_components <= size(comp, 2)); % Can't use more components than there are
assert(round(input_components) == input_components); % input_components must be an integer
assert(size(comp,1) == 64 && size(comp,2) == 64); % Components matrix is 64x64
assert(mod(width,8) == 0); % Width must be a multiple of 8
assert(size(score, 1) >= width/8); % There must be at least one full row
assert(mod(size(score,1)*64,width) == 0); % There must be an integral number of rows
assert(length(block_mean) == 64); % Should be mean of one block
assert(size(score_dev,1) == 64 && size(score_dev,2) == 1); % score_dev is 64x1 column vector
assert(all(score_dev >= 0)); % Absolute deviation 
assert(edge_sum >= 0);
assert(isscalar(edge_sum));
assert(isscalar(min_score));
assert(isscalar(max_score));

%%%%%%%%%%%%%%%%%%
%
% Create miscellaneous utility variables
%
%%%%%%%%%%%%%%%%%%

% bock_num(i,j) is the index of the row containing block i,j in the scores
% variable. This is done in row-major order.
block_num = zeros(n_box_h, n_box_v);
for row=1:n_box_v
    block_num(:,row) = 1+(row-1)*n_box_h:row*n_box_h;
end

% Extract basic image and input attributes
height = size(score,1)*pixels_per_box/width;
n_box_h = width/box_side_size; % num boxes in horizontal direction
n_box_v = height/box_side_size; % num boxes in vertical direction
n_boxes = size(score,1);

%%%%%%%%%%%%%%%%%%
%
% Choose variable locations in optimization matrices
%
%%%%%%%%%%%%%%%%%%


% Set up the indices at which different variables are found in the final
% linear program arrays
%
% Unless otherwise noted, 2D coordinates like box offsets are given as 
% horizontal, vertical pairs.

% There is one variable containing the final value of each pixel ... they
% will be limited to 0..255. loc_pixel(i,j,x,y) gives the index of the
% variable containing the intensity at offset x,y (both 1..8) in box i,j.

num_pixels = width*height;
loc_pixel = reshape(1:num_pixels, n_box_h, n_box_v, 8, 8);
last_pixel_var = num_pixels;

% There is one variable for each unknown element of the scores array. For
% ease of indexing, I also make locations for the elements of the scores
% array that were given as input and set those locations to nan. 
%
% loc_score(i,j,q) is the location of the variable containing the score of 
% the q'th component in the box at i,j.
num_scores = n_boxes*(total_components-input_components);
loc_score = nan(n_box_h, n_box_v, total_components);
loc_score(:,:,input_components+1:total_components) = reshape( ...
    last_pixel_var+1:last_pixel_var+num_scores, n_box_h, n_box_v, ...
    total_components-input_components);
last_score_var = last_pixel_var+num_scores;


% There is one variable for the mean score of each unknown element of the
% scores array. For ease of indexing, I make locations for the input scores
% and just set these locations to nan.
%
% loc_mean_score(q) is the location of the variable containing the mean of
% the scores of the q'th component
num_mean_scores = total_components-input_components;
loc_mean_score = nan(total_components,1);
loc_mean_score(input_components+1:total_components,1) = reshape(...
    last_score_var+1:last_score_var+num_mean_scores, num_mean_scores, 1);
last_mean_score_var = last_score_var+num_mean_scores;

% There are two variables for the calculated absolute deviation of each
% unknown score, calc_dev_abs_plus will be non-zero if the deviation value
% is positive and calc_dev_abs_minus will be non-zero if the deviation
% value is negative. The deviation value is calc_dev_abs_plus -
% calc_dev_abs_minus and their sum is the absolute value of the deviation.
% As usual, locations for components whose scores were included in the 
% input are stored but set to nan to make indexing easier.
%
% loc_calc_dev_abs_plus(q,i,j) is location of the variable containing the 
% absolute value of the difference of the i,j'th box's score on the q'th 
% component from the mean score for the q'th component when that 
% difference is positive.
%
% loc_calc_dev_abs_minus(q,i,j) is the location of the variable like
% calc_dev_abs_plus, but when the difference is negative. At the optimum,
% only one of these two variables will be positive, the other will be 0.

num_calc_dev = num_scores;
loc_calc_dev_abs_plus = nan(total_components, n_box_h, n_box_v);
loc_calc_dev_abs_minus = nan(total_components, n_box_h, n_box_v);
loc_calc_dev_abs_plus(input_components+1:total_components, :, :) = ...
    reshape(last_mean_score_var+1:2:last_mean_score_var+2*num_calc_dev, ...
    num_calc_dev, n_box_h, n_box_v);
loc_calc_dev_abs_minus(input_components+1:total_components, :, :) = ...
    reshape(last_mean_score_var+2:2:last_mean_score_var+2*num_calc_dev, ...
    num_calc_dev, n_box_h, n_box_v);
last_calc_dev = last_mean_score_var+2*num_calc_dev;

% There are two variables for the absolute values of the difference between
% pixels on the right edge of one block and the left edge of another, as
% with calc_dev_abs_plus and _minus, right_edge_diff_plus and _minus are
% both non-negative and at the optimum, equal to the absolute value of the
% difference or to 0 and at least one is always 0.
%
% loc_right_edge_diff_plus(i,j,y) is the absolute value of the difference
% between the pixel on the right edge of block i,j and the pixel on the
% left edge of block i+1,j when the difference is positive
%
% loc_right_edge_diff_minus(i,j,y) is the absolute value of the difference
% when it is negative.
%
% Note: i goes 1..n_box_h-1 because the rightmost row doesn't have pixels
% adjacent to it

num_right_edge_diff = box_side_size*(n_box_h-1)*(n_box_v);
loc_right_edge_diff_plus = reshape(...
    last_calc_dev+1:2:last_calc_dev+2*num_right_edge_diff, n_box_h-1, ...
    n_box_v, box_side_size);
loc_right_edge_diff_minus = reshape(...
    last_calc_dev+2:2:last_calc_dev+2*num_right_edge_diff, n_box_h-1, ...
    n_box_v, box_side_size);
last_right_edge_diff = last_calc_dev+2*num_right_edge_diff;

% There are two variables for the absolute values of the difference between
% pixels on the bottom edge of one block and the top edge of another, as
% with calc_dev_abs_plus and _minus, bot_edge_diff_plus and _minus are
% both non-negative and at the optimum, equal to the absolute value of the
% difference or to 0 and at least one is always 0.
%
% loc_bot_edge_diff_plus(i,j,y) is the absolute value of the difference
% between the pixel on the bottom edge of block i,j and the pixel on the
% left edge of block i,j+1 when the difference is positive
%
% loc_bot_edge_diff_minus(i,j,y) is the absolute value of the difference
% when it is negative.
%
% Note: j goes 1..n_box_v-1 because the bottom row doesn't have pixels
% adjacnt to it

num_bot_edge_diff = box_side_size*n_box_h*(n_box_v-1);
loc_bot_edge_diff_plus = reshape(...
    last_calc_dev+1:2:last_calc_dev+2*num_bot_edge_diff, n_box_h, ...
    n_box_v-1, box_side_size);
loc_bot_edge_diff_minus = reshape(...
    last_calc_dev+2:2:last_calc_dev+2*num_bot_edge_diff, n_box_h, ...
    n_box_v-1, box_side_size);
last_bot_edge_diff = last_calc_dev+2*num_bot_edge_diff;



num_vars = last_bot_edge_diff;


%%%%%%%%%%%%%%%%%%
%
% Set up constants
%
%%%%%%%%%%%%%%%%%%

% score_const(i,j,q) is the score q'th component score for the i,j'th block
% where q=1..input_components
score_const = nan(n_box_h, n_box_v, input_components);
for i=1:n_box_h
    for j=1:n_box_v
        score_const(i,j,:) = some_scores(block_num(i,j),:);
    end
end


% mean_block2d(x,y) is the intensity of the mean block at coordinate x,y
mean_block2d = nan(box_side_size, box_side_size);
i=0;
for y=1:box_side_size
    for x=1:box_side_size
        mean_block2d(x,y)=mean_block(i);
        i=i+1;
    end
end

%%%%%%%%%%%%%%%%%%
% Set up the linear program
%%%%%%%%%%%%%%%%%%

% First, the objective function - just minimize the sum of the absolute 
% value components so that in the optima, they truly represent the absolute
% value.

f=zeros(num_vars,1);
f(reshape(loc_bottom_edge_diff_plus,[],1))=1;
f(reshape(loc_bottom_edge_diff_minus,[],1))=1;
f(reshape(loc_right_edge_diff_plus,[],1))=1;
f(reshape(loc_right_edge_diff_minus,[],1))=1;
f(reshape(loc_calc_dev_abs_plus(input_components+1:total_components, ...
    :, :), [],1))=1;
f(reshape(loc_calc_dev_abs_minus(input_components+1:total_components, ...
    :, :), [],1))=1;

% Set up empty equality constraint matrices
Aeq=[]; beq=[];

% Now add the constraint that the pixel values are the sum of
% the appropriate components scaled by the scores
Aeq=[Aeq;zeros(width*height,num_vars)];
beq=[beq;zeros(width*height,1)];

% First, set up the constant part of the pixel value
blocks = some_scores*comp(:,1:input_components)'+repmat(block_mean,size(some_scores,1),1);
constant_px=zeros(n_box_h, n_box_v, box_side_size, box_side_size);
for i=1:n_box_h
    for j=1:n_box_v
        constant_px(i,j,:,:)= ...
            reshape(blocks(block_num(i,j),:),box_side_size,box_side_size)';
    end
end

clear blocks;
clear constant_px;

% Now, encode the equation
% pixel(i,j,x,y)=const(i,j,x,y)+sum(comp(:,x,y).*score(i,j,:))
% Or (as it is actually written):
% pixel(i,j,x,y)-sum(comp(:,x,y).*score(i,j,:))=const(i,j,x,y)

%TODO

end