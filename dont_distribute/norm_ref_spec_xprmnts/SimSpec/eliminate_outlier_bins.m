function inlier_bins = eliminate_outlier_bins( binned_collections, target_sum, use_spectrum, use_bin, outlier_iqr)
% Returns only those bins that have quotients that are not extreme outliers in some collection
%
% The spectra in use_spectra are the ones used for creating the reference
% spectrum. The bins in use_bin are the ones whose quotients with the
% reference spectrum are used to determine the quotient for the spectrum.
% Only the bins in use_bin are considered when looking at the distribution
% from which outliers are determined.
%
% If fewer than two spectra are provided, all used bins from use_bin are 
% also inlier bins.
%
% If fewer than two bins are selected, they are all counted as inlier bins
% and returned. 
%
% -------------------------------------------------------------------------
% Input arguments
% -------------------------------------------------------------------------
% 
% binned_collections  - a cell array of spectral collections. Each spectral
%                       collection is a struct. This is the format of the
%                       return value of load_collections.m in
%                       common_scripts.
%
%                       The y values in this collection are the sum of y
%                       values in some other collection to avoid problems
%                       with noise and peak shifts.
%
%                       All these collections must use the same
%                       set of x values. Check with only_one_x_in.m.
%
% target_sum          - the target sum for the sum normalization carried
%                       out before the main quotients are calculated.
%
% use_spectrum        - a cell array of logical arrays. use_spectrum{i}(j) 
%                       is true iff the j-th spectrum in the i-th 
%                       collection should be used in calculating the 
%                       median.
% 
% use_bin             - array of logical. use_bin(i) is true iff the bin 
%                       at index i is used in calculating quotients for 
%                       determining the normalization coefficient. use_bin
%                       must have the same number of columns as
%                       binnec_collections{j}.x for all j.
%
% outlier_iqr         - scalar. The multiple of the iqr to use in detecting
%                       outliers. A value is an outlier if it is
%                       outlier_iqr * iqr beyond the nearest quartile.
%
% -------------------------------------------------------------------------
% Output parameters
% -------------------------------------------------------------------------
% 
% inlier_bins - an array of logical, just like use_bin, except that
%               inlier_bins(i) is true iff use_bin(i) is true and the
%               quotient for the i-th bin was not an extreme outlier in any
%               spectrum
%
% -------------------------------------------------------------------------
% Examples
% -------------------------------------------------------------------------
%
% >> cols{1}.x = 1:7;
% >> cols{1}.Y=[2,1,0.4;1,0.5,0.2;10,5,200000;20,40,60;10,5,2;1,0.5,0.2;3,1.5,0.6];
% >> cols{2} = cols{1};
% >> cols{2}.Y=[2,5;1,1;10,21;20,39;10,21;1,1;3,5];
% >> cols{2}.original_multiplied_by = [1,2];
% >> use_spectra = {[true, true, true],[true, true]};
% >> use_bins    = [true, true, true, false, true, true, true];
% >> inlier_bins = eliminate_outlier_bins(cols, 47, use_spectra, use_bins, 3);
% 
% inlier_bins =
% 
%      1     1     0     1     1     1     1
%
% -------------------------------------------------------------------------
% Authors
% -------------------------------------------------------------------------
%
% Eric Moyer (May 2012) eric_moyer@yahoo.com
%

%Ensure that use_bin is a row vector (if it is a vector -- which it ought to be)
if size(use_bin,1) > 1
    use_bin = use_bin';
end

% Set inliers to the input bins - the default
inlier_bins = use_bin;

% Treat the case where there will be no outliers since the median spectrum
% will be the original since there is only one. Also treat the worse case
% where no spectra were passed.
if num_spectra_in(binned_collections) < 2
    return;
else mark_end_line_covered=1; %#ok<NASGU>
end 

% Treat the special case where we should not eliminate any bins (because
% there is only 1 bin, or worse, no bins)
if sum(inlier_bins) < 2
    return;
else mark_end_line_covered=1; %#ok<NASGU>
end 

% Preprocess
binned_collections = sum_normalize( binned_collections, target_sum );

ref_spec = median_spectrum( binned_collections, use_spectrum );

with_quotients = set_quotients_field( binned_collections, ref_spec );

% Each pass through the loop recalculate the iqrs and remove the 
% extreme outliers. Stop when there are no outliers or when
% you can't remove the outliers without running out of bins.
scaled_quotients = zeros(length(inlier_bins),num_spectra_in(with_quotients)); % Preallocate scaled_quotients
while true
    already_removed = ~inlier_bins;
    
    % Flatten the quotients field and scale the quotients to the iqr for their
    % spectrum
    first_empty = 1;
    for col = 1:length(with_quotients)
        num_samples =  size(with_quotients{col}.Y,2);
        last_used = first_empty + num_samples - 1;
        scaled_quotients(:, first_empty:last_used) = quotient_outlyingness(with_quotients{col}.quotients, inlier_bins);
    end

    % Select bins to remove as remove bins those over outlier_iqr iqr away from the
    % nearest quartile
    to_remove = any(abs(scaled_quotients) > outlier_iqr,2);
    to_remove = to_remove' & ~already_removed;

    % Break out of the loop if we didn't remove anything this pass or if
    % removing what is left would leave us with no bins. Otherwise update
    % handles
    if ~any(to_remove)
        break
    else mark_end_line_covered=1; %#ok<NASGU>
    end 
    new_use_bin = inlier_bins & ~to_remove;
    if ~any(new_use_bin)
        break;
    else
        inlier_bins = new_use_bin;
    end
end


end

