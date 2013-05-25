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
            length = obj.max - obj.min;
        end
        
	
        function does_contain = contains(obj, val)
        % Returns true if this ClosedInterval contains val and
        % false otherwise. 
        %
        % val must be a scalar
          assert(isscalar(val));
          does_contain = [obj.min] <= val & val <= [obj.max];
        end
        
        function does_intersect = intersects(objs, closed_interval)
        % Returns true iff this ClosedInterval has a non-empty intersection with closed_interval
        %
        % closed_interval must be a single ClosedInterval object
        %
        % does_intersect(i) is true objs(i) represents a closed interval
        %     of the real line that has a non-empty intersection with 
        %     closed_interval
        %
        % Note: to extend this code to the case where
        % length(closed_interval) == length(objs), change 
        %
        % assert(length(closed_interval) == 1);
        %
        % to
        %
        % assert(length(closed_interval) == 1 || length(closed_interval == length(objs));
        % change the documentation and write the test cases. 
        %
        % I didn't do this because I didn't want to write the test cases
        %
        % ----------------------------------------------------------------
        % Examples
        % ----------------------------------------------------------------
        %
        % The following are all true
        %
        % >> a = ClosedInterval(0,0);
        % >> b = ClosedInterval(0,1);
        % >> c = ClosedInterval(1,2);
        % >> d = ClosedInterval(0,2);
        % >> e = ClosedInterval(2,3);
        % >> f = ClosedInterval(3,3);
        % >> g = ClosedInterval(3,4);
        % >> tot = [a b c d e f g];
        % >> a.intersects(a);
        % >> a.intersects(b);
        % >> ~a.intersects(c);
        % >> a.intersects(d);
        % >> ~a.intersects(e);
        % >> ~a.intersects(f);
        % >> ~a.intersects(g);
        % >> tot.intersects(a) == [true,true,false,true,false,false,false];
        %
        % >> b.intersects(a);
        % >> b.intersects(b);
        % >> b.intersects(c);
        % >> b.intersects(d);
        % >> ~b.intersects(e);
        % >> ~b.intersects(f);
        % >> ~b.intersects(g);
        % >> tot.intersects(b) == [true,true,true,true,false,false,false];
        %
        % >> ~c.intersects(a);
        % >> c.intersects(b);
        % >> c.intersects(c);
        % >> c.intersects(d);
        % >> c.intersects(e);
        % >> ~c.intersects(f);
        % >> ~c.intersects(g);
        % >> tot.intersects(c) == [false,true,true,true,true,false,false];
        %
        % >> d.intersects(a);
        % >> d.intersects(b);
        % >> d.intersects(c);
        % >> d.intersects(d);
        % >> d.intersects(e);
        % >> ~d.intersects(f);
        % >> ~d.intersects(g);
        % >> tot.intersects(d) == [true,true,true,true,true,false,false];
        %
        % >> ~e.intersects(a);
        % >> ~e.intersects(b);
        % >> e.intersects(c);
        % >> e.intersects(d);
        % >> e.intersects(e);
        % >> e.intersects(f);
        % >> e.intersects(g);
        % >> tot.intersects(e) == [false,false,true,true,true,true,true];
        %
        % >> ~f.intersects(a);
        % >> ~f.intersects(b);
        % >> ~f.intersects(c);
        % >> ~f.intersects(d);
        % >> f.intersects(e);
        % >> f.intersects(f);
        % >> f.intersects(g);
        % >> tot.intersects(f) == [false,false,false,false,true,true,true];
        %
        % >> ~g.intersects(a);
        % >> ~g.intersects(b);
        % >> ~g.intersects(c);
        % >> ~g.intersects(d);
        % >> g.intersects(e);
        % >> g.intersects(f);
        % >> g.intersects(g);
        % >> tot.intersects(g) == [false,false,false,false,true,true,true];
          assert(isa(closed_interval, 'ClosedInterval'));
          assert(length(closed_interval) == 1);
          assert(~isempty(objs)); % I assume that you can't call this on an empty vector, but I'm just making sure
          % The two intervals [a,b] [x,y] don't intersect in only two 
          % cases
          % 1. b < x (the first interval comes before the second)
          % 2. y < a (the second interval comes before the first)
          %
          % Thus we can identify the intersection by 
          % NOT(b < x OR y < a)
          %
          % Distributing, intersection means
          %
          % x <= b AND a <= y
          %
          % This analysis is cribbed from: 
          % http://world.std.com/~swmcd/steven/tech/interval.html
          does_intersect = [objs.min] <= [closed_interval.max] & ...
              [closed_interval.min] <= [objs.max];
        end
        
        function result = intersection(objs, closed_interval)
        % result(i) is the intersection of objs(i) and closed_interval
        %
        % It is an error to use objs and closed_interval values that will
        % generate an empty intersection. Use ClosedInterval.intersects to
        % avoid this.
        %
        % ----------------------------------------------------------------
        % Examples
        % ----------------------------------------------------------------
        %
        % The following are all true
        %
        % >> a = ClosedInterval(0,0);
        % >> b = ClosedInterval(0,1);
        % >> c = ClosedInterval(1,2);
        % >> d = ClosedInterval(0,2);
        % >> e = ClosedInterval(2,3);
        % >> f = ClosedInterval(3,3);
        % >> g = ClosedInterval(3,4);
        % >> tot = [a b c d e f g];
        % >> a.intersection(a) == a;
        % >> a.intersection(b) == a;
        % >> a.intersection(d) == a;
        % >> a_intersectors = tot(tot.intersects(a));
        % >> a_intersectors.intersection(a) == [a,a,a];
        %
        % >> b.intersection(a) == a;
        % >> b.intersection(b) == b;
        % >> b.intersection(c) == ClosedInterval(1,1);
        % >> b.intersection(d) == b;
        % >> b_intersectors = tot(tot.intersects(b));
        % >> b_intersectors.intersect(b) == [a, b, ClosedInterval(1,1), b];
        %
        % >> c.intersection(b) == ClosedInterval(1,1);
        % >> c.intersection(c) == c;
        % >> c.intersection(d) == c;
        % >> c.intersection(e) == ClosedInterval(2,2);
        % >> c_intersectors = tot(tot.intersects(c));
        % >> c_intersectors.intersect(c) == [ClosedInterval(1,1),c,c,ClosedInterval(2,2)];
        %
        % >> d.intersection(a) == a;
        % >> d.intersection(b) == b;
        % >> d.intersection(c) == c;
        % >> d.intersection(d) == d;
        % >> d.intersection(e) == ClosedInterval(2,2);
        % >> d_intersectors = tot(tot.intersects(d));
        % >> d_intersectors.intersect(d) == [a,b,c,d,ClosedInterval(2,2)];
        %
        % >> e.intersection(c) == ClosedInterval(2,2);
        % >> e.intersection(d) == ClosedInterval(2,2);
        % >> e.intersection(e) == e;
        % >> e.intersection(f) == f;
        % >> e.intersection(g) == f;
        % >> e_intersectors = tot(tot.intersects(e));
        % >> e_intersectors.intersect(e) == [ClosedInterval(2,2),ClosedInterval(2,2),e,f,f];
        %
        % >> f.intersection(e) == f;
        % >> f.intersection(f) == f;
        % >> f.intersection(g) == f;
        % >> f_intersectors = tot(tot.intersects(f));
        % >> f_intersectors.intersect(f) == [f,f,f];
        %
        % >> g.intersection(e) == f;
        % >> g.intersection(f) == f;
        % >> g.intersection(g) == g;
        % >> g_intersectors = tot(tot.intersects(g));
        % >> g_intersectors.intersect(g) == [f,f,g];
          assert(all(objs.intersects(closed_interval)));
          mins = max([objs.min],[closed_interval.min]); %#ok<CPROP>
          maxes = min([objs.max],[closed_interval.max]); %#ok<CPROP>
          result = arrayfun(@ClosedInterval, mins, maxes, 'UniformOutput',false);
          result = [result{:}];
        end

        function str=char(obj)
        % Return a human-readable string representation of this
        % object. (Matlab's version of toString, however, Matlab
        % doesn't call it automatically)
          if length(obj) == 1
            str = sprintf('ClosedInterval(%g,%g)', obj.min, obj.max);
          else
            first = obj(1);
            rest = obj(2:end);
            str = [ '[' ...
                sprintf('ClosedInterval(%g,%g)', ...
                   first.min, first.max) ...
                sprintf(' ClosedInterval(%g,%g)', ...
                   rest.min, rest.max) ...
                ']'
            ];
          end
        end
	    
        function display(obj)
        % Display this object to a console. (Called by Matlab
        % whenever an object of this class is assigned to a
        % variable without a semicolon to suppress the display).
            disp(obj.char);
        end
        
        function are_eq = eq(a, b)
        % Implements the == operator for ClosedInterval objects
        % are_eq(i) == a(i) has same min and max as b(i)
        %
        % ----------------------------------------------------------------
        % Examples
        % ----------------------------------------------------------------
        %
        % The following are all true statements
        %
        % >> ClosedInterval(1,1) == ClosedInterval(1,1)
        % >> ~(ClosedInterval(0,1) == ClosedInterval(1,1))
        % >> ~(ClosedInterval(1,2) == ClosedInterval(1,1))
        % >> ~(ClosedInterval(2,2) == ClosedInterval(1,1))
        % >> all([ClosedInterval(1,1),ClosedInterval(2,2)]==[ClosedInterval(1,1),ClosedInterval(2,2)])
        % >> ~any([ClosedInterval(1,1),ClosedInterval(2,2)]==[ClosedInterval(2,1),ClosedInterval(2,1)])
        % >> ~any([ClosedInterval(1,1),ClosedInterval(1,1)]==[ClosedInterval(1,2),ClosedInterval(2,2)])
        % >> all([ClosedInterval(1,1),ClosedInterval(1,1)]==ClosedInterval(1,1))
        % >> ([ClosedInterval(1,2),ClosedInterval(1,1)]==ClosedInterval(1,1)) == [false, true]
          are_eq = [a.min] == [b.min] & [a.max] == [b.max];
        end
    end
    
end

