function extreme = GLBIO2013_extreme_loc_param_pairs(results, loc_param_errs)
% Return set of 3 deconvolutions with extreme values of location and/or parameter error values ready for plotting
% Usage: extreme = GLBIO2013_extreme_param_vals(results, loc_param_errs)
%
% The plot is made on the current axes.
%
% -------------------------------------------------------------------------
% Input parameters
% -------------------------------------------------------------------------
%
% results - (array of GLBIO2013Datum) The array from which the 
%     loc_param_errs objects were made.
%
% loc_param_errs - (array of struct) A subset of the result of running
%     GLBIO2013_peak_loc_vs_param_errs on results
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


