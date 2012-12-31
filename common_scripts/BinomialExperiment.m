classdef BinomialExperiment
    %BINOMIALEXPERIMENT Represents the results of drawing multiple samples from a Bernoulli distribution
    %
    % The parameters are the number of successes and number of
    % failures. The methods inferring a most probable parameter
    % value and 95% confidence intervals also take parameters
    % giving the prior a and b. My favorite prior is the Jefferey's
    % prior (which has a = b = 1/2). The other two popular priors
    % are the Haldane prior (a = b = 0) and the uniform
    % distribution (a = b = 1).
    %
    % ---------------------------------------------------------------------
    % Examples
    % ---------------------------------------------------------------------
    %
    
    properties (SetAccess=private)
        % The number of successes in the experiment  A scalar.
        successes
        
        % The number of failures observed in the experiment. A scalar.
        failures
        
        % The alpha parameter of the Beta distribution that represents
        % the information about the parameter of the Bernoulli
        % distribution known before the binomial experiment took
        % place. One can think of this as the number of successes
        % observed. Set this to 1/2, 1, or 0 for the Jefferey's ,
        % Uniform, or Haldane prior respectively. A scalar.
        priorAlpha
        
        % The beta parameter of the Beta distribution that represents
        % the information about the parameter of the Bernoulli
        % distribution known before the binomial experiment took
        % place. One can think of this as the number of failures
        % observed. Set this to 1/2, 1, or 0 for the Jefferey's ,
        % Uniform, or Haldane prior respectively. A scalar.
        priorBeta
    end
    
    properties (Dependent)
        % The most likely parameter of the Bernoulli distribution that
        % the experiment sampled given the observations and the prior
        % assumptions. This is the estimated probability of getting a
        % success. Note that in some cases there is no single mode
        % (most commonly when there are no observations). In that
        % case, this is NaN (not a number).
        prob
        
        % The total number of trials (=successes+failures)
        trials
        
    end
    
    methods
        function objs=BinomialExperiment(successes, failures, ...
                priorAlpha, priorBeta)
            % BinomialExperiment(successes, failures, priorAlpha, priorBeta)
            %
            % Creates a binomial experiment with the given observed
            % successes and failures and the given parameters for the
            % prior distribution.
            %
            % A good prior to use is priorAlpha = priorBeta = 0.5 (this
            % is the Jefferey's prior). A uniform prior distribution is
            % priorAlpha = priorBeta = 1.
            %
            % All parameters must be non-negative scalars.
            if nargin > 0
                assert(nargin == 4);
                assert(isscalar(successes));
                assert(isscalar(failures));
                assert(isscalar(priorAlpha));
                assert(isscalar(priorBeta));
                assert(successes >= 0);
                assert(failures >= 0);
                assert(priorAlpha >= 0);
                assert(priorBeta >= 0);
                
                objs.successes = successes;
                objs.failures = failures;
                objs.priorAlpha = priorAlpha;
                objs.priorBeta = priorBeta;
            end
        end
        
        function prob=get.prob(obj)
            % Getter method calculating prob
            f = obj.failures + obj.priorAlpha;
            s = obj.successes + obj.priorBeta;
            if s > 1 && f > 1
                % The standard case
                prob = (s-1)/(s+f-2);
            elseif s == f
                % We know that s <= 1 because of the previous
                % test. This means that the Beta distribution is
                % either uniform, u-shaped, or two dirac deltas. In
                % all cases, there is no mode, so there is no most
                % likely probability.
                prob = nan;
            elseif s < 1
                if f < 1
                    % U-shaped when s < 1 & f < 1, so no mode
                    prob = nan;
                else %f >= 1
                    % Reverse J shaped with a right tail, strictly decreasing
                    prob = 0;
                end
            elseif s == 1
                if f < 1
                    % J-shaped with a left tail
                    prob = 1;
                else % f > 1 (since s ~= f)
                    % Strictly decreasing mirror-image power function
                    % distribution
                    assert(f > 1);
                    prob = 0;
                end
            else %s > 1
                assert(f <= 1); % if s>1 && f>1 we'd be in the
                % standard case
                % f < 1 is J-shaped with a left tail
                % f == 1 is a strictly increasing power function
                % distribution. The mode is 1 in both cases.
                prob = 1;
            end
        end
        
        function trials=get.trials(obj)
            % Getter method calculating prob
            trials = obj.successes+obj.failures;
        end
        
        function new_exp = withMoreTrials(obj, numSuccesses, ...
                numTrials)
            % Constructs (and returns) a new BinomialExperiment object
            % reflecting the fact that more trials have been done.
            %
            % Technical note: Even though, technically, the current
            % experiment's parameters should be combined into the prior, I
            % like having a record of the initial prior and decided to
            % make the new experiment as if all trials (including the ones
            % from this experiment) had been performed in that
            % experiment. All calculations on the returned experiment will
            % return the same results.
            %
            % numSuccesses - (scalar) the number of successes in the new
            %                trials. Must be non-negative.
            %
            % numTrials - (scalar) the number of trials performed. Must
            %                be at least as large as numSuccesses.
            %
            % new_exp - the newly created BinomialExperiment object
            assert(isscalar(numSuccesses));
            assert(isscalar(numTrials));
            assert(numSuccesses >= 0);
            assert(numTrials >= numSuccesses);
            
            new_exp = BinomialExperiment(obj.successes + numSuccesses, ...
                obj.failures + numTrials- ...
                numSuccesses, obj.priorAlpha, ...
                obj.priorBeta);
        end
        
        
        function interval=shortestCredibleInterval(obj, confidence, tolerance)
            % Calculates the the shortest interval that contains the
            % parameter of the Bernoulli distribution sampled in the
            % experiment with the given confidence
            %
            % confidence - (scalar) the confidence one wants. For a 95%
            %              CI, use 0.95, then the parameter will be in the
            %              returned interval 95% of the time. Must be in
            %              the interval [0, 1], that is, 0 <= confidence
            %              <= 1.
            %
            % tolerance - (scalar, optional) the tolerance for the location
            %             of the start of the confidence interval. A more
            %             accurate start may make the interval smaller.
            %             However, calculating that interval will take more
            %             time. If this parameter is omitted, it defaults 
            %             to 1e-7.
            %
            %
            % interval - (ClosedInterval or Nan) The interval calculated
            %            by the algorithm or NaN if it doesn't converge.
            %
            % This algorithm can fail to converge. This failure may become
            % more probable as the product successes*trials increases. On
            % failure, returns NaN. I have been unable to make it fail, so
            % this is not tested (betainv fails before my code does).
            %
            %Example:
            % >> BinomialExperiment(10,15,1,1).shortestCredibleInterval(.95)
            %
            % Returns the shortest 95% credible interval with a uniform
            % prior
            %
            % ans = ClosedInterval(0.229108, 0.589409)
            %
            % >> BinomialExperiment(2,2,1,1).shortestCredibleInterval(.95)
            %
            % ans = ClosedInterval(0.146633, 0.853367)
            %
            % >> BinomialExperiment(0,2,1,1).shortestCredibleInterval(.95)
            %
            % ans = ClosedInterval(0, 0.631597)
            %
            % >> BinomialExperiment(1,0,1,1).shortestCredibleInterval(.95)
            %
            % ans = ClosedInterval(0.223607, 1)
            %
            %
            
            % This code is based upon (but much improved from) code from
            % http://www.causascientia.org/math_stat/compPCI.js used in
            % view-source:http://www.causascientia.org/math_stat/ProportionCI.html
            assert(isscalar(confidence));
            assert(0 <= confidence && confidence <= 1);
            
            if ~exist('tolerance','var')
                tolerance = 1e-7;
            end
            
            a = obj.successes + obj.priorAlpha;
            b = obj.failures + obj.priorBeta;
            
            if obj.successes == 0
                % No successes
                interval = ClosedInterval(0, betainv(confidence, a, b));
                return;
            elseif obj.failures == 0
                % No failures
                interval = ClosedInterval(betainv(1-confidence, a, b), 1);
                return;
            elseif obj.successes == obj.failures
                % Symmetric beta distribution so smallest CI is the
                % one containing the median
                interval = ClosedInterval(...
                    betainv(0.5*(1 - confidence), a, b), ...
                    betainv(0.5*(1 + confidence), a, b));
                return;
            else
                [interval_start,length,status] = fminbnd(...
                    @(start) betainv(betacdf(start, a, b) + confidence, ...
                    a, b) - start, ...
                    0, betainv(1-confidence, a, b),...
                    optimset('TolX',tolerance));
                if status == 1
                    interval = ClosedInterval(interval_start, ...
                        interval_start + length);
                else
                    interval = nan;
                end
                return;
            end
        end
            
        function str=char(obj) 
            % Return a human-readable string representation of this
            % object. (Matlab's version of toString, however, Matlab
            % doesn't call it automatically)
            aa = obj.priorAlpha; bb = obj.priorBeta;
            if aa==bb && (aa==0 || aa==0.5 || aa==1)
                if aa==0
                    prior = 'Haldane Prior';
                elseif aa==0.5
                    prior = 'Jeffreys Prior';
                else
                    assert(aa==1);
                    prior = 'Uniform Prior';
                end
            else
                prior = sprintf('Beta(%g, %g) Prior', aa, bb);
            end
            str=sprintf('BinomialExperiment(Succ=%g, Fail=%g, %s)', ...
                obj.successes, obj.failures, prior);
        end

        function display(obj) 
            % Display this object to a console. (Called by Matlab
            % whenever an object of this class is assigned to a
            % variable without a semicolon to suppress the display).
            disp(obj.char);
        end
            
    end
end
