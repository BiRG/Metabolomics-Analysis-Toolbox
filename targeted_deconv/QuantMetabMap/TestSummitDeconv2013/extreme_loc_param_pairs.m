function extreme = extreme_loc_param_pairs(results, loc_param_errs)
% Return set of 3 deconvolutions with extreme values of location and/or parameter error values ready for plotting
% Usage: extreme = extreme_param_vals(results, loc_param_errs)
%
% The plot is made on the current axes.
%
% -------------------------------------------------------------------------
% Input parameters
% -------------------------------------------------------------------------
%
% results - (array of ExpDatum) The array from which the 
%     loc_param_errs objects were made.
%
% loc_param_errs - (array of struct) A subset of the result of running
%     peak_loc_vs_param_errs on results
%
% -------------------------------------------------------------------------
% Output parameters
% -------------------------------------------------------------------------
%
% extreme - (array of struct) extreme will have 3 entries each giving
%     details on one of the peaks that had the most extreme values for
%     initial peak location estimate and final parameter error. The fields
%     of extreme are chosen to make plotting and further exploration easy.
%
%     extreme(1) describes the peak with the minimum parameter error among
%          the peaks in the top 1% of initial peak location error
%
%     extreme(2) describes the peak with the maximum parameter error among
%          the peaks in the top 1% of initial peak location error
%
%     extreme(3) describes the peak with the maximum parameter error among
%          the peaks in the bottom 1% of initial peak location error
%        
%     The fields of extreme(i) are:
%
%          datum - the ExpDatum object where the peak resides
%
%          result_idx - the index of that datum object in the original
%               experimental results array passed to this function
%
%          deconv_idx - the index of the deconvolution where the peak
%               resides within datum.deconvolutions
%
%          deconv_peak_idx - the index of the peak object itself within
%               datum.deconvolutions(deconv_idx).peaks
%
% -------------------------------------------------------------------------
% Examples
% -------------------------------------------------------------------------
%
% 
% -------------------------------------------------------------------------
% Authors
% -------------------------------------------------------------------------
%
% Eric Moyer (eric_moyer@yahoo.com) May 2013

% Flatten the loc_param_errs struct array
loc_e = [loc_param_errs.peak_loc_error];
par_e = [loc_param_errs.param_error];

result_idxs = [loc_param_errs.result_idx];
deconv_idxs = [loc_param_errs.deconv_idx];
deconv_pk_idxs = [loc_param_errs.deconv_pk_idx];

% Find the flattened indices where the extreme values lie. 
is_top_loc_e = loc_e >= prctile(loc_e, 99);
is_bot_loc_e = loc_e <= prctile(loc_e,  1);

par_e_for_top_loc = par_e(is_top_loc_e);
par_e_for_bot_loc = par_e(is_bot_loc_e);

extreme_idx(1) = find(par_e == min(par_e_for_top_loc) & is_top_loc_e,1,'first');
extreme_idx(2) = find(par_e == max(par_e_for_top_loc) & is_top_loc_e,1,'first');
extreme_idx(3) = find(par_e == max(par_e_for_bot_loc) & is_bot_loc_e,1,'first');

% Fill the result array from the flattened indices
extreme(3) = struct('result_idx',[], 'datum',results(1), 'deconv_idx',[], ...
    'deconv_peak_idx',[]);
for i = 1:3
    e = extreme_idx(i);
    extreme(i).result_idx = result_idxs(e); 
    extreme(i).datum = results(extreme(i).result_idx); 
    extreme(i).deconv_idx = deconv_idxs(extreme_idx(i)); 
    extreme(i).deconv_peak_idx = deconv_pk_idxs(extreme_idx(i)); 
end
