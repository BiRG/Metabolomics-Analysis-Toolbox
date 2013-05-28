function exercise_hist_simplify(num)
% Does procedures for HistogramDistribution simplification using a reduced
% dataset for profiling
%
% num is the number of original bins to use
% 
if ~exist('num','var')
    num = 100;
end
raw_orig_width = nssd_data_dist('width');
mins = [raw_orig_width.min];
maxes = [raw_orig_width.max];
orig_width_dist = HistogramDistribution.fromEqualProbBins(...
    mins(1:num), maxes(1:num));
orig_width_7bin = orig_width_dist.rebinApproxEqualProb(7);

end

