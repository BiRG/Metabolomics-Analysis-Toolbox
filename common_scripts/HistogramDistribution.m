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
    
    methods
        function objs=HistogramDistribution(bounds, probs, border_is_in_upper_bin)
        % usage: objs=HistogramDistribution(bounds, probs, border_is_in_upper_bin)
        % usage: objs=HistogramDistribution(bounds, probs)
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
    end
    
end

