classdef ClosedInterval
    %INTERVAL Represents a non-empty closed interval on the real line
    % 
    % Parameters are the minimum and maximum.
    %
    % ---------------------------------------------------------------------
    % Examples
    % ---------------------------------------------------------------------
    % 
    
    properties (SetAccess=private)
        % The minimum value in the interval. min <= max. (scalar)
        min
        
        % The maximum value in the interval. min <= max. (scalar)
        max
    end
    
    properties (Dependent)
        % The length of the interval 
        length	
    end
    
    methods
        function objs=ClosedInterval(min, max)
        % ClosedInterval(min, max)
        %
        % Creates a closed interval with the given miniumum and maximum
	%
	% All parameters must be scalars. min <= max
	% 
        % ----------------------------------------------------------------
        % Examples
        % ---------------------------------------------------------------
	%
	% >> ClosedInterval(-1,1)
	%
	% Creates a closed interval containing all points from -1
        % to 1, including -1 and 1 themeselves.
	  if nargin > 0
	    assert(nargin == 2);
	    assert(isscalar(min));
	    assert(isscalar(max));
	    assert(min <= max);

	    objs.min = min;
	    objs.max = max;
	  end
        end
        
        function length=get.length(obj)
        % Getter method calculating length
	    length = max - min;
        end
        
	
	function does_contain = contains(obj, val)
	% Returns true if this ClosedInterval contains val and
        % false otherwise. 
	%
	% val must be a scalar
	  assert(isscalar(val);
	  does_contain = min <= val && val <= max;
	end

        function str=char(obj)
        % Return a human-readable string representation of this
        % object. (Matlab's version of toString, however, Matlab
        % doesn't call it automatically)
          str = sprintf('ClosedInterval(%g,%g)', obj.min, obj.max);
	end
	    
        function display(obj)
        % Display this object to a console. (Called by Matlab
        % whenever an object of this class is assigned to a
        % variable without a semicolon to suppress the display).
	   disp(obj.char);
	end
    end
    
end

