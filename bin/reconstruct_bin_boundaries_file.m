function chosen=reconstruct_bin_boundaries_file( original_collection_filename, binned_collection_filename, reconstructed_bin_boundaries_filename )
% Reads an original collection and its binned version generated by DAB and reconstructs the bin boundaries that were used to generated the binned copy
% 
% It assumes that the binning did not involve any deconvolution and cannot
% restore any names that were attached to bins (the name fields are left
% blank).
%
% Usage: reconstruct_bin_boundaries_file( original_collection_filename, binned_collection_filename, reconstructed_bin_boundaries_filename )
% -------------------------------------------------------------------------
% Input arguments
% -------------------------------------------------------------------------
%
% original_collection_filename - 
%     the name of the text file from which to read the original collection.
%     Must be suitable for loading with load_collection. The x values must
%     be monotonic increasing or decreasing.
%
% binned_collection_filename -
%     the name of the text file from which to read the binned collection.
%     Must be suitable for loading with load_collection. Must have been
%     generated by DAB (that is, the bin x values must be the bin centers).
%
% reconstructed_bin_boundaries_filename -
%     the file that will hold the reconstructed bin boundaries. Will be
%     overwritten. Will be suitable for loading with the "Load bins" button
%     in the dynamic adaptive binning application "Results" tab.
%
% -------------------------------------------------------------------------
% Output parameters
% -------------------------------------------------------------------------
% 
% chosen -
%    a cell array. Each entry is a 2 element vector giving the computed
%    bounds for the selected bin.
%
% -------------------------------------------------------------------------
% Examples
% -------------------------------------------------------------------------
%
% >> reconstruct_bin_boundaries_file( 'foo', 'foo.binned', 'foo.bounds');
% Reads a collection from foo and one from foo.binned, reconstructs the
% boundaries that generated foo.binned from foo and writes them to
% 'foo.bounds'
%
% -------------------------------------------------------------------------
% Authors
% -------------------------------------------------------------------------
%
% Paul Anderson ????
% Eric Moyer 2012 (eric_moyer@yahoo.com)

orig_col = load_collection(original_collection_filename,'');
if ~isstruct(orig_col)
    error('bin_reconstruct_bin_boundaries:no_load',...
        'Could not load collection from %s', original_collection_filename);
end
binned_col = load_collection(binned_collection_filename,'');
if ~isstruct(binned_col)
    error('bin_reconstruct_bin_boundaries:no_load',...
        'Could not load collection from %s', binned_collection_filename);
end

if size(orig_col.Y, 2) ~= size(binned_col.Y, 2)
    error('bin_reconstruct_bin_boundaries:diff_num_samples',...
        ['The binned and original collections have different numbers of '...
        'spectra, thus they are not related only by binning.']);
end


% Generate candidate pairs for each bin center
wait_h = waitbar(0,'Phase 1 of 2: Select bin boundaries consistent with known bin centers (Phase 1 of 2)');
orig_x = orig_col.x;
binned_x = binned_col.x;

if ~(issorted(orig_x) || issorted(fliplr(orig_x)))
    error('bin_reconstruct_bin_boundaries:not_sorted',...
        'The x values in %s are not sorted.', original_collection_filename);
end

num_pairs = length(orig_x)*(length(orig_x)-1)/2;
candidates = cell(size(binned_x));
rounding_factor = 128;  % Use a fixed point integer representation with 3.6
                         % decimal places for "rounded" values.
                         % This rounding takes care of the loss of
                         % precision that occurs when reading/writing
                         % floating point values from/to a text file.
                         %
                         % I chose 3.6 decimal places because that would
                         % take care of the error in one example I looked
                         % at.
rounded_binned_x = round(binned_x * rounding_factor); 
for idx1=1:length(orig_x)
    num_pairs_remaining = (length(orig_x)-idx1+1)*(length(orig_x)-idx1)/2;
    frac_done = 1 - num_pairs_remaining/num_pairs;
    waitbar(frac_done, wait_h);
    
    coord_1 = orig_x(idx1);
    idx2 = idx1:length(orig_x);
    centers = (coord_1 + orig_x(idx2)) / 2;
    rounded_centers = round(centers * rounding_factor);
    potential_bin_indices = find(rounded_binned_x <= max(rounded_centers) & rounded_binned_x >= min(rounded_centers));
    for i = 1:length(potential_bin_indices)
        bin_idx = potential_bin_indices(i);
        matches = rounded_binned_x(bin_idx) == rounded_centers;
        if any(matches)
            candidates{bin_idx} = horzcat(candidates{bin_idx}, ...
                [repmat(idx1,1,sum(matches)); ...
                idx2(matches); ...
                centers(matches)] ...
                );
        end
    end
end

num_candidates = cellfun(@(x) size(x,1), candidates);
if any(num_candidates == 0)
    error('bin_reconstruct_bin_boundaries:no_candidates',...
        ['No bin boundaries came close enough to giving a correct ' ...
        'bin center for %d bins. Try reducing the rounding factor ' ...
        'in the source code.'], sum(num_candidates));
end

% Choose those candidates with the minimum total error when their samples
% are summed over the bins. Ties are broken by max errors and then by
% closest bin center to the actual bin center.
waitbar(0, wait_h, 'Selecting the best candidate for each bin. (Phase 2 of 2)');
chosen = cell(size(candidates));
chosen_err = zeros(size(candidates));
y = orig_col.Y;
binned_y = binned_col.Y;
for bin_idx = 1:length(candidates)
    waitbar((bin_idx-1)/length(candidates), wait_h);
    expected_sums = binned_y(bin_idx, :);
    cur_cand = candidates{bin_idx};
    num_cand = size(cur_cand, 2);
    
    % Evaluate the error for each candidate
    max_err = zeros(1, num_cand); % max_err(i) is the maximum error in 
                                  % summation that would be incurred by
                                  % choosing candidate i
    total_err = zeros(1, num_cand); % total_err(i) is the sum of all the 
                                    % errors that would be incurred by
                                    % choosing candidate i
    for cand_idx = 1:num_cand
        % Get the starting and ending indices of the candidate bin in 
        % sorted order
        v = cur_cand(1:2, cand_idx);
        sort(v);
        a=v(1); b = v(2); assert(a <= b);
        % Exclude the lower endpoint for non-singleton bins
        if a < b; b = b-1; end; 
        % Find the contents of the candidate bin
        sums = sum(y(a:b, :));
        % Calculate the error statistics for the candidate 
        errs = abs(sums - expected_sums);
        max_err(1, cand_idx) = max(errs);
        total_err(1, cand_idx) = sum(errs);
    end
    center_err = abs(cur_cand(3, :) - binned_x(bin_idx));  % center_err(i)
                                      % is the distance of the calculated
                                      % center of candidate i from the
                                      % center location given in the
                                      % original file
    
    % Select the best candidate breaking ties by max error, center error
    % and finally by the first candidate in the list
    remaining = true(size(max_err));
    remaining = remaining & max_err == min(max_err(remaining));
    remaining = remaining & total_err == min(total_err(remaining));
    remaining = remaining & center_err == min(center_err(remaining));
    the_one = cur_cand(1:2, remaining);
    the_one = the_one(:,1); % We can do this because there was at least one candidate to begin with
    
    % Change the one remaining candidate from ppm into bin coordinates and
    % record its error
    the_one = orig_x(the_one);
    the_one = sort(the_one, 2, 'descend')';
    chosen{bin_idx} = the_one;
    chosen_err(bin_idx) = min(max_err);
end

% Write the file
file = fopen(reconstructed_bin_boundaries_filename,'w');
if file <= 0
    error('bin_reconstruct_bin_boundaries:no_candidates',...
        'Could not write output file %s', reconstructed_bin_boundaries_filename);
end
% First write the actual bin boundaries
for i=1:length(chosen)
    pr = chosen{i};
    if i > 1
        fprintf(file, ';%f,%f', pr);
    else
        fprintf(file, '%f,%f', pr);
    end
end
fprintf(file,'\n');
% Then write lines saying that all variables were defined by summation and
% that no names were given
assert(length(chosen) >= 1);
fprintf(file,['sum',repmat(';sum', 1, length(chosen)-1),'\n']);
fprintf(file,[repmat(';', 1, length(chosen)-1),'\n']);
fclose(file);

% Print a message to the user indicating magnitude of greatest error
err_bin = find(chosen_err == max(chosen_err));
err_bin = err_bin(1);
fprintf(['Reconstruction complete. The maximum summation error ' ...
    'encountered was %g in bin %d.\n'], max(chosen_err), err_bin);

% Get rid of the waitbar
close(wait_h);

end

