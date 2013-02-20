function combined = combine_merging_probs( merge1, merge2 )
% Combine the output of two runs of probability_of_peak_mergine_in_random_spec into one struct as if there had been only one run
% Usage: combined = COMBINE_MERGING_PROBS( merge1, merge2 )
%
% merge1 - ouptut of probability_of_peak_mergine_in_random_spec. Must
%          have pairs of entries sharing the same mean_width, num_peaks,
%          and num_width attributes.
%
% merge2 - ouptut of probability_of_peak_mergine_in_random_spec.
%
% combined - the outputs combined as if there had been only one run - the
%            number of reps is summed as are the counts for every opair
%            that had the same num_peaks, num_widths, and mean_width values.
combined(1,min(length(merge1),length(merge2)))=struct('num_peaks', 0, 'num_widths', 0, 'width', 0, 'mean_width', 0, 'num_reps', 0, 'counts', 0);

% For each element of merge1, add it to the output and then add counts and
% reps from the matching elemends of merge2
dest = 1;
merge2_matches = false(length(merge2)); % merge2_matches(i) is true if merge2(i) has a match in merge1 and thus is already represented in the combined list
for i1 = 1:length(merge1)
    m1 = merge1(i1);
    combined(1,dest) = m1;
    for i2 = 1:length(merge2)
        m2 = merge2(i2);
        % If the current element of merge2 matches the current element of
        % merge1 and has not matched before, update the destination by
        % adding the num_reps and counts from merge2
        if m1.num_peaks == m2.num_peaks && m1.num_widths == m2.num_widths &&...
                m1.mean_width == m2.mean_width && ~merge2_matches(i2)
            assert(m1.width == m2.width);
            combined(1, dest).num_reps = combined(dest).num_reps + m2.num_reps;
            combined(1, dest).counts = combined(dest).counts + m2.counts;
            merge2_matches(i2) = true;
        end
    end
    dest = dest + 1;
end

% Paste on those elements that were unmatched
combined = [combined, merge2(~merge2_matches(i2))];

