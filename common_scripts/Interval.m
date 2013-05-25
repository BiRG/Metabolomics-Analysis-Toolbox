classdef Interval
    %INTERVAL Represents an interval on the real line
    % 
    % Parameters are the supremum and infimum and whether those are each
    % contained in the interval
    %
    
    properties (SetAccess=private)
        % The infimum of the interval. min <= max. (scalar)
        min
        
        % The supremum of the interval. min <= max. (scalar)
        max
        
        % True iff the interval contains its infimum (logical)
        contains_min
        
        % True iff the interval contains its supremum (logical)
        contains_max
    end
    
    properties (Dependent)
        % The length of the interval (scalar)
        length	
        
        % True iff the interval contains no points
        is_empty
    end
    
    methods
        function objs=Interval(min, max, contains_min, contains_max)
        % Usage: objs=Interval(min, max, contains_min, contains_max)
        %
        % Creates a closed interval with the given miniumum and maximum and
        % end-point containment. See the properties for a description of
        % the parameters.
        %
        % If contains_min or contains_max are not logicals, they are
        % converted to logicals by contains_min ~= 0
        %
        % All parameters must be the same length. min <= max
        % 
        % ----------------------------------------------------------------
        % Examples
        % ---------------------------------------------------------------
        %
        % >> Interval(-1,1, true, true)
        %
        % Creates a closed interval containing all points from -1
        % to 1, including -1 and 1 themeselves.
        %
        % >> Interval(-1,1, false, true)
        %
        % Creates a half-open interval containing all points from -1
        % to 1, not including -1 but including 1.
        %
        % >> Interval(-1,1, false, false)
        %
        % Creates an interval containing all points from -1
        % to 1, not including either endpoint
        %
        % >> Interval(-1,1, true, false)
        %
        % Creates an interval containing all points from -1
        % to 1, excluding 1 but including -1
        %
        % >> Interval(1,1, false, false)
        %
        % Creates an empty interval
        %
        % >> Interval(1,1, true, true)
        %
        % Creates an interval containing only the point 1
        %
        % >> Interval(1,1, false, true)
        %
        % Error: Interval:zero_length_end_points
        %
        % The interval contains its max which is 1. It cannot exlcude 1
        % which is its min. A zero length interval can either contain both
        % its endpoints or be empty.
        
          if nargin > 0
            assert(nargin == 4);
            assert(length(min) == length(max));
            assert(length(min) == length(contains_min));
            assert(length(min) == length(contains_max));
            
            assert(all(min <= max));
            if ~islogical(contains_min)
                contains_min = contains_min ~= 0;
            end
            if ~islogical(contains_max)
                contains_max = contains_max ~= 0;
            end
            
            if length(min) == 1
                % Create a single interval
                objs.min = min;
                objs.max = max;
                objs.contains_min = contains_min;
                objs.contains_max = contains_max;
                if min == max && contains_min ~= contains_max
                    error('Interval:zero_length_end_points','If a zero-length Interval contains one endpoint, it must contain both');
                end
            else
                % Fill an array of intervals
                objs = arrayfun(@Interval, min, max, contains_min, contains_max, 'UniformOutput', false);
                objs = [objs{:}];
            end
            
          end
        end

        function length=get.length(objs)
        % Getter method calculating length
            length = [objs.max] - [objs.min];
        end
        
        function is_empty=get.is_empty(objs)
        % Getter method calculating whether the interval is empty
            is_empty = ([objs.max] - [objs.min]) == 0 & ~[objs.contains_min] & ~[objs.contains_max];
        end
        
	
        function does_contain = contains(obj, val)
        % Returns true if this ClosedInterval contains val and
        % false otherwise. 
        %
        % val must be a scalar
          assert(isscalar(val));
          does_contain = ...
              ([obj.min] < val & val < [obj.max]) | ...     % Fully in the interval
              ([obj.contains_min] & [obj.min] == val) | ... % Or at the infimum and the infimum is inside the interval
              ([obj.contains_max] & [obj.max] == val);      % Or at the supremum and the supremum is inside the interval
        end
        
        function does_intersect = intersects(objs, interval)
        % Returns true iff this Interval has a non-empty intersection with interval
        %
        % interval must be a single Interval object
        %
        % does_intersect(i) is true iff objs(i) represents an interval
        %     of the real line that has a non-empty intersection with 
        %     interval
        %
        % Note: to extend this code to the case where
        % length(interval) == length(objs), change 
        %
        % assert(length(interval) == 1);
        %
        % to
        %
        % assert(length(interval) == 1 || length(interval == length(objs));
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
        % >> a = Interval(0,0,true,true);
        % >> b = Interval(0,1,true,true);
        % >> c = Interval(1,2,true,true);
        % >> d = Interval(0,2,true,true);
        % >> e = Interval(2,3,true,true);
        % >> f = Interval(3,3,true,true);
        % >> g = Interval(3,4,true,true);
        % >> h = Interval(1,1,true,true);
        % >> i = Interval(2,2,true,true);
        % >> j = Interval(0,0,false,false);
        % >> k = Interval(0,1,false,false);
        % >> l = Interval(1,1,false,false);
        % >> m = Interval(1,2,false,false);
        % >> n = Interval(0,2,false,false);
        % >> o = Interval(2,2,false,false);
        % >> p = Interval(2,3,false,false);
        % >> q = Interval(3,3,false,false);
        % >> r = Interval(3,4,false,false);
        % >> s = Interval(0,1,true,false);
        % >> t = Interval(1,2,true,false);
        % >> u = Interval(0,2,true,false);
        % >> v = Interval(2,3,true,false);
        % >> w = Interval(3,4,true,false);
        % >> x = Interval(0,1,false,true);
        % >> y = Interval(1,2,false,true);
        % >> z = Interval(0,2,false,true);
        % >> aa= Interval(2,3,false,true);
        % >> ab= Interval(3,4,false,true);
        % >> tot = [a b c d e f g h i j k l m n o p q r s t u v w x y z aa ab];
        %
        % >> a.intersects(a);
        % >> a.intersects(b);
        % >> ~a.intersects(c);
        % >> a.intersects(d);
        % >> ~a.intersects(e);
        % >> ~a.intersects(f);
        % >> ~a.intersects(g);
        % >> ~a.intersects(h);
        %
        % >> ~a.intersects(i);
        % >> ~a.intersects(j);
        % >> ~a.intersects(k);
        % >> ~a.intersects(l);
        % >> ~a.intersects(m);
        % >> ~a.intersects(n);
        % >> ~a.intersects(o);
        % >> ~a.intersects(p);
        %
        % >> ~a.intersects(q);
        % >> ~a.intersects(r);
        % >> a.intersects(s);
        % >> ~a.intersects(t);
        % >> a.intersects(u);
        % >> ~a.intersects(v);
        % >> ~a.intersects(w);
        % >> ~a.intersects(x);
        %
        % >> ~a.intersects(y);
        % >> ~a.intersects(z);
        % >> ~a.intersects(aa);
        % >> ~a.intersects(ab);
        %
        % Below is a tableau I used to help calculate the intersections for
        % the test items
        %
        % min if exists         0  0 0 1 0  2 3 3 1  2 - - -  - - - -  - - 0 1  0 2 3 -  - - - - 
        % infimum               0  0 0 1 0  2 3 3 1  2 0 0 1  1 0 2 2  3 3 0 1  0 2 3 0  1 0 2 3  
        %
        %             0            0 0   0             - -      -          0    0     -    -       
        %             1              1 1 |        1      - -  - |          - 1  |     1  - | 
        %             2                2 2  2        2        - - - -        -  - 2      2 2 - 
        %             3         -           3 3 3                   -  - -        - 3        3 - 
        %             4                         4                        -          -          4  
        %
        % supremum              2  0 1 2 2  3 3 4 1  2 0 1 1  2 2 2 3  3 4 1 2  2 3 4 1  2 2 3 4 
        % max if exists         2  0 1 2 2  3 3 4 1  2 - - -  - - - -  - - - -  - - - 1  2 2 3 4 
        % >>                tot = [a b c d  e f g h  i j k l  m n o p  q r s t  u v w x  y z aa ab];
        % >> tot.intersects(a) == [1 1 0 1  0 0 0 0  0 0 0 0  0 0 0 0  0 0 1 0  1 0 0 0  0 0 0 0]~=0;
        % >> tot.intersects(b) == [1 1 1 1  0 0 0 1  0 0 1 0  0 1 0 0  0 0 1 1  1 0 0 1  0 1 0 0]~=0; 
        % >> tot.intersects(c) == [0 1 1 1  1 0 0 1  1 0 0 0  1 1 0 0  0 0 0 1  1 1 0 1  1 1 0 0]~=0; 
        % >> tot.intersects(d) == [1 1 1 1  1 0 0 1  1 0 1 1  1 1 0 0  0 0 1 1  1 1 0 1  1 1 0 0]~=0; 
        %
        % >> tot.intersects(e) == [0 0 1 1  1 1 1 0  1 0 0 0  0 0 0 1  0 0 0 0  0 1 1 0  1 1 1 0]~=0; 
        % >> tot.intersects(f) == [0 0 0 0  1 1 1 0  0 0 0 0  0 0 0 0  0 0 0 0  0 0 1 0  0 0 1 0]~=0; 
        % >> tot.intersects(g) == [0 0 0 0  1 1 1 0  0 0 0 0  0 0 0 0  0 1 0 0  0 0 1 0  0 0 1 1]~=0; 
        % >> tot.intersects(h) == [0 1 1 1  0 0 0 1  0 0 0 0  0 1 0 0  0 0 0 1  1 0 0 1  0 1 0 0]~=0;  
        %
        % >> tot.intersects(i) == [0 0 1 1  1 0 0 0  1 0 0 0  0 0 0 0  0 0 0 0  0 1 0 0  1 1 0 0]~=0; 
        % >> tot.intersects(j) == [0 0 0 0  0 0 0 0  0 0 0 0  0 0 0 0  0 0 0 0  0 0 0 0  0 0 0 0]~=0;                                              
        % >> tot.intersects(k) == [0 1 0 1  0 0 0 0  0 0 1 0  0 1 0 0  0 0 1 0  1 0 0 1  0 1 0 0]~=0;   
        % >> tot.intersects(l) == [0 0 0 1  0 0 0 0  0 0 0 0  0 0 0 0  0 0 0 0  0 0 0 0  0 0 0 0]~=0; 
        %
        % >> tot.intersects(m) == [0 0 1 1  0 0 0 0  0 0 0 0  1 1 0 0  0 0 0 1  1 0 0 0  1 1 0 0]~=0;
        % >> tot.intersects(n) == [0 1 1 1  0 0 0 1  0 0 1 0  1 1 0 0  0 0 1 1  1 0 0 1  1 1 0 0]~=0;
        % >> tot.intersects(o) == [0 0 0 0  0 0 0 0  0 0 0 0  0 0 0 0  0 0 0 0  0 0 0 0  0 0 0 0]~=0;
        % >> tot.intersects(p) == [0 0 0 0  1 0 0 0  0 0 0 0  0 0 0 1  0 0 0 0  0 1 0 0  0 0 1 0]~=0;
        %
        % >> tot.intersects(q) == [0 0 0 0  0 0 0 0  0 0 0 0  0 0 0 0  0 0 0 0  0 0 0 0  0 0 0 0]~=0;
        % >> tot.intersects(r) == [0 0 0 0  0 0 1 0  0 0 0 0  0 0 0 0  0                             A
        % >> tot.intersects(s) == [1 1 0 1  0 0 0 0  0 0 1 0  0 1 0 0  0                             A
        % >> tot.intersects(t) == [0 1 1 1  0 0 0 1  0 0 0 0  1 1 0 0  0                             A
        %                                                                                            A 
        % >> tot.intersects(u) == [1 1 1 1  0 0 0 1  0 0 1 0  1 1 0 0  0                             A
        % >> tot.intersects(v) == [0 0 1 1  1 0 0 0  1 0 0 0  0 0 0 1  0                             A
        % >> tot.intersects(w) == [0 0 0 1  1 1 1 0  0 0 0 0  0 0 0 0  0                             A
        % >> tot.intersects(x) == [0 1 1 1  0 0 0 1  0 0 1 0  0 1 0 0  0                             A
        %                                                                                            A
        % >> tot.intersects(y) == [0 0 1 1  1 0 0 0  1 0 0 0  1 1 0 0  0                             A
        % >> tot.intersects(z) == [0 1 1 1  1 0 0 1  1 0 1 0  1 1 0 0  0                             A
        % >> tot.intersects(aa)== [0 0 0 0  1 1 1 0  0 0 0 0  0 0 0 1  0                             A
        % >> tot.intersects(ab)== [0 0 0 0  0 0 1 0  0 0 0 0  0 0 0 0  0                             A
        % 
        % >> a = Interval(0,0,true,true);
        % >> b = Interval(0,1,true,true);
        % >> c = Interval(1,2,true,true);
        % >> d = Interval(0,2,true,true);
        %
        % >> e = Interval(2,3,true,true);
        % >> f = Interval(3,3,true,true);
        % >> g = Interval(3,4,true,true);
        % >> h = Interval(1,1,true,true);
        %
        % >> i = Interval(2,2,true,true);
        % >> j = Interval(0,0,false,false);
        % >> k = Interval(0,1,false,false);
        % >> l = Interval(1,1,false,false);
        %
        % >> m = Interval(1,2,false,false);
        % >> n = Interval(0,2,false,false);
        % >> o = Interval(2,2,false,false);
        % >> p = Interval(2,3,false,false);
        %
        % >> q = Interval(3,3,false,false);
        % >> r = Interval(3,4,false,false);
        % >> s = Interval(0,1,true,false);
        % >> t = Interval(1,2,true,false);
        %
        % >> u = Interval(0,2,true,false);
        % >> v = Interval(2,3,true,false);
        % >> w = Interval(3,4,true,false);
        % >> x = Interval(0,1,false,true);
        %
        % >> y = Interval(1,2,false,true);
        % >> z = Interval(0,2,false,true);
        % >> aa= Interval(2,3,false,true);
        % >> ab= Interval(3,4,false,true);

        % >> b.intersects(a);
        % >> b.intersects(b);
        % >> b.intersects(c);
        % >> b.intersects(d);
        % >> ~b.intersects(e);
        % >> ~b.intersects(f);
        % >> ~b.intersects(g);
        %
        % >> ~c.intersects(a);
        % >> c.intersects(b);
        % >> c.intersects(c);
        % >> c.intersects(d);
        % >> c.intersects(e);
        % >> ~c.intersects(f);
        % >> ~c.intersects(g);
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
          assert(isa(interval, 'ClosedInterval'));
          assert(length(interval) == 1);
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
          does_intersect = [objs.min] <= [interval.max] & ...
              [interval.min] <= [objs.max];
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

