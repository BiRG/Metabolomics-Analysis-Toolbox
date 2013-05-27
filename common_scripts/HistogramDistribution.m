classdef HistogramDistribution
    % Represents 1D probability distribution where the real line is divided
    % up into mutually-exclusive discrete bins each with a fixed probability
    % 
    % Parameters are the bin boundaries and the probabilities for each bin
    
    properties (SetAccess=private)
        % Along with border_is_in_upper_bin, represents a partition of a 1D
        % segment into intervals (which I call bins). bounds holds the
        % sorted boundaries of the intervals. Two adjacent boundaries can
        % be equal if there is a zero-length interval (which can have a
        % probability if it contains a Dirac delta).
        %
        % Since bounds represents a partition, no more than 2 adjacent
        % boundaries can be equal - each point can belong to exactly
        % one bin.
        %
        % bounds(end) is the maximum of the partitioned segment and
        % bounds(1) is the minimum. These are also the minimum and maximum
        % bounds values respectively.
        %
        % (row vector)
        bounds
        
        % probs(i) is the probability of the generated value lying in bin
        % whose lower boundary is i. length(probs) == length(bounds)-1.
        % 0 <= probs(i) <= 1 and sum(probs) == 1
        %
        % (row vector)
        probs
        
        % cdf(i) is sum(probs(1:i)
        %
        % (row vector)
        cdf
        
        % border_is_in_upper_bin(i) true means that the bin with boundaries 
        % bounds(i) and bounds(i+1) contains the point bounds(i). Otherwise
        % the point bounds(i) is contained in the bin 
        % bounds(i-1) .. bounds(i).
        %
        % A few relations hold:
        %
        % First and last bins have no lower and upper neighbors, and so must 
        % contain their lower and upper endpoints
        %
        % border_is_in_upper_bin(1) == true; 
        %
        % border_is_in_upper_bin(end) == false
        %
        % A zero-length bin must contain both its endpoints
        % border_is_in_upper_bin(bounds(1:end-1)==bounds(2:end), false) == true
        % border_is_in_upper_bin(false, bounds(1:end-1)==bounds(2:end)) == false
        %
        % (row vector of logical)
        border_is_in_upper_bin;
    end
    
    properties (Dependent)
    end
    
    methods(Static)
        function obj=fromEqualProbBins(mins, maxes)
        % Usage: obj=HistogramDistribution.fromEqualProbBins(mins, maxes)
        %
        % Factory method that creates a HistogramDistribution from a set of
        % bins each having an equal probability. The bins are treated as
        % either uniform distribution or (for zero-width bins) Dirac delta
        % functions. The end-point behavior of the bins is not kept except 
        % for Dirac deltas (which must be a closed interval). Instead the
        % function produces default end-point behavior of the constructor
        % when no border_is_in_upper_bin parameter is passed
        %
        % The interval [ mins(i), maxes(i) ] represents one bin with a
        % probability of 1/length(mins)
        %
        % -------------------------------------------------------------------------
        % Input arguments
        % -------------------------------------------------------------------------
        % 
        % mins -  (row vector of double) mins(i) is the minimum value of
        %      the i'th bin. Must be the same length as maxes. There must
        %      be at least 1 bin. maxes(i) >= mins(i)
        %
        % maxes - (row vector of double) maxes(i) is the maximum value of
        %      the i'th bin. Must be the same length as mins. There must be
        %      at least 1 bin. maxes(i) >= mins(i)
        %
        % -------------------------------------------------------------------------
        % Output parameters
        % -------------------------------------------------------------------------
        % 
        % obj - A HistogramDistribution having the same distribution as the
        %      input bins (except possibly at endpoints).
        %
        % -------------------------------------------------------------------------
        % Examples
        % -------------------------------------------------------------------------
        %
        % Single bin non-dirac
        % >> o = HistogramDistribution.fromEqualProbBins(0,1)
        %
        % o.bounds == [0 1]
        %
        % o.probs = 1
        %
        % o.cdf = 1
        %
        % o.border_is_in_upper_bin = [1 0]
        %
        % Single dirac bin
        % >> o = HistogramDistribution.fromEqualProbBins(1,1)
        %
        % o.bounds == [1 1]
        %
        % o.probs = 1
        %
        % o.cdf = 1
        %
        % o.border_is_in_upper_bin = [1 0]
        %
        % Two identical bins non-dirac
        % >> o = HistogramDistribution.fromEqualProbBins([1,1],[5,5])
        %
        % o.bounds == [1 5]
        %
        % o.probs = 1
        %
        % o.cdf = 1
        %
        % o.border_is_in_upper_bin = [1 0]
        %
        % Two identical dirac bins
        % >> o = HistogramDistribution.fromEqualProbBins([0,0],[0,0])
        %
        % o.bounds == [0 0]
        %
        % o.probs = 1
        %
        % o.cdf = 1
        %
        % o.border_is_in_upper_bin = [1 0]
        %
        % Two different non-overlapping bins 
        % >> o = HistogramDistribution.fromEqualProbBins([1,3],[2,5])
        %
        % o.bounds == [1 2 3 5]
        %
        % o.probs = [0.5 0 0.5]
        %
        % o.cdf = [0.5 0.5 1]
        %
        % o.border_is_in_upper_bin = [1 1 1 0]
        %
        % Two different overlapping bins 
        % >> o = HistogramDistribution.fromEqualProbBins([1,2],[3,6])
        % o.bounds == [1 2 3 6]
        %
        % o.probs = [0.25 0.375 0.375]
        %
        % o.cdf = [0.25 0.625 1]
        %
        % o.border_is_in_upper_bin = [1 1 1 0]
        %
        % Two different overlapping one fully contained
        % >> o = HistogramDistribution.fromEqualProbBins([1,2],[9,3])
        % o.bounds == [1 2 3 9]
        % o.probs = [0.0625 0.5625 0.375]
        %
        % o.cdf = [0.0625 0.625 1]
        %
        % o.border_is_in_upper_bin = [1 1 1 0]
        %
        % Two different one dirac dirac fully contained
        % >> o = HistogramDistribution.fromEqualProbBins([1,2],[9,2])
        % o.bounds == [1 2 2 9]
        % o.probs = [0.0625 0.5 0.4375]
        %
        % o.cdf = [0.0625 0.5625 1]
        %
        % o.border_is_in_upper_bin = [1 1 0 0]
        %
        % Two different one dirac dirac below lower
        % >> o = HistogramDistribution.fromEqualProbBins([1,0],[9,0])
        % o.bounds == [0 0 1 9]
        % o.probs = [0.5 0 0.5]
        %
        % o.cdf = [0.5 0.5 1]
        %
        % o.border_is_in_upper_bin = [1 0 1 0]
        %
        % Two different one dirac dirac at lower
        % >> o = HistogramDistribution.fromEqualProbBins([1,1],[9,1])
        % o.bounds == [1 1 9]
        % o.probs = [0.5 0.5]
        %
        % o.cdf = [0.5 1]
        %
        % o.border_is_in_upper_bin = [1 0 0]
        %
        % Two different one dirac dirac at upper
        % >> o = HistogramDistribution.fromEqualProbBins([1,9],[9,9])
        % o.bounds == [1 9 9]
        % o.probs = [0.5 0.5]
        %
        % o.cdf = [0.5 1]
        %
        % o.border_is_in_upper_bin = [1 1 0]
        %
        % Two different one dirac dirac above upper
        % >> o = HistogramDistribution.fromEqualProbBins([1,10],[9,10])
        % o.bounds == [1 9 10 10]
        % o.probs = [0.5 0 0.5]
        %
        % o.cdf = [0.5 0.5 1]
        %
        % o.border_is_in_upper_bin = [1 1 1 0]
        %
        % Two different both dirac
        % >> o = HistogramDistribution.fromEqualProbBins([1,10],[1,10])
        % o.bounds == [1 1 10 10]
        % o.probs = [0.5 0 0.5]
        %
        % o.cdf = [0.5 0.5 1]
        %
        % o.border_is_in_upper_bin = [1 0 1 0]
        %
        % Four different bins first dirac
        % >> o = HistogramDistribution.fromEqualProbBins([1,1,3,5],[1,3,5,9])
        % o.bounds == [1 1 3 5 9]
        % o.probs = [0.25 0.25 0.25 0.25]
        %
        % o.cdf = [0.25 0.5 0.75 1]
        %
        % o.border_is_in_upper_bin = [1 0 1 1 0]
        %
        % Four different bins first two identical dirac
        % >> o = HistogramDistribution.fromEqualProbBins([1,1,1,5],[1,1,5,9])
        % o.bounds == [1 1 5 9]
        % o.probs = [0.5 0.25 0.25]
        %
        % o.cdf = [0.5 0.75 1]
        %
        % o.border_is_in_upper_bin = [1 0 1 0]
        
        if length(mins) ~= length(maxes)
            error('HistogramDistribution:mins_maxes_same_length',['The '...
                'mins and maxes parameters to fromEqualProbBins must '...
                'be the same length']);
        end
        if isempty(mins)
            error('HistogramDistribution:at_least_one_bin',['The '...
                'distribution passed to HistogramDistribution must have '...
                'at least one bin.']);
        end
        if ~all(maxes >= mins)
            error('HistogramDistribution:maxes_greater',['Each '...
                'bin minimum must be at least as small as its '...
                'corresponding maximum.']);
        end
        
        % Set up the bounds to be the list of all entries that were the
        % upper or lower boundary of some bin plus all dirac entry bounds
        % (to repeat them)
        bounds = unique([maxes,mins],'R2012a'); %#ok<PROP>
        dirac_bounds = unique(maxes(maxes == mins),'R2012a');
        bounds = sort([bounds, dirac_bounds]); %#ok<PROP>
        
        % Turn the original bins into intervals
        orig_intervals = arrayfun(@Interval,mins, maxes, true(1,length(mins)), true(1,length(mins)), 'UniformOutput',false);
        orig_intervals = [orig_intervals{:}];
        
        % Calculate the probablility mass assigned to each original bin
        interval_mass = 1/length(mins);
        
        % To get the actual bins of the new distribution, calculate a
        % HistogramDistribution with the same bounds but equal
        % probabilities
        equal_prob_distr = HistogramDistribution(bounds, ones(1,length(bounds)-1)./(length(bounds)-1)); %#ok<PROP>
        new_bins = Interval(bounds(1:end-1),bounds(2:end), ...
            equal_prob_distr.border_is_in_upper_bin(1:end-1), ...
            ~equal_prob_distr.border_is_in_upper_bin(2:end)); %#ok<PROP>
        
        % For each new bin, calculate the contribution of each original
        % bin to its probability
        probs = zeros(1,length(bounds)-1); %#ok<PROP>
        for bin_idx = 1:length(probs) %#ok<PROP>
            bin = new_bins(bin_idx);
            for orig_idx = 1:length(orig_intervals)
                orig = orig_intervals(orig_idx);
                if bin.intersects(orig)
                    if orig.length > 0
                        intersection = bin.intersection(orig);
                        probs(bin_idx) = probs(bin_idx) + interval_mass*intersection.length()/orig.length(); %#ok<PROP>
                    else
                        probs(bin_idx) = probs(bin_idx) + interval_mass; %#ok<PROP>
                    end
                end
            end
        end
        
        % Create the object using the normal constructor
        obj = HistogramDistribution(bounds, probs); %#ok<PROP>
        
        end
    end
    
    methods
        function objs=HistogramDistribution(bounds, probs, border_is_in_upper_bin)
        % Usage: objs=HistogramDistribution(bounds, probs, border_is_in_upper_bin)
        % Usage: objs=HistogramDistribution(bounds, probs)
        %
        % Creates a HistogramDistribution with the given bin boundaries and
        % probabilities. See bounds, probs, and border_is_in_upper_bin for 
        % description of the inputs. border_is_in_upper_bin is optional
        %
        % When border_is_in_upper_bin is omitted, it is assumed that 
        % border_is_in_upper_bin is always true unless restricted by the 
        % relations given under border_is_in_upper_bin. This is equivalent 
        % to assuming that for a bin not next to a dirac delta bin or an 
        % endpoint, the bin will be a half-open interval
        % [ bounds(i), bounds(i+1) )
        %
        % The border_is_in_upper_bin parameter can be specified as a vector
        % of 1's (for true) and 0's (for false) rather than as a vector of
        % logical variables.
        % 
        % ----------------------------------------------------------------
        % Examples
        % ---------------------------------------------------------------
        %
        % >> o = HistogramDistribution([0,1,1,2,3,5],[1,2,1,2,2]./8,[1,1,0,1,0,0])
        %
        % Creates a HistogramDistribution with the members:
        %
        % bounds = [0,1,1,2,3,5]
        %
        % probs = [1,2,1,2,2]/.8 = [0.125,0.25,0.125,0.25,0.25]
        %
        % cdf = [0.125, 0.375, 0.5, 0.75, 1]
        %
        % border_is_in_upper_bin = [1,1,0,1,0,0]
        %
        % This corresponds to the probabilities on the intervals:
        %
        % [0,1) - 1/8
        % [1,1] - 1/4
        % (1,2) - 1/8
        % [2,3] - 1/4
        % (3,5] - 1/4
        %
        % >> o = HistogramDistribution([0,1,1,2,3,5],[1,2,1,2,2]/.8)
        %
        % Creates a HistogramDistribution with the members:
        %
        % bounds = [0,1,1,2,3,5]
        %
        % probs = [1,2,1,2,2]/.8 = [0.125,0.25,0.125,0.25,0.25]
        %
        % cdf = [0.125, 0.375, 0.5, 0.75, 1]
        %
        % border_is_in_upper_bin = [1,1,0,1,1,0]
        %
        % This corresponds to the probabilities on the intervals:
        %
        % [0,1) - 1/8
        % [1,1] - 1/4
        % (1,2) - 1/8
        % [2,3) - 1/4
        % [3,5] - 1/4
        %
        % The following are errors
        %
        % >> o = HistogramDistribution([0,1,1,2,3,5],[1,2,1,2,2]./8,[1,1,1,1,0,0])
        % Dirac interval must be contain its upper bound - HistogramDistribution:invalid_borders
        %
        % >> o = HistogramDistribution([0,1,1,2,3,5],[1,2,1,2,2]./8,[1,0,0,1,0,0])
        % Dirac interval must be contain its lower bound - HistogramDistribution:invalid_borders
        %
        % >> o = HistogramDistribution([0,1,1,2,3,5],[1,2,1,2,2]./8,[1,1,0,1,0,1])
        % There is no bin above the last - HistogramDistribution:invalid_borders
        %
        % >> o = HistogramDistribution([0,1,1,2,3,5],[1,2,1,2,2]./8,[0,1,0,1,0,0])
        % There is no bin below the first - HistogramDistribution:invalid_borders
        %
        % >> o = HistogramDistribution([0,1,1,2,3,5],[1,2,1,2,3]./8)
        % The probabilities don't sum to 1. Assertion failure.
        %
        % >> o = HistogramDistribution([0,1,1,2,3,5],[1,2,1,2,1,1]./8)
        % There are more probabilities than bins. Assertion failure.
        %
        % >> o = HistogramDistribution([0,1,1,2,3,5],[1,2,1,4]./8)
        % There are fewer probabilities than bins. Assertion failure.
        %
        % >> o = HistogramDistribution([0,1,1,2,3,5],[-1,3,1,2,2]./8)
        % The probabilities must all be non-negative. Assertion failure.
        %
        % >> o = HistogramDistribution([2,1,1,2,3,5],[1,2,1,2,2]./8)
        % The bin boundaries are not sorted. Assertion failure
        %
        % >> o = HistogramDistribution([0],[])
        % There must be at least 1 bin (two bin boundaries). Assertion falulre.
        
        
          if nargin > 0
            assert(nargin == 2 || nargin == 3);
            assert(isrow(bounds));
            assert(isrow(probs));
            assert(abs(1-sum(probs)) < 1e-6); % sum of probs is approximately 1
            assert(all(probs >= 0));
            assert(length(probs) == length(bounds) - 1);
            assert(~isempty(probs)); % There must be at least 1 bin
            assert(issorted(bounds));
            objs.bounds = bounds;
            objs.probs = probs;
            objs.cdf = cumsum(probs);
            min_of_delta_bin = [bounds(1:end-1)==bounds(2:end), false];
            max_of_delta_bin = [false, bounds(1:end-1)==bounds(2:end)];
            if(nargin < 3)
                objs.border_is_in_upper_bin = true(size(bounds));
                objs.border_is_in_upper_bin(end) = false;
                objs.border_is_in_upper_bin(max_of_delta_bin) = false;
            else
                if ~islogical(border_is_in_upper_bin)
                    border_is_in_upper_bin = border_is_in_upper_bin ~= 0;
                end
                if ~border_is_in_upper_bin(1) || ...
                        border_is_in_upper_bin(end) ||...
                        ~all(border_is_in_upper_bin(min_of_delta_bin)) || ...
                        any(border_is_in_upper_bin(max_of_delta_bin))
                    error('HistogramDistribution:invalid_borders',...
                        ['The border_is_in_upper_bin value passed to ' ...
                        'the HistogramDistribution constructor is ' ...
                        'not consistent with the borders being a ' ...
                        'partition. See border_is_in_upper_bin ' ...
                        'description.']);
                end
                objs.border_is_in_upper_bin = border_is_in_upper_bin;
            end
          end
        end

        function p = probOfInterval(objs, intervals)
        % Usage: p = probOfInterval(objs, intervals)
        %
        % Returns the probability of the given intervals in the given 
        % histogram distributions.
        %
        % If there are the same number of intervals and histogram objects,
        % each interval is measured under its corresponding histogram. If
        % there is only one 
        %
        % -------------------------------------------------------------------------
        % Input arguments
        % -------------------------------------------------------------------------
        % 
        % objs - (row vector of HistogramDistribution) the distributions
        %      under which the probability is measured. There can either be
        %      1 or the same number as the number of intervals.
        %
        % interval - (row vector of Interval objects) the intervals whose
        %      probability is measured. There can either be 1 or the same
        %      number as the number of objs.
        %
        % -------------------------------------------------------------------------
        % Output parameters
        % -------------------------------------------------------------------------
        % 
        % p - (row vector of double) p(i) is the probability of interval
        %      under o(i)
        %
        % -------------------------------------------------------------------------
        % Examples
        % -------------------------------------------------------------------------
        %
        % >> h = HistogramDistribution([0,1,1,2,3],[0.25 0.25 0.25 0.25]);
        % >> i = HistogramDistribution([0,1,1,2,3,9],[0.2 0.2 0.2 0.2 0.2]);
        % >> hi = [h,i];
        %
        % >> p = h.probOfInterval(Interval(0,1.5,false,false))
        %
        % p == 0.625
        %
        % >> p = h.probOfInterval(Interval(1,1.5,true,true))
        % 
        % p == 0.375
        %
        % >> p = h.probOfInterval(Interval(1,1.5,false,true))
        %
        % p == 0.125
        %
        % >> p = i.probOfInterval(Interval(1,1.5,false,true))
        %
        % p == 0.1
        %
        % >> p = hi.probOfInterval(Interval(1,1.5,false,true))
        %
        % p == [0.125, 0.1]
        %
        % >> p = hi.probOfInterval(Interval([0 1],[1 1.5],[false false],[true true]))
        %
        % p == [0.625, 0.1]
        %
        % >> p = h.probOfInterval(Interval([0 1],[1 1.5],[false false],[true true]))
        %
        % p == [0.625, 0.125]
        %
        % >> p = hi.probOfInterval(Interval([0 1 2],[1 1.5 3]))
        %
        % Error: 'HistogramDistribution_probOfInterval:input_shape'
            if length(objs) == 1 && length(intervals) == 1
                bins = Interval(objs.bounds(1:end-1),objs.bounds(2:end), ...
                    objs.border_is_in_upper_bin(1:end-1), ...
                    ~objs.border_is_in_upper_bin(2:end));
                p = 0;
                intersects = bins.intersects(intervals);
                for bin_idx = find(intersects) % Loop only over those bins where there is an intersection
                    b = bins(bin_idx);
                    prob = objs.probs(bin_idx);
                    if b.length == 0
                        p = p+prob;
                    else
                        intersection = b.intersection(intervals);
                        p = p+prob * intersection.length / b.length;
                    end
                end
            elseif length(objs) == length(intervals)
                p = arrayfun(@(o,i) o.probOfInterval(i), objs, intervals);
            elseif length(objs) == 1
                p = arrayfun(@(i) objs.probOfInterval(i), intervals);
            elseif length(intervals) == 1
                p = arrayfun(@(o) o.probOfInterval(intervals), objs);
            else
                error('HistogramDistribution_probOfInterval:input_shape',...
                    ['If there are different numbers of Intervals and '...
                    'HistogramDistributions, one of vector must be size 1.']);
            end
        end
        
        function new_dists = rebinApproxEqualProb(objs, num_bins)
        % Return a HistogramDistribution where a given interval has the
        % same probability as this one but the bins have approximately
        % equal probabilities
        %
        % Usage: newDist = rebinApproxEqualProb(objs, num_bins)
        %
        % When there is exactly one object and number of bins, proceeds
        % from the first bin making the probability of each bin as close as
        % possible to prob_remaining/bins_remaining (the presence of Dirac
        % delta bins can make having the exact probability impossible.)
        %
        % When there is one object or one num_bins, it is repeated to match
        % the size of the other parameter.
        %
        % When there are an equal number of entries for objs and num_bins,
        % bins each object according to its corresponding number of bins.
        %
        % -------------------------------------------------------------------------
        % Input arguments
        % -------------------------------------------------------------------------
        % 
        % objs - (row vector of HistogramDistribution) There can either be
        %      1 or the same number as num_bins
        %
        % num_bins - (row vector of integers) The number of bins in the new
        %      HistogramDistribution There can either be 1 or the same
        %      number as the number of objs.
        %
        % -------------------------------------------------------------------------
        % Output parameters
        % -------------------------------------------------------------------------
        % 
        % new_dists - (row vector of HistogramDistribution) new_dists(i) is
        %      the rebinned version of objs(i)
        %
        % -------------------------------------------------------------------------
        % Examples
        % -------------------------------------------------------------------------
        %
        % >> h = HistogramDistribution([0,1,1,2,3],[0.25 0.25 0.25 0.25]);
        % >> i = HistogramDistribution([0,1,1,2,3,5],[0.2 0.2 0.2 0.2 0.2]);
        % >> hi = [h,i];
        %
        % >> n = h.rebinApproxEqualProb(4)
        %
        % n == h
        %
        % >> n = h.rebinApproxEqualProb(5)
        %
        % n == HistogramDistribution([0, 0.8,1,5/3,7/3,3],[0.2 0.3 1/6 1/6 1/6],[1,1,0,1,1,0]);
        %
        % >> n = i.rebinApproxEqualProb(5)
        %
        % n == i
        %
        % >> n = i.rebinApproxEqualProb(4)
        %
        % n == HistogramDistribution([0,1,4/3,8/3,5],[3/15 4/15 4/15 4/15])
        %
        % >> n = hi.rebinApproxEqualProb(4)
        %
        % n == [h, HistogramDistribution([0,1,4/3,8/3,5],[3/15 4/15 4/15 4/15])]
        %
        % >> n = hi.rebinApproxEqualProb(4,5)
        %
        % n == hi
        %
            if length(objs) == 1 && length(num_bins) == 1
                if num_bins < 1
                    error('HistogramDistribution_rebin:at_least_one', ...
                        ['A HistogramDistribution must have at least ' ...
                        'one bin so num_bins passed to '...
                        'rebinApproxEqualProb must be at least 1']);
                end
                if num_bins ~= round(num_bins)
                    error('HistogramDistribution_rebin:integer_bins', ...
                        'num_bins must be an integer.');
                end
                remaining_prob = 1;
                remaining_bins = num_bins;
                target_prob = remaining_prob / remaining_bins;
                new_bins(num_bins) = Interval();
                cur_bin_idx = 1;
                cur_bound_idx = 1;
                cur_bin = Interval(objs.bounds(cur_bound_idx),objs.bounds(cur_bound_idx),true,true);
                cur_prob = objs.probOfInterval(cur_bin);
                while(remaining_bins > 0)
                    accept_cur_bin = false;
                    if cur_prob >= target_prob
                        % If we can't improve the probability by extending
                        % the bin, add this bin to the list and start 
                        % making a new one
                        accept_cur_bin = true;
                    else
                        assert(cur_prob < target_prob);
                        % If we are below the target probability, try to
                        % extend the bin. If the expansion doesn't exceed
                        % the target probability, continue. Otherwise, the
                        % current bin is the closest you can get without
                        % overshooting and the extended one is the closest
                        % you can get above. Choose the one whose
                        % probability is closer to the target and add it to
                        % the list.
                        extended_bin = objs.private_extendInterval(cur_bin, target_prob);
                        extended_prob = objs.probOfInterval(extended_bin);
                        if extended_prob <= target_prob
                            cur_bin = extended_bin;
                            cur_prob = extended_prob;
                        else
                            if extended_prob - target_prob < target_prob - cur_prob
                                cur_bin = extended_bin;
                                cur_prob = extended_prob;
                            end
                            accept_cur_bin = true;
                        end
                    end
                    if accept_cur_bin
                        % Add the bin to the list and update all the state
                        % variables
                        new_bins(cur_bin_idx) = cur_bin;
                        cur_bin_idx = cur_bin_idx + 1;
                        remaining_bins = remaining_bins - 1;
                        remaining_prob = remaining_prob - target_prob;
                        if remaining_bins > 0
                            target_prob = remaining_prob / remaining_bins;
                        else
                            target_prob = 0;
                        end
                        cur_bin = Interval(cur_bin.max, cur_bin.max, ~cur_bin.contains_max, ~cur_bin.contains_max);
                        cur_prob = objs.probForInterval(cur_bin);
                    end
                end
                
                % Turn the list of bins into a histogram distribution
                final_bin = new_bins(end);
                new_bins(end) = Interval(final_bin.min, final_bin.max, ...
                    final_bin.contains_min, true);  % Ensure the last bin is contains its maximum to meet the requirements of HistogramDistribution objects
                all_but_first_bin = new_bins(2:end);
                new_dists = HistogramDistribution(...
                    [[new_bins.min], final_bin.max], ...
                    objs.probForInterval(new_bins), ...
                    [true,[all_but_first_bin.contains_min],false]);
            elseif length(objs) == length(num_bins)
                new_dists = arrayfun(@(o,n) o.rebinApproxEqualProb(n), objs, num_bins);
            elseif length(objs) == 1
                new_dists = arrayfun(@(n) objs.rebinApproxEqualProb(n), num_bins);
            elseif length(num_bins) == 1
                new_dists = arrayfun(@(o) o.rebinApproxEqualProb(num_bins), objs);
            else
                error('HistogramDistribution_rebinApproxEqualProb:input_shape',...
                    ['If there are different numbers of bin quantities and '...
                    'HistogramDistributions, one of vector must be size 1.']);
            end
        end
        
        function str=char(obj)
        % Return a human-readable string representation of this
        % object. (Matlab's version of toString, however, Matlab
        % doesn't call it automatically)
            function strs = to_strs(nums,format)
            % Convert a numeric array to a cell array of strings using the
            % given fprintf format
                strs = arrayfun(@(x) num2str(x,format), nums, 'UniformOutput',false);
            end
          if length(obj) == 1
              str = ['HistogramDistribution([', ...
                  strjoin(to_strs(obj.bounds,'%g'),', '), '], [', ...
                  strjoin(to_strs(obj.probs,'%g'),', '), '], [', ...
                  strjoin(to_strs(obj.border_is_in_upper_bin,'%d'), ', '), '])'];
          else
              str = ['[ ', strjoin(...
                  arrayfun(@(x) x.char(), obj, ...
                      'UniformOutput',false), ...
                  ', '), ...
                  ' ]'];
          end
        end
	    
        function display(obj)
        % Display this object to a console. (Called by Matlab
        % whenever an object of this class is assigned to a
        % variable without a semicolon to suppress the display).
            disp(obj.char);
        end
        
        function new_interval = private_extendInterval(obj, interval, target_prob)
        % Usage: private_extendInterval(obj, interval, target_prob)
        %
        % Non-class members should not call this function. It is public so
        % I can write test code to call it. But the private_ prefix should
        % give a clue as to my intentions
        %
        % Changes the upper bound of the given interval by 1 step to try
        % and meet target_prob.
        %
        % If the interval is open at the top, closes it.
        % If the interval is closed at the top and there is a greater 
        %    boundary, opens it and changes the interval's boundary to 
        %    either:
        %   fall between its current value and the next greater boundary
        %      (if that would make its integral equal target probability)
        %
        %   fall on the next greater boundary
        %      (if no intervening value would make its integral equal to
        %      the target probability)
        %
        % Otherwise, does nothing
        % -------------------------------------------------------------------------
        % Input arguments
        % -------------------------------------------------------------------------
        % 
        % objs - (a HistogramDistribution object)
        %
        % interval - (an Interval object) the interval to be extended
        %
        % target_prob - (a double) The probability the extension is trying
        %      to achieve. must be between 0 and 1 inclusive.
        %
        % -------------------------------------------------------------------------
        % Output parameters
        % -------------------------------------------------------------------------
        % 
        % new_interval - (an Interval object) the extended interval
        %
        % -------------------------------------------------------------------------
        % Examples
        % -------------------------------------------------------------------------
        %
        % >> h = HistogramDistribution([2,3,5,8,8],0.25*ones(1,4),[1,1,1,1,0]);
        % >> i = h.private_extendInterval(Interval(5,8,false,false),0.3);
        % i == Interval(5,8,false,true)
        %
        % >> i = h.private_extendInterval(Interval(5,8,false,false),0.25);
        % i == Interval(5,8,false,true)
        %
        % >> i = h.private_extendInterval(Interval(5,8,false,true),0.25);
        % i == Interval(5,8,false,true)
        %
        % >> i = h.private_extendInterval(Interval(3,5,false,true),0.2); 
        % i == Interval(3,8,false,false) % Note that the target probability
        %                                % was ignored here since it could
        %                                % not be met in the interval
        %
        % >> i = h.private_extendInterval(Interval(3,5,false,true),0.375); 
        % i == Interval(3,6.25,false,false)
        %
        % >> i = h.private_extendInterval(Interval(3,5,false,false),0.375); 
        % i == Interval(3,5,false,true)
        %
        % >> i = h.private_extendInterval(Interval(3,5,false,true),0.6); 
        % i == Interval(3,8,false,false)
        
            %TODO: stub
            new_interval = interval;
        end
    end
    
end

