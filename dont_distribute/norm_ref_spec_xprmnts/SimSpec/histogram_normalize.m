function [collections, multipliers] = histogram_normalize(collections, baseline_pts, n_std_dev, num_bins, use_waitbar, hist_method, hist_scale)
% Applies Torgrip's histogram normalization to the spectra 
%
% collections = HISTOGRAM_NORMALIZE(collections, baseline_pts, std_dev, num_bins, use_waitbar, hist_method)
%
% Uses the algorithm from "A note on normalization of biofluid 1D 1H-NMR
% data" by R. J. O. Torgrip, K. M. Aberg, E. Alm, I. Schuppe-Koistinen and
% J. Lindberg published in Metabolomics (2008) 4:114–121, 
% DOI 10.1007/s11306-007-0102-2
%
% To normalize nmr spectra.
%
% -------------------------------------------------------------------------
% Input arguments
% -------------------------------------------------------------------------
% 
% collections  - a cell array of spectral collections. Each spectral
%                collection is a struct. This is the format
%                of the return value of load_collections.m in
%                common_scripts. All collections must use the same set of x
%                values. Check with only_one_x_in.m
%
%                Special: if there is only one argument and this argument
%                is the string 'return subfunction handles for testing' 
%                the 'collections' variable returned will be a cell array
%                of function handles to the subfunctions so that they can be 
%                tested using xUnit. Which functions are returned should 
%                be of no concern to the user, though xUnit should check 
%                this list as one of its tests using func2str.
%
% baseline_pts - the number of points to use at the beginning of each
%                spectrum to estimate the standard deviation of the noise.
%                Must be at least 2.
%
% n_std_dev    - all samples less than n_std_dev * noise_standard_deviation
%                are ignored in creating the histogram. Must be
%                non-negative.
%
% num_bins     - the number of bins to use in the histogram. Must be at
%                least 1
%
% use_waitbar  - if true then a waitbar is displayed during processing.
%                Must be a logical.
%
% hist_method  - (optional) must be 'logarithmic' (the method from the
%                original paper) or 'equal frequency'. 
%
%                If equal frequency, the bin boundaries are set using 
%                the equal_frequency_histogram_boundaries routine. See
%                algorithm description there.
%
% hist_scale   - (optional) must be 'count' or 'fraction of total'.
%
%                'count' - the histogram bins contain the number of 
%                elements that fell into that bin - this is the method from 
%                the original paper and the default if the parameter 
%                is omitted.
%
%                'fraction of total' - the histogram bins contain the
%                number of elements that fell into that bin divided by the
%                total number of elements that could have fallen into any
%                bins - this may help if some spectra had an especially low
%                SNR and noise removal removed many of the points that
%                found their way into the median spectrum)
%
% -------------------------------------------------------------------------
% Output parameters
% -------------------------------------------------------------------------
% 
% collections - the collections after normalization. The processing log is
%               updated and the histograms are all multiplied by their
%               respective dilution factors.
%
% multipliers - cell array of the dilution factors appropriate for passing
%               to multiply_collections to scale the input collections to
%               match the output collections
%
% -------------------------------------------------------------------------
% Examples
% -------------------------------------------------------------------------
%
% >> collections = HISTOGRAM_NORMALIZE(collections, 30, 5, 60, true)
%
% Uses histogram normalization on the spectra in collections. It creates
% an estimate of the noise standard deviation from the first 30 points in 
% each spectrum. Then it excludes all points in a spectrum that have an 
% intensity less than 5 standard deviations above 0. Finally it bins
% the intensities into 60 bins and uses a waitbar to report progress to 
% the user.
%
% -------------------------------------------------------------------------
% Authors
% -------------------------------------------------------------------------
%
% Eric Moyer (May-July 2012) eric_moyer@yahoo.com
%

% I set these as constants so misspellings will not be a problem later in
% the code.
hist_method_log_string = 'logarithmic';
hist_method_equ_string = 'equal frequency';

hist_scale_count_string = 'count';
hist_scale_frac_string = 'fraction of total';



function expurgated = remove_values(values, baseline_pts, n_std_dev)
    % Return an array of the entries in values that were strictly more than 
    % n_std_dev standard deviations above 0. The size of one standard
    % deviation is calcualted from the first baseline_pts entries in
    % values. 
    %
    % values must have at least baseline_pts entries.
    %
    % baseline_pts must be a scalar
    %
    % n_std_dev must be a scalar
    
    assert(length(values) >= baseline_pts,'remove_values:enough_baseline',...
        'Not enough values for %d baseline points', baseline_pts);
    dev = std(values(1:baseline_pts));
    expurgated = values(values > n_std_dev*dev);
end

function err_v = err(mult, values, y_bins, ref_histogram)
    % Returns the sum of squared differences between the histogram of 
    % values*mult using y_bins and ref_histogram.
    if ~isempty(values)
        h = histc_inclusive(mult.*values, y_bins, 1);
    else
        h = zeros(size(ref_histogram));
    end
    diffs = h-ref_histogram;
    err_v = sum(diffs.^2);
end

function err_v = err_scaled(mult, values, y_bins, ref_histogram, scale_factor)
    % Returns the sum of squared differences between the histogram of 
    % values*mult using y_bins and ref_histogram. The histogram of
    % values*mult is multiplied by scale_factor before doing the
    % comparison.
    h = histc_inclusive(mult.*values, y_bins);
    diffs = (h.*scale_factor)-ref_histogram;
    err_v = sum(diffs.^2);
end


function [low_b, up_b] = mult_search_bounds_for(values, y_bins, ref_histogram, min_y, max_y)
    % Return possibly improved lower and upper search bounds for
    % best_mult_for
    %
    % min_y and max_y are the minimum and maximum values in the reference
    % spectrum.
    %
    % Let min_v and max_v be the min and max values in the values array. 
    % Then the current implementationStarts with bounds of min_y/max_v and 
    % max_y/min_v. These initial bounds are the most conservative
    % multipliers - they bring at least one value in the values list into
    % the range [min_y,max_y]. Then the routine steps in powers of 2 and 
    % chooses the power of 2 interval that had minimum error when binned.
    %
    % Assumes 0 < min_y <= max_y
    
    assert(0 < min_y, 'mult_search_bounds_for:pos_min_y', ...
        'min_y parameter must be strictly positive');
    assert(min_y <= max_y, 'mult_search_bounds_for:min_at_most_max', ...
        'min_y must be no larger than max_y');
    
    % Initialize the search bounds to (min_y/max_v) and (max_y/min_v).
    min_v = min(values);
    max_v = max(values);
    low_b = min_y/max_v;
    up_b  = max_y/min_v;
    
    % Now, tighten the search bounds because fminbnd does not do well
    % searching for optima when there are large flat spaces in the upper
    % part of the search range (probably in the lower part as well).
    
    % Make a list of the errors at multipliers low_b, low_b*2,
    % low_b * 4 ... first_element_in_this_series_greater_than_up_b
    num_steps = ceil(log2(up_b/low_b));
    bound_mults = low_b.*(2.^(0:num_steps));
    errs = arrayfun(@(m) err(m, values, y_bins, ref_histogram), ...
        bound_mults);
    
    % Get the indices of the two elements that bound the first interval of minimum error
    min_err_idx = find(errs == min(errs),1,'first');
    low_b_idx = find(errs(1:min_err_idx-1) > errs(min_err_idx),1,'last');
    if isempty(low_b_idx)
        % All previous elements equal to the minimum - or there were no
        % previous elements
        low_b_idx = 1;
    end
    up_b_idx = find(errs(min_err_idx+1:end) > errs(min_err_idx),1,'first');
    if isempty(up_b_idx)
        up_b_idx = length(errs);
    else
        up_b_idx = up_b_idx + min_err_idx;
    end

	% Make those two elements the new search bounds if they are tighter
    if bound_mults(up_b_idx) < up_b
        up_b = bound_mults(up_b_idx);
    end
    if bound_mults(low_b_idx) > low_b
        low_b = bound_mults(low_b_idx);
    end
end

function mult = best_mult_for(values, y_bins, ref_histogram, min_y, max_y, hist_scale)
    % Return the multiplier that minimizes the sum of squared differences
    % between the histogram of values*mult using y_bins and ref_histogram.
    %
    %
    % if hist_scale is hist_scale_count_string or if there are no entries
    % in the values array, the value of the new histogram is left alone
    % before comparing it to ref_histogram. 
    % Otherwise, it is divided by the length of values.
    %
    % The search looks at all values between (min_y/max(values) and
    % (max_y/min(values)). 0 <= min_y <= max_y & 0 < min(values)
    
    [low_b, up_b]=mult_search_bounds_for(values, y_bins, ref_histogram, min_y, max_y);
    
    if strcmpi(hist_scale, hist_scale_count_string) || isempty(values)
        mult = fminbnd(@(mult) err(mult, values, y_bins, ref_histogram), ...
           low_b , up_b);
    elseif strcmpi(hist_scale, hist_scale_frac_string)
        scale_factor = 1/length(values);
        mult = fminbnd(@(mult) err_scaled(mult, values, y_bins, ...
            ref_histogram, scale_factor), ...
            low_b , up_b);
    else
        error('histogram_normalize___best_mult_for:bad_hist_scale', ...
            ['The value of hist_scale passed to '...
            'histogram_normalize/best_mult_for was ''%s'', which is '...
            'not one of the recognized values.'], hist_scale);
    end
       
end

function counts = histc_inclusive(vector, bins, dim)
    % Like histc except that the last count includes values == bins(end)
    %
    % All of the bins from the histc command are open intervals - count of
    % values in the range a <= x < b. Then the last bin returned is the count
    % of the values exactly equal to b. This command returns the values in
    % histc except with the modification that the next to last bin is the 
    % values in the range a <= x <= b and the last bin is 0.

    if exist('dim','var')
        counts = histc(vector, bins, dim);
    else
        counts = histc(vector, bins);
    end

    if length(counts) >= 2
        counts(end-1) = counts(end-1) + counts(end);
        counts(end) = 0;
    end
end


% Special behavior supporting unit testing of sub-functions
if nargin == 1 && ischar(collections) && ...
        strcmpi(collections, 'return subfunction handles for testing')
    collections = {@remove_values, @err, @best_mult_for, ...
        @mult_search_bounds_for, @histc_inclusive};
    return;
end

if baseline_pts < 2
    error('histogram_normalize:two_baseline',['You must use at least '...
        'two baseline points to estimate the noise standard deviation.']);
end

if num_bins < 1
    error('histogram_normalize:one_bin',['You must use at least '...
        'one histogram bin in histogram normalization.']);
end

if n_std_dev < 0
    error('histogram_normalize:nonneg_std',['n_std_dev '...
        'parameter cannot be negative.']);
end

if use_waitbar; 
    wait_h = waitbar(0,'Initializing histogram normalization'); 
else
    wait_h = -1;
end


if ~exist('hist_method','var')
    hist_method = hist_method_log_string;
end

if ~exist('hist_scale', 'var')
    hist_scale = hist_scale_count_string;
end

if ~strcmpi(hist_scale, hist_scale_count_string) && ...
        ~strcmpi(hist_scale, hist_scale_frac_string)
    error('histogram_normalize:bad_hist_scale',['The hist_scale value '...
        'passed to histogram_normalize was not one of the allowed ' ...
        'values. See documentation.']);
end

% Calculate the reference spectrum
all_spectra = cellfun(@(in) true(in.num_samples,1), collections, 'UniformOutput', false);
ref_spectrum = median_spectrum(collections, all_spectra);
ref_values = remove_values(ref_spectrum.Y, baseline_pts, n_std_dev);

% Calculate the y-values we will histogram y{i} is the values remaining 
% from the i'th spectrum, where the first spectrum is collection{1}.Y(:,1)
% and you continue increasing the spectrum number until you run out of
% spectra in the collection, at which point, you go through the spectra in
% the next collection.
y=cell(num_spectra_in(collections), 1);
cur = 1;
for c=1:length(collections)
    if use_waitbar; waitbar(0.1*(c-1)/length(collections),...
            wait_h, 'Removing baseline points'); end
    for s=1:collections{c}.num_samples
        y{cur}=remove_values(collections{c}.Y(:,s), ...
            baseline_pts, n_std_dev);
        cur=cur+1;
    end
end

% Calculate histogram edges.
min_y = min(ref_values); % Calculate the bounds of the histogram based on the reference spectrum
max_y = max(ref_values);
if strcmpi(hist_method, hist_method_log_string)
    % Note that rather than taking the log(y+1) each
    % iteration, I move the histogram edges according to the inverse of this
    % function. edge=2^edge-1. This means that we are not translating the y
    % values anymore (I'd have to change this if I wanted to use the fourier
    % autocorrelation trick, for example) but we are only doing multiplications
    % each time through the main optimization loop - and multiplications are
    % faster than additions for floating point.
    assert(min_y > 0);
    assert(max_y >= min_y);
    min_z = log2(min_y+1); %z values are those transformed into logarithmic space
    max_z = log2(max_y+1); 
    z_bins = linspace(min_z, max_z, num_bins+1);
    y_bins = (2.^z_bins)-1;
elseif strcmpi(hist_method, hist_method_equ_string)
    y_bins = equal_frequency_histogram_boundaries(ref_values, num_bins);
else
    error('histogram_normalize:bad_hist_method',['The method passed to '...
        'histogram normalize must be either ''%s'' or ''%s''. Instead ' ...
        '''%s'' was passed.'],  hist_method_equ_string,  ...
        hist_method_log_string, hist_method);
end

% Calculate the multipliers
ref_histogram = histc_inclusive(ref_values, y_bins);
if strcmpi(hist_scale, hist_scale_frac_string)
    ref_histogram = ref_histogram ./ length(ref_values);
end

multipliers = zeros(length(y), 1);
for cur = 1:length(y)
    if use_waitbar
        waitbar(0.1+0.85*(cur-1)/length(y), wait_h, 'Calcuating multipliers'); 
    end

    multipliers(cur)=best_mult_for(y{cur}, y_bins, ref_histogram, min_y, max_y, hist_scale);
end

% Scale the spectra
collections = ensure_original_multiplied_by_field(collections);
cur = 1;
for c=1:length(collections)
    if use_waitbar
        waitbar(0.95+0.05*(c-1)/length(collections), wait_h, 'Scaling spectra'); 
    end
    if ~isfield(collections{c}, 'processing_log')
        collections{c}.processing_log = '';
    end
    collections{c}.processing_log = sprintf([...
        '%s  Histogram normalized with %d bins using the first ' ...
        '%d points for a noise estimate and excluding points with an ' ...
        'intensity less than %g noise standard deviations above 0.'], ...
        collections{c}.processing_log, num_bins, baseline_pts, n_std_dev);
    for s=1:collections{c}.num_samples
        collections{c}.Y(:,s)=multipliers(cur)*collections{c}.Y(:,s);
        collections{c}.original_multiplied_by(s)=...
            multipliers(cur)*collections{c}.original_multiplied_by(s);
        cur = cur + 1;
    end
end

% Reformat the multipliers array into a cell array
multipliers_cells = cell(size(collections));
cur = 1;
for c=1:length(collections)
    cur_size = size(collections{c}.Y,2);
    multipliers_cells{c} = multipliers(cur : cur+cur_size-1);
    cur = cur + cur_size;
end
multipliers = multipliers_cells;

if use_waitbar; delete(wait_h); end;


end