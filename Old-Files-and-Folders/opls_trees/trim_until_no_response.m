function sel_bins = trim_until_no_response(labels,bin_data,sel_bins,mult,talpha,num_perm,fold)
min_num_features = 2;
try
cut_inx = round(length(sel_bins)*mult);
old_sel_bins = sel_bins;
sel_bins = old_sel_bins(cut_inx:end);
num_perm_orig = num_perm;
num_perm = 20;
if 20*talpha < 1
    perm_needed = 1;
else
    perm_needed = round(20*talpha);
end;

if length(sel_bins) > min_num_features
    response = is_responding_ix(labels,bin_data,sel_bins,talpha,num_perm,fold,perm_needed);
    % Look for a no response. If we can't find a response, then return
    % sel_bins = []
    while response && length(sel_bins) > min_num_features
        mult = mult + (1 - mult)/2;
        cut_inx = round(length(old_sel_bins)*mult);
        sel_bins = old_sel_bins(cut_inx:end);
        if length(sel_bins) > min_num_features
            response = is_responding_ix(labels,bin_data,sel_bins,talpha,num_perm,fold,perm_needed);
        end
    end
    if response
        sel_bins = [];
        return;
    end
    
    % Found no response, now we have to look for response. This should be
    % guranteed because we started with a response.
    % Reset the multiplier to the previous point with a response, and then
    % update the end multiplier
    prev_mult = 2*mult - 1;
    end_mult = mult;
    mult = prev_mult;
    response = true;
    while response && length(sel_bins) > min_num_features
        mult = mult + (end_mult - mult)/2;
        cut_inx = round(length(old_sel_bins)*mult);
        sel_bins = old_sel_bins(cut_inx:end);
        if length(sel_bins) > min_num_features
            response = is_responding_ix(labels,bin_data,sel_bins,talpha,num_perm,fold,perm_needed);
        end
    end
    if response % Something wrong
        sel_bins = 0;
        return;
    end
    % Now we found a no response that is in the neighborhood
    % Now add one at a time until we get a response
    num_perm = num_perm_orig;
    perm_needed = round(num_perm*talpha);
    response = is_responding_ix(labels,bin_data,sel_bins,talpha,num_perm,fold,perm_needed);
    if(~response) 
        while ~response && length(sel_bins) > min_num_features
            cut_inx = cut_inx - 1;
            if cut_inx < 1 % Something went wrong
                sel_bins = 0;
                return;
            end
            sel_bins = old_sel_bins(cut_inx:end);
            if length(sel_bins) > min_num_features
                response = is_responding_ix(labels,bin_data,sel_bins,talpha,num_perm,fold,perm_needed);
            end
        end
        if response
            cut_inx = cut_inx + 1; % Go back to previous
            sel_bins = old_sel_bins(cut_inx:end);
            return;
        else
            sel_bins = 0;
            return;
        end
    else
        while response && length(sel_bins) > min_num_features
            cut_inx = cut_inx + 1;
            if cut_inx < 1 % Something went wrong
                sel_bins = 0;
                return;
            end
            sel_bins = old_sel_bins(cut_inx:end);
            if length(sel_bins) > min_num_features
                response = is_responding_ix(labels,bin_data,sel_bins,talpha,num_perm,fold,perm_needed);
            end
        end
        if ~response
            cut_inx = cut_inx - 1; % Go back to previous
            sel_bins = old_sel_bins(cut_inx:end);
            return;
        else
            sel_bins = 0;
            return;
        end
    end
else
    sel_bins = []; % Ran out of bins to try
end
catch ME
    ME
end