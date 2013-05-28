function exercise_hist_simplify()
% Does procedures for HistogramDistribution simplification using a reduced
% dataset for profiling
% 
raw_orig_width = nssd_data_dist('width');
mins = [raw_orig_width.min];
maxes = [raw_orig_width.max];
orig_width_dist = HistogramDistribution.fromEqualProbBins(...
    mins(1:50), maxes(1:50));
orig_width_7bin = orig_width_dist.rebinApproxEqualProb(7);

end

