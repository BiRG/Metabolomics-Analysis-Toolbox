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
        
        % bounds and border_is_in_upper_bin combined into one Interval
        % object per bin.
        %
        % (row vector of Interval)
        bins
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
        for orig_idx = 1:length(orig_intervals)
            orig = orig_intervals(orig_idx);
            possible_bins = equal_prob_distr.private_possiblyOverlappingBins(orig);
            for bin_idx = possible_bins
                bin = new_bins(bin_idx);
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
        
        function obj = fromPoints(points)
        % Takes a list of points and puts bin boundaries halfway between then uses the ML estimate of the probabilities of each bin
        %
        % The maximum and minimum of the distribution are taken directly
        % from the maximum and minimum of the points
        % -------------------------------------------------------------------------
        % Input arguments
        % -------------------------------------------------------------------------
        % 
        % points - (row vector of double) a list of finite double values
        %      whose empirical distribution will be approximated by a set
        %      of uniform distributions. Must have at least 1 point.
        %
        % -------------------------------------------------------------------------
        % Output parameters
        % -------------------------------------------------------------------------
        % 
        % obj - A HistogramDistribution with a uniform distribution around
        %      each input point
        %
        % -------------------------------------------------------------------------
        % Examples
        % -------------------------------------------------------------------------
        %
        % >> h = HistogramDistribution.fromPoints(1)
        % h == HistogramDistribution([1, 1], [1], [1, 0])
        %
        % >> h = HistogramDistribution.fromPoints([1 1])
        % h == HistogramDistribution([1, 1], [1], [1, 0])
        %
        % >> h = HistogramDistribution.fromPoints([[1 1 2.5 3.5 4.5])
        % h == HistogramDistribution([1, 1.75, 3, 4, 4.5], [0.4, 0.2, 0.2, 0.2], [1, 1, 1, 1, 0])
            assert(~isempty(points));
            
            bnd = unique(points,'R2012a');
            if length(bnd) > 1
                bnd = unique([bnd(1), (bnd(1:end-1)+bnd(2:end))/2, bnd(end)]);
            else
                bnd = [bnd bnd];
            end
            equal_prob = HistogramDistribution(bnd,ones(1,length(bnd)-1)/(length(bnd)-1));
            counts = equal_prob.binCounts(points);
            obj = HistogramDistribution(bnd,counts/sum(counts));
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
            objs.bins = Interval(bounds(1:end-1),bounds(2:end), ... 
                objs.border_is_in_upper_bin(1:end-1), ...
                ~objs.border_is_in_upper_bin(2:end));
          end
        end

        function bin_idxs = private_possiblyOverlappingBins(obj,interval)
        % Usage: bin_idxs = private_possiblyOverlappingBins(obj,interval)
        %
        % NOTE: this function is private. It should be used only by 
        % functions in HistogramDistribution. It is not part of the public
        % interface for the class. It is only technically public so I
        % can call it from test routines. Don't call it from client code.
        %
        % Return a list of the indices of the bins in obj that may overlap
        % interval. If a bin is not included in bin_idxs then it definitely
        % does not overlap interval. If a bin is included and it is not the
        % first and last index then it definitely does overlap. Otherwise
        % the first and last included bins must be checked separately if
        % necessary.
        %
        % -------------------------------------------------------------------------
        % Input arguments
        % -------------------------------------------------------------------------
        % 
        % objs - (a HistogramDistribution object) the distribution
        %      whose bins are checked for overlap.
        %
        % interval - (an Interval object) the intervals whose
        %      probability is measured. There can either be 1 or the same
        %      number as the number of objs.
        %
        % -------------------------------------------------------------------------
        % Output parameters
        % -------------------------------------------------------------------------
        % 
        % bin_idxs - (row vector of integer) an array of indexes into the
        %      array of bins. The first and last elements of this list may
        %      not overlap. The rest definitely overlap. All overlapping
        %      bins are included in this list
        %
        % -------------------------------------------------------------------------
        % Examples
        % -------------------------------------------------------------------------
        %
        % >> h = HistogramDistribution([1 3 6 12 24], ones(1,4)./4);
        % >> b = h.private_possiblyOverlappingBins(Interval(4,13,1,1));
        % b == [2,3,4]
        % >> b = h.private_possiblyOverlappingBins(Interval(3,12,0,0));
        % b == [2,3,4]
        % >> b = h.private_possiblyOverlappingBins(Interval(3,11,0,0));
        % b == [2,3]
        % >> h = HistogramDistribution([3 24 48], ones(1,4)./4);
        % >> b = h.private_possiblyOverlappingBins(Interval(4,13,1,1));
        % b == 1
        % >> b = h.private_possiblyOverlappingBins(Interval(0,1,0,0));
        % b == 1
        % >> b = h.private_possiblyOverlappingBins(Interval(56,72,0,0));
        % b == 2
            % Get the indices of the bins bounding those that can
            % overlap and force them into the actual range of bins
            first_bin_idx = obj.binContaining(interval.min);
            first_bin_idx = min(length(obj.bins), max(1, first_bin_idx));
            last_bin_idx = obj.binContaining(interval.max);
            last_bin_idx = max(1, min(length(obj.bins), last_bin_idx));
            assert(first_bin_idx <= last_bin_idx); % this should be guaranteed by the ordering of interval max and min

            bin_idxs = first_bin_idx:last_bin_idx;
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
                p = 0;
                
                ibins_idxs = objs.private_possiblyOverlappingBins(intervals);
                ibins = objs.bins(ibins_idxs);
                intersects = ibins.intersects(intervals);
                for bin_idx = ibins_idxs(intersects) % Loop only over those bins where there is an intersection
                    b = objs.bins(bin_idx);
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
        
        function bin_idx = binContaining(obj, value)
        % Usage: bin_idx = binContaining(obj, value)
        %
        % Returns the index of the bin containing value or 0 or 
        % length(bins)+1 if the value lies below the lowest border or above
        % the highest border respectively. There will be at most one bin 
        % since the bins are a partition of an interval of the real line.
        % -------------------------------------------------------------------------
        % Input arguments
        % -------------------------------------------------------------------------
        % 
        % objs - (a single HistogramDistribution) the distribution
        %      to be searched for appropriate bin.
        %
        % value - (a scalar) the value whose containing bin is searched for
        %
        % -------------------------------------------------------------------------
        % Output parameters
        % -------------------------------------------------------------------------
        % 
        % bin_idx - (an integer) if one bin contains value, then the index of
        %     that bin. If the bin is below the lowest boundary, 0.
        %     length(bins)+1 if it is above the highest boundary.
        %
        % -------------------------------------------------------------------------
        % Examples
        % -------------------------------------------------------------------------
        %
        % >> h = HistogramDistribution([1,2,2,4,6,10,16],0.2*ones(1,5))
        %
        % >> b = h.binContaining(-1);
        % b == 0;
        %
        % >> b = h.binContaining(1);
        % b == 1;
        %
        % >> b = h.binContaining(2);
        % b == 2;
        %
        % >> b = h.binContaining(3);
        % b == 3;
        %
        % >> b = h.binContaining(4);
        % b == 4;
        %
        % >> b = h.binContaining(5);
        % b == 4;
        %
        % >> b = h.binContaining(6);
        % b == 5;
        %
        % >> b = h.binContaining(7);
        % b == 5;
        %
        % >> b = h.binContaining(9);
        % b == 5;
        %
        % >> b = h.binContaining(10);
        % b == 6;
        %
        % >> b = h.binContaining(11);
        % b == 6;
        %
        % >> b = h.binContaining(16);
        % b == 6;
        %
        % >> b = h.binContaining(17);
        % b == 7;
        %
        % >> b = h.binContaining(10000);
        % b == 7;
        %
        % >> h = HistogramDistribution([10,12],1)
        %
        % >> b = h.binContaining(1);
        % b == 0;
        %
        % >> b = h.binContaining(10);
        % b == 1;
        %
        % >> b = h.binContaining(11);
        % b == 1;
        %
        % >> b = h.binContaining(12);
        % b == 1;
        %
        % >> b = h.binContaining(12.5);
        % b == 2;
        %
        % >> b = h.binContaining(10000);
        % b == 2;
            assert(length(obj) == 1);
            assert(length(value) == 1);
            if value < obj.bounds(1)
                bin_idx = 0;
                return;
            elseif value > obj.bounds(end)
                bin_idx = length(obj.bounds);
                return;
            end
            % Do a binary search
            % Loop invariant obj.bounds(lower_bound) <= value <=
            % obj.bounds(upper_bound)
            lower_bound = 1;
            upper_bound = length(obj.bounds);
            while (upper_bound - lower_bound) >= 2
                cur_bound_idx = floor((lower_bound + upper_bound) / 2);
                cur_bound = obj.bounds(cur_bound_idx);
                if cur_bound <= value
                    lower_bound = cur_bound_idx;
                else
                    assert(value < cur_bound)
                    upper_bound = cur_bound_idx;
                end
            end
            
            % Now find out exactly what bin the value falls in
            if obj.bounds(upper_bound) == value
                if obj.border_is_in_upper_bin(upper_bound)
                    bin_idx = upper_bound;
                else
                    bin_idx = upper_bound-1;
                end
            elseif obj.bounds(lower_bound) == value
                if obj.border_is_in_upper_bin(lower_bound)
                    bin_idx = lower_bound;
                else
                    bin_idx = lower_bound-1;
                end
            else % value lies between lower and upper
                assert(obj.bounds(lower_bound) < value && value < obj.bounds(upper_bound));
                bin_idx = lower_bound;
            end
        end
        
        
        function new_dists = rebinEqualWidth(objs, num_bins)
        % Return a HistogramDistribution with the same support but the bins are all the same size
        %
        % Usage: new_dists = rebinEqualWidth(objs, num_bins)
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
        % >> h = HistogramDistribution([0,1,1,2,3],[0.25 0.25 0.25 0.25]);
        % >> i = HistogramDistribution([0,1,1,2,3,5],[0.2 0.2 0.2 0.2 0.2]);
        % >> hi = [h,i];
        %
        % >> b=h.rebinEqualWidth(2);
        %
        % b == HistogramDistribution([0,1.5,3],[0.625 0.375]);
        %
        % >> b=h.rebinEqualWidth(3);
        %
        % b == HistogramDistribution([0,1,2,3],[0.25 0.5 0.25]);
        %
        % >> b=h.rebinEqualWidth(4);
        %
        % b == HistogramDistribution([0,0.75,1.5,2.25,3],[3/16 7/16 3/16 3/16]);
        %
        % >> b=h.rebinEqualWidth(6);
        %
        % b == HistogramDistribution([0,0.5,1,1.5,2,2.5,3],[1,1,3,1,1,1]/8);
        %
        % >> b=i.rebinEqualWidth(2);
        %
        % b == HistogramDistribution([0,2.5,5],[0.7,0.3]);
        %
        % >> b=i.rebinEqualWidth(5);
        %
        % b == HistogramDistribution([0,1,2,3,4,5],[0.2,0.4,0.2,0.1,0.1]);
        %
        % >> b=i.rebinEqualWidth([2,5]);
        %
        % b == [ HistogramDistribution([0, 2.5, 5], [0.7, 0.3]) HistogramDistribution([0,1,2,3,4,5],[0.2,0.4,0.2,0.1,0.1])]
        %
        % >> b=hi.rebinEqualWidth(2);
        %
        % b == [ HistogramDistribution([0, 1.5, 3], [0.625, 0.375]), HistogramDistribution([0, 2.5, 5], [0.7, 0.3]) ]
        %
        % >> b=hi.rebinEqualWidth([2,5]);
        %
        % b == [ HistogramDistribution([0, 1.5, 3], [0.625, 0.375]), HistogramDistribution([0, 1, 2, 3, 4, 5], [0.2, 0.4, 0.2, 0.1, 0.1]) ]
            if length(objs) == 1 && length(num_bins) == 1
                if num_bins < 1
                    error('HistogramDistribution_rebin:at_least_one', ...
                        ['A HistogramDistribution must have at least ' ...
                        'one bin so num_bins passed to '...
                        'rebinEqualWidth must be at least 1']);
                end
                if num_bins ~= round(num_bins)
                    error('HistogramDistribution_rebin:integer_bins', ...
                        'num_bins must be an integer.');
                end
                bnd = linspace(objs.bounds(1),objs.bounds(end),num_bins+1);
                equal_prob = HistogramDistribution(bnd,ones(1,length(bnd)-1)/(length(bnd)-1));
                p = objs.probOfInterval(equal_prob.bins);
                new_dists = HistogramDistribution(bnd, p, equal_prob.border_is_in_upper_bin);
            elseif length(objs) == length(num_bins)
                new_dists = arrayfun(@(o,n) o.rebinEqualWidth(n), objs, num_bins, 'UniformOutput',false);
            elseif length(objs) == 1
                new_dists = arrayfun(@(n) objs.rebinEqualWidth(n), num_bins, 'UniformOutput',false);
            elseif length(num_bins) == 1
                new_dists = arrayfun(@(o) o.rebinEqualWidth(num_bins), objs, 'UniformOutput',false);
            else
                error('HistogramDistribution_rebinEqualWidth:input_shape',...
                    ['If there are different numbers of bin quantities and '...
                    'HistogramDistributions, one of vector must be size 1.']);
            end
            
            % Unpack cell array output from arrayfun
            if iscell(new_dists)
                new_dists = [new_dists{:}];
            end
        end

        function new_dists = rebinEqualProb(obj, num_bins)
        % Return a HistogramDistribution where a given interval has the
        % same probability as this one but the bins have 
        % equal probabilities. Only works for distributions that lack dirac
        % delta bins.
        %
        % The above description doesn't describe things correctly. See the
        % examples.
        % 
        % Usage: new_dists = rebinEqualProb(objs, num_bins)
        % -------------------------------------------------------------------------
        % Input arguments
        % -------------------------------------------------------------------------
        % 
        % obj - (HistogramDistribution) Must be exactly 1 object. Cannot
        %     contain any dirac delta bins.
        %
        % num_bins - (positive integer) The number of bins in the new
        %     HistogramDistribution.
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
        % >> h = HistogramDistribution([0,1,3,6,10],[0.375 0.125 0.375 0.125]);
        % >> i = HistogramDistribution([0,1,2,3,4,5],[0.2 0.2 0.2 0.2 0.2]);
        % >> j = HistogramDistribution([0,1,2,3,4,5],[0.25 0 0.25 0.25 0.25]);
        % >> k = HistogramDistribution([1,2,3,4,5],[0 0 1 0]);
        % >> l = HistogramDistribution([1,1,2],[0.5,0.5]);
        % >> hi = [h,i];
        % >> x = h.rebinEqualProb(1);
        %
        %   x == HistogramDistribution([0, 10], [1], [1, 0]);
        %
        % >> x = h.rebinEqualProb(2);
        %
        %   x == HistogramDistribution([0, 3, 10], [0.5, 0.5], [1, 1, 0]);
        % 
        % >> x = h.rebinEqualProb(4);
        %
        %   x == HistogramDistribution([0, 2/3, 3, 5, 10], [0.25, 0.25, 0.25, 0.25], [1, 1, 1, 1, 0]);
        %
        % >> x = i.rebinEqualProb(5);
        %
        %   x == HistogramDistribution([0,1,2,3,4,5],[0.2 0.2 0.2 0.2 0.2]);
        %
        % >> x = k.rebinEqualProb(4);
        %
        %   x == HistogramDistribution([1, 3.25, 3.5, 3.75, 5], [0.25, 0.25, 0.25, 0.25], [1, 1, 1, 1, 0]);
        %
        % The following are all errors:
        % >> x = l.rebinEqualProb(3);
        % >> x = h.rebinEqualProb([3,4]);
        % >> x = h.rebinEqualProb([]);
        % >> x = h.rebinEqualProb(0);
        % >> x = h.rebinEqualProb(1.5);
        % >> x = hi.rebinEqualProb(3);
            if length(obj) ~= 1
                error('HistogramDistribution_rebinEqualProb:too_many_obj',...
                    ['rebinEqualProb must be called '...
                    'on a single HistogramDistribution object only. Use'...
                    'rebinApproxEqualProb instead.']);
            end
            if length(num_bins) ~= 1
                error('HistogramDistribution_rebinEqualProb:too_many_num_bins',...
                    'rebinEqualProb can accept only a single number of bins');
            end
            if num_bins < 1 || num_bins ~= round(num_bins)
                error('HistogramDistribution_rebinEqualProb:at_least_1_bin',...
                    'num_bins for rebinEqualProb must be a positive integer.');
            end
            if any(obj.bounds(1:end-1)==obj.bounds(2:end))
                error('HistogramDistribution_rebinEqualProb:no_dirac',...
                    'rebinEqualProb can only work on HistogramDistributions with no dirac bins');
            end

            new_bounds = zeros(1,num_bins+1);
            new_bounds(1)=obj.bounds(1);
            new_bounds(end)=obj.bounds(end);
            target_prob = 1/num_bins;
            new_bnd_idx = 2; % Index of upper bound of the new bin which is being calculated
            old_bnd_idx = 2; % Index of upper bound of the old bin from which probability is being taken for the new bin
            unused_prob_from_prev_old_bins = 0;
            old_bin_width = obj.bounds(old_bnd_idx) - ...
                obj.bounds(old_bnd_idx-1);
            old_bin_remaining = old_bin_width;
            old_prob_per_unit = obj.probs(old_bnd_idx-1)/...
                old_bin_width;
            while new_bnd_idx <= num_bins
                
                % Each time through the loop, make a new bin, advance
                % to the next old bin, or both
                
                needed_prob = target_prob - unused_prob_from_prev_old_bins;
                if needed_prob <= old_bin_remaining * old_prob_per_unit
                    % If there is enough probability mass in this bin to
                    % finish the current new bin, add a new bin at that point.
                    
                    needed_width = needed_prob / old_prob_per_unit;
                    if needed_prob < old_bin_remaining * old_prob_per_unit
                        % If we don't have to use up the whole bin, set the
                        % new bound in the middle of the bin
                        new_bounds(new_bnd_idx) = obj.bounds(old_bnd_idx) - old_bin_remaining + needed_width;
                        old_bin_remaining = old_bin_remaining - needed_width;
                    else
                        % Otherwise we had to use up the whole bin -
                        % advance to the next old bin
                        new_bounds(new_bnd_idx) = obj.bounds(old_bnd_idx);
                        
                        old_bnd_idx = old_bnd_idx + 1;
                        old_bin_width = obj.bounds(old_bnd_idx) - ...
                            obj.bounds(old_bnd_idx-1);
                        old_bin_remaining = old_bin_width;
                        old_prob_per_unit = obj.probs(old_bnd_idx-1)/...
                            old_bin_width;
                    end
                    % Advance to the next new bin
                    unused_prob_from_prev_old_bins = 0;
                    new_bnd_idx = new_bnd_idx + 1;
                else
                    % Not enough mass remains in this bin. Add everything
                    % in the bin to the total from previous bins and move
                    % to the next old bin.
                    
                    % Add rest of bin to unused prob accumulator
                    if old_bin_remaining < old_bin_width
                        % If less than the entire bin is being used,
                        % calculate how much probability is added from this
                        % bin
                        prob_remaining = old_bin_remaining * old_prob_per_unit;
                    else
                        % If we are using the entire bin, use the
                        % probability for the bin rather than doing a
                        % multiplication, which would introduce error
                        prob_remaining = obj.probs(old_bnd_idx-1);
                    end
                    unused_prob_from_prev_old_bins = unused_prob_from_prev_old_bins + prob_remaining;
                    
                    % Move to the next old bin
                    old_bnd_idx = old_bnd_idx + 1;
                    old_bin_width = obj.bounds(old_bnd_idx) - ...
                        obj.bounds(old_bnd_idx-1);
                    old_bin_remaining = old_bin_width;
                    old_prob_per_unit = obj.probs(old_bnd_idx-1)/...
                        old_bin_width;
                end
            end
            new_dists = HistogramDistribution(new_bounds, ...
                target_prob*ones(1,num_bins));
        end        
        
        function new_dists = rebinApproxEqualProb(objs, num_bins)
        % Return a HistogramDistribution where a given interval has the
        % same probability as this one but the bins have approximately
        % equal probabilities
        %
        % Usage: newDist = rebinApproxEqualProb(objs, num_bins)
        %
        % When there are no dirac bins, calls rebinEqualProb(num_bins).
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
        % NOTE: this algorithm can fail with dirac bins:
        %
        % For example consider: 
        %
        % HistogramDistribution([0,0,1,1],[0.5,0,0.5])
        %
        % Rebin that into 5 segments. The first two segments will be [0,0]
        % and then (0,1]. There will be no place to put the other
        % zero-probability segments.
        %
        % To avoid this, the last bin must be a non-zero probability
        % uniform bin.
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
        % n == HistogramDistribution([0,1,1,2,3,5],[0.2 0.2 0.2 0.2 0.2],[1 1 0 0 1 0]);
        % NOTE: you'd expect n==i but it doesn't work out that way because
        % of floating point rounding. The difference in calculations is
        % negligable, but it is much less nice aestetically.
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
                if ~any(objs.bounds(1:end-1)==objs.bounds(2:end))
                    new_dists = objs.rebinEqualProb(num_bins);
                    return;
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
                        if extended_prob <= target_prob && ~(extended_bin == cur_bin)
                            cur_bin = extended_bin;
                            cur_prob = extended_prob;
                        else
                            % We cannot improve by further extension either
                            % because the extended probabiliy is greater
                            % than the target probability or because
                            % extension is not changing the bin
                            if abs(extended_prob - target_prob) <= abs(target_prob - cur_prob)
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
                        remaining_prob = remaining_prob - cur_prob;
                        if remaining_bins > 0
                            target_prob = remaining_prob / remaining_bins;
                        else
                            target_prob = 0;
                        end
                        cur_bin = Interval(cur_bin.max, cur_bin.max, ~cur_bin.contains_max, ~cur_bin.contains_max);
                        cur_prob = objs.probOfInterval(cur_bin);
                    end
                end
                
                % Turn the list of bins into a histogram distribution
                final_bin = new_bins(end);
                new_bins(end) = Interval(final_bin.min, final_bin.max, ...
                    final_bin.contains_min, true);  % Ensure the last bin is contains its maximum to meet the requirements of HistogramDistribution objects
                all_but_first_bin = new_bins(2:end);
                new_dists = HistogramDistribution(...
                    [[new_bins.min], final_bin.max], ...
                    objs.probOfInterval(new_bins), ...
                    [true,[all_but_first_bin.contains_min],false]);
            elseif length(objs) == length(num_bins)
                new_dists = arrayfun(@(o,n) o.rebinApproxEqualProb(n), objs, num_bins, 'UniformOutput',false);
            elseif length(objs) == 1
                new_dists = arrayfun(@(n) objs.rebinApproxEqualProb(n), num_bins, 'UniformOutput',false);
            elseif length(num_bins) == 1
                new_dists = arrayfun(@(o) o.rebinApproxEqualProb(num_bins), objs, 'UniformOutput',false);
            else
                error('HistogramDistribution_rebinApproxEqualProb:input_shape',...
                    ['If there are different numbers of bin quantities and '...
                    'HistogramDistributions, one of vector must be size 1.']);
            end
            
            % Unpack cell array output from arrayfun
            if iscell(new_dists)
                new_dists = [new_dists{:}];
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
        % If the interval is non-zero length and open at the top, closes it.
        % If the interval is closed at the top or zero length and there is a greater 
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
        % obj - (a HistogramDistribution object)
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
        %
        % >> i = h.private_extendInterval(Interval(8,8,false,false),0.6); 
        % i == Interval(8,8,false,false)
        %
        % >> hh = HistogramDistribution([2,2,3,5,8],0.25*ones(1,4),[1,1,1,1,0]);
        % >> i = hh.private_extendInterval(Interval(2,2,false,false),0.6); 
        % i == Interval(2,3,false,false)
        %
        % >> i = hh.private_extendInterval(Interval(2,2,false,false),0.125); 
        % i == Interval(2,2.5,false,false)
            assert(0 <= target_prob && target_prob <= 1);
            assert(length(obj) == 1);
            assert(length(interval) == 1);
            
            if ~interval.contains_max && interval.length ~= 0
                new_interval = Interval(interval.min, interval.max, interval.contains_min, true);
            else
                greater_bounds = obj.bounds > interval.max;
                if any(greater_bounds)
                    % Calculate how much probability could be made up by
                    % extending the interval (note that the next interval
                    % can never have zero length because greater_bounds is
                    % those bounds that are strictly greater than
                    % interval.max)
                    next_bound_idx = find(greater_bounds, 1,'first');
                    remaining_prob = ...
                        target_prob - obj.probOfInterval(interval);
                    if remaining_prob <= 0
                        % If no prob could be made up, just extend
                        new_interval = Interval(interval.min, ...
                            obj.bounds(next_bound_idx), ...
                            interval.contains_min, false);
                    else
                        % If some probability could be made up, see how
                        % much of the next interval is needed
                        next_interval = Interval(interval.max, ...
                        obj.bounds(next_bound_idx), false, false);
                        next_interval_prob = obj.probOfInterval(next_interval);
                        fraction_needed = remaining_prob / next_interval_prob;
                        if fraction_needed >= 1
                            % If more is needed than we have, extend by the
                            % entire new interval
                            new_interval = Interval(interval.min, ...
                                obj.bounds(next_bound_idx), ...
                                interval.contains_min, false);
                        else
                            % Otherwise, use exactly what we need to reach
                            % the target probability
                            new_max = interval.max + ...
                                next_interval.length * fraction_needed;
                            if new_max == interval.max
                                % If the fraction needed was too small,
                                % increment by smallest floating point
                                % number.
                                new_max = nextAfter(interval.max);
                            end
                            new_interval = Interval(interval.min, ...
                                new_max, ...
                                interval.contains_min, false);
                        end
                    end
                    
                else % No way to extend the interval, so leave it alone
                    new_interval = interval;
                end
            end
        end
        
        function [handle] = plot(obj, linespec)
        % Usage [handle] = plot(obj, linespec)
        %
        % Plot this HistogramDistribution on the current axes
            widths = obj.bounds(2:end)-obj.bounds(1:end-1);
            heights = obj.probs ./ widths;
            is_dirac = obj.bounds(2:end) == obj.bounds(1:end-1);
            heights(is_dirac) = 0;
            heights(is_dirac) = max(heights);
            
            if ~exist('linespec','var')
                h = stairs([obj.bounds(1), obj.bounds, obj.bounds(end)], ...
                    [0, heights, heights(end),0]);
            else
                h = stairs([obj.bounds(1), obj.bounds, obj.bounds(end)], ...
                    [0, heights, heights(end),0], linespec);
            end
            if nargout > 0
                handle = h;
            end
            
        end
        
        function counts = binCounts(obj, observations)
        % Usage counts = binCounts(obj, observations)
        %
        % Return the number of observations that fell into each bin.
        % -------------------------------------------------------------------------
        % Input arguments
        % -------------------------------------------------------------------------
        % 
        % obj - (a HistogramDistribution object)
        %
        % observations - (vector of double)
        %
        % -------------------------------------------------------------------------
        % Output parameters
        % -------------------------------------------------------------------------
        % 
        % counts - (vector of double) counts(i) is the number of
        %      observations that fell into bin(i)
        %
        % -------------------------------------------------------------------------
        % Examples
        % -------------------------------------------------------------------------
        % >> h = HistogramDistribution([-2,1,1,5,11,13,15],ones(1,6)/6)
        % >> c = h.binCounts([-5,0,1,1,2,2,2,3,3,3,5,5,5,6,11,11,11,11,11,90])
        % c == [1,2,6,4,5,0]
        % >> c = h.binCounts([])
        % c == [0,0,0,0,0,0]
            counts = zeros(size(obj.probs));
            for o = observations
                bin_idx = obj.binContaining(o);
                if 1 <= bin_idx && bin_idx <= length(counts)
                    counts(bin_idx) = counts(bin_idx) + 1;
                end
            end
        end
    end
    
end

