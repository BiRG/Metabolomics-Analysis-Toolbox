classdef Interval
    %INTERVAL Represents an interval on the real line
    % 
    % Parameters are the supremum and infimum and whether those are each
    % contained in the interval
    %
    
    properties (SetAccess=private)
        % The infimum of the interval. min <= max. Note that it is only 
        % the infimum if the interval is non-empty. (scalar)
        min
        
        % The supremum of the interval. min <= max. Note that it is only 
        % the supremum if the interval is non-empty. (scalar)
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
        % Creates an interval with the given miniumum and maximum and
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
            x = [objs.max];
            n = [objs.min];
            is_empty = x == n & ~[objs.contains_min]; % No need to look at contains_max if max==min contains_max == contains_min
        end
        
	
        function does_contain = contains(obj, val)
        % Returns true if this ClosedInterval contains val and
        % false otherwise. 
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
        % the test/example items
        %
        % min if exists            0 0 1 0  2 3 3 1  2 - - -  - - - -  - - 0 1  0 2 3 -  - - - - 
        % infimum                  0 0 1 0  2 3 3 1  2 0 0 1  1 0 2 2  3 3 0 1  0 2 3 0  1 0 2 3  
        %
        %             0         -  0 0   0             - -      -          0    0     -    -       
        %             1         |    1 1 |        1      - -  - |          - 1  |     1  - | 
        %             2         2      2 2  2        2        - - - -        -  - 2      2 2 - 
        %             3                     3 3 3                   -  - -        - 3        3 - 
        %             4                         4                        -          -          4  
        %
        % supremum                 0 1 2 2  3 3 4 1  2 0 1 1  2 2 2 3  3 4 1 2  2 3 4 1  2 2 3 4 
        % max if exists            0 1 2 2  3 3 4 1  2 - - -  - - - -  - - - -  - - - 1  2 2 3 4 
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
        % >> tot.intersects(r) == [0 0 0 0  0 0 1 0  0 0 0 0  0 0 0 0  0 1 0 0  0 0 1 0  0 0 0 1]~=0;
        % >> tot.intersects(s) == [1 1 0 1  0 0 0 0  0 0 1 0  0 1 0 0  0 0 1 0  1 0 0 1  0 1 0 0]~=0;
        % >> tot.intersects(t) == [0 1 1 1  0 0 0 1  0 0 0 0  1 1 0 0  0 0 0 1  1 0 0 1  1 1 0 0]~=0;
        %
        % >> tot.intersects(u) == [1 1 1 1  0 0 0 1  0 0 1 0  1 1 0 0  0 0 1 1  1 0 0 1  1 1 0 0]~=0;
        % >> tot.intersects(v) == [0 0 1 1  1 0 0 0  1 0 0 0  0 0 0 1  0 0 0 0  0 1 0 0  1 1 1 0]~=0;
        % >> tot.intersects(w) == [0 0 0 1  1 1 1 0  0 0 0 0  0 0 0 0  0 1 0 0  0 0 1 0  0 0 1 1]~=0;
        % >> tot.intersects(x) == [0 1 1 1  0 0 0 1  0 0 1 0  0 1 0 0  0 0 1 1  1 0 0 1  0 1 0 0]~=0;
        %
        % >> tot.intersects(y) == [0 0 1 1  1 0 0 0  1 0 0 0  1 1 0 0  0 0 0 1  1 1 0 0  1 1 0 0]~=0;
        % >> tot.intersects(z) == [0 1 1 1  1 0 0 1  1 0 1 0  1 1 0 0  0 0 1 1  1 1 0 1  1 1 0 0]~=0;
        % >> tot.intersects(aa)== [0 0 0 0  1 1 1 0  0 0 0 0  0 0 0 1  0 0 0 0  0 1 1 0  0 0 1 0]~=0;
        % >> tot.intersects(ab)== [0 0 0 0  0 0 1 0  0 0 0 0  0 0 0 0  0 1 0 0  0 0 1 0  0 0 0 1]~=0;
          assert(isa(interval, 'Interval'));
          assert(length(interval) == 1);
          assert(~isempty(objs)); % I assume that you can't call this on an empty vector, but I'm just making sure
          %
          % Empty intervals never have a non-empty intersection with another interval.
          %
          % Two non-empty intervals <a,b> <x,y> (I use <> to indicate that 
          % end-point behavior is not specified here) don't intersect in 
          % only two cases: all elements of <a,b> come before all of
          % the elements of <x,y> or all of the elements of <x,y>
          % come before all of the elments of <a,b>.
          %
          % Let q and r be intervals. The statement "all of the elements of
          % q come before all of the elements of r" implies 4 different
          % inequalities depending on whether q and r contain their
          % supremum and infimum respectively. Let Q be the supremum of q
          % and R be the infimum of r. Further let qq and rr be arbitrary
          % elements of q and r for the sake of demonstration
          % Q in q | R in r | Inequality
          % -------+--------+-----------------
          %    F   |    F   | Q <= R  (qq <  Q <= R <  rr so qq < rr)
          %    F   |    T   | Q <= R  (qq <  Q <= R <= rr so qq < rr)
          %    T   |    F   | Q <= R  (qq <= Q <= R <  rr so qq < rr)
          %    T   |    T   | Q <  R  (qq <= Q <  R <= rr so qq < rr)
          %
          % So we see that unless both intervals contain their "adjacent"
          % endpoints Q <= R is sufficient to ensure no intersection. 
          %
          % Let C=<a,b> and W=<x,y>. No intersection means C before W OR W
          % before C. Intersection is its opposite. NOT (C before W or W
          % before C). 
          %
          % Distributing, we get equation 1: 
          % C intersects W == NOT(C before W) AND NOT(W before C).
          % 
          % Translating into supremum and infimum
          %
          % NOT(C before W) means:
          %    if C contains supremum(C) and W contains infimum(W)
          %       NOT(supremum(C) < infimum(W))
          %    else 
          %       NOT(supremum(C) <= infimum(W))
          %    end
          %
          % If we remove the NOTs, we get:
          %    if C contains supremum(C) and W contains infimum(W)
          %       infimum(W) <= supremum(C)
          %    else 
          %       infimum(W) < supremum(C)
          %    end
          %
          %
          % When we swap the roles of C and W we get the second half of the
          % AND in equation 1:
          %
          %    if W contains supremum(W) and C contains infimum(C)
          %       infimum(C) <= supremum(W)
          %    else 
          %       infimum(C) < supremum(W)
          %    end
          %
          % Now, we can combine the two conditions
          % If we remove the NOTs, we get:
          %    if C contains supremum(C) and W contains infimum(W)
          %       if W contains supremum(W) and C contains infimum(C)
          %          infimum(C) <= supremum(W) & infimum(W) <= supremum(C)
          %       else 
          %          infimum(C) <  supremum(W) & infimum(W) <= supremum(C)
          %       end
          %    else 
          %       if W contains supremum(W) and C contains infimum(C)
          %          infimum(C) <= supremum(W) & infimum(W) < supremum(C)
          %       else 
          %          infimum(C) <  supremum(W) & infimum(W) < supremum(C)
          %       end
          %    end
          %
          %
          %    if O contains supremum(O) and I contains infimum(I)
          %       if I contains supremum(I) and O contains infimum(O)
          %          infimum(O) <= supremum(I) & infimum(I) <= supremum(O)
          %       else 
          %          infimum(O) <  supremum(I) & infimum(I) <= supremum(O)
          %       end
          %    else 
          %       if I contains supremum(I) and O contains infimum(O)
          %          infimum(O) <= supremum(I) & infimum(I) < supremum(O)
          %       else 
          %          infimum(O) <  supremum(I) & infimum(I) < supremum(O)
          %       end
          %    end
          % This analysis is an expansion and generalization of: 
          % http://world.std.com/~swmcd/steven/tech/interval.html
          o_cn = [objs.contains_min]; % contains infimum
          o_cs = [objs.contains_max]; % contains supremum
          i_cn = [interval.contains_min];
          i_cs = [interval.contains_max];
          no = [objs.min]; % iNfimum  Obj
          so = [objs.max]; % Supremum Obj
          ni = [interval.min]; % iNfimum  Interval
          si = [interval.max]; % Supremum Interval

          does_intersect = ...
              ~[objs.is_empty] & ~[interval.is_empty] & ( ...
             (   o_cs & i_cn  & i_cs & o_cn    & no <= si & ni <= so) | ... % first condition
             (   o_cs & i_cn  & ~(i_cs & o_cn) & no <  si & ni <= so) | ... % second condition
             ( ~(o_cs & i_cn) & i_cs & o_cn    & no <= si & ni <  so) | ... % third condition
             ( ~(o_cs & i_cn) & ~(i_cs & o_cn) & no <  si & ni <  so));     % final condition
        end
                
        function result = intersection(objs, interval)
        % result(i) is the intersection of objs(i) and interval
        %
        % ----------------------------------------------------------------
        % Examples
        % ----------------------------------------------------------------
        %
        % >> a = Interval(-2,-1, false, false).intersect(Interval(0,3,false,false))
        %
        % a = Interval(0,0, false, false)
        %
          mins = max([objs.min],[interval.min]); %#ok<CPROP>
          maxes = min([objs.max],[interval.max]); %#ok<CPROP>
          contains_mins  = objs.contains(mins) & interval.contains(mins);
          contains_maxes = objs.contains(maxes) & interval.contains(maxes);
          maxes(maxes < mins) = mins(maxes < mins);
          result = arrayfun(@Interval, mins, maxes, contains_mins, contains_maxes, 'UniformOutput',false);
          result = [result{:}];
        end

        function str=char(obj)
        % Return a human-readable string representation of this
        % object. (Matlab's version of toString, however, Matlab
        % doesn't call it automatically)
          if length(obj) == 1
            str = sprintf('Interval(%g,%g,%d,%d)', obj.min, obj.max, ...
                obj.contains_min, obj.contains_max);
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
        
        function are_eq = eq(a, b)
        % Implements the == operator for Interval objects
        % are_eq(i) == a(i) has same min and max and endpoints as b(i)
        %
        % NOTE: this means some empty intervals are not equal to one
        % another - (0,0) is not the same as (1,1) under this equality.
        %
        % ----------------------------------------------------------------
        % Examples
        % ----------------------------------------------------------------
        %
          are_eq = [a.min] == [b.min] & [a.max] == [b.max] & ...
              [a.contains_min] == [b.contains_min] & ...
              [a.contains_max] == [b.contains_max];
        end
    end
    
end

