function test_suite = test_Interval%#ok<STOUT>
%matlab_xUnit tests excercising Interval
%
% Usage:
%   runtests test_Interval
initTestSuite;


function test_constructor %#ok<DEFNU>
% Test examples from constructor
%
% Creates a closed interval containing all points from -1
% to 1, including -1 and 1 themeselves.
a = Interval(-1,1, true, true);
assertEqual(a.min, -1);
assertEqual(a.max, 1);
assertTrue(a.contains_min);
assertTrue(a.contains(-1));
assertTrue(a.contains_max);
assertTrue(a.contains(1));

% Creates a half-open interval containing all points from -1
% to 1, not including -1 but including 1.
a = Interval(-1,1, false, true);
assertEqual(a.min, -1);
assertEqual(a.max, 1);
assertTrue(~a.contains_min);
assertTrue(~a.contains(-1));
assertTrue(a.contains_max);
assertTrue(a.contains(1));

% Creates an interval containing all points from -1
% to 1, not including either endpoint
a = Interval(-1,1, false, false);
assertEqual(a.min, -1);
assertEqual(a.max, 1);
assertTrue(~a.contains_min);
assertTrue(~a.contains(-1));
assertTrue(~a.contains_max);
assertTrue(~a.contains(1));

% Creates an interval containing all points from -1
% to 1, excluding 1 but including -1
a = Interval(-1,1, true, false);
assertEqual(a.min, -1);
assertEqual(a.max, 1);
assertTrue(a.contains_min);
assertTrue(a.contains(-1));
assertTrue(~a.contains_max);
assertTrue(~a.contains(1));

% Creates an empty interval
a = Interval(1,1, false, false);
assertEqual(a.min, 1);
assertEqual(a.max, 1);
assertTrue(~a.contains_min);
assertTrue(~a.contains_max);
assertTrue(~a.contains(1));

% Creates an interval containing only the point 1
a = Interval(1,1, true, true);
assertEqual(a.min, 1);
assertEqual(a.max, 1);
assertTrue(a.contains_min);
assertTrue(a.contains(1));
assertTrue(a.contains_max);
assertTrue(a.contains(1));

% Error: Interval:zero_length_end_points
f = @() Interval(1,1, false, true);
assertExceptionThrown(f, 'Interval:zero_length_end_points');

function test_is_empty %#ok<DEFNU>
% Try some test examples to verify the behavior of is_empty
a = Interval(0,0,true,true);
b = Interval(0,1,true,true);
d = Interval(0,1,false,true);
f = Interval(0,1,true,false);
g = Interval(0,0,false,false);
h = Interval(0,1,false,false);
i = Interval(1,1,false,false);
tot=[a,b,d,f,g,h,i];
assertFalse(a.is_empty);
assertFalse(b.is_empty);
assertFalse(d.is_empty);
assertFalse(f.is_empty);
assertTrue(g.is_empty);
assertFalse(h.is_empty);
assertTrue(i.is_empty);
assertEqual([tot.is_empty], [0,0,0,0,1,0,1]~=0);

function test_length %#ok<DEFNU>
% Uses the examples from intersects to check that the length function works
a = Interval(0,0,true,true);
assertEqual(a.length,0);
b = Interval(0,1,true,true);
assertEqual(b.length,1);
c = Interval(1,2,true,true);
assertEqual(c.length,1);
d = Interval(0,2,true,true);
assertEqual(d.length,2);
e = Interval(2,3,true,true);
assertEqual(e.length,1);
a = Interval(3,3,true,true);
assertEqual(a.length,0);
a = Interval(3,4,true,true);
assertEqual(a.length,1);
a = Interval(1,1,true,true);
assertEqual(a.length,0);
a = Interval(2,2,true,true);
assertEqual(a.length,0);
a = Interval(0,0,false,false);
assertEqual(a.length,0);
a = Interval(0,1,false,false);
assertEqual(a.length,1);
a = Interval(1,1,false,false);
assertEqual(a.length,0);
a = Interval(1,2,false,false);
assertEqual(a.length,1);
a = Interval(0,2,false,false);
assertEqual(a.length,2);
a = Interval(2,2,false,false);
assertEqual(a.length,0);
a = Interval(2,3,false,false);
assertEqual(a.length,1);
a = Interval(3,3,false,false);
assertEqual(a.length,0);
a = Interval(3,4,false,false);
assertEqual(a.length,1);
a = Interval(0,1,true,false);
assertEqual(a.length,1);
a = Interval(1,2,true,false);
assertEqual(a.length,1);
a = Interval(0,2,true,false);
assertEqual(a.length,2);
a = Interval(2,3,true,false);
assertEqual(a.length,1);
a = Interval(3,4,true,false);
assertEqual(a.length,1);
a = Interval(0,1,false,true);
assertEqual(a.length,1);
a = Interval(1,2,false,true);
assertEqual(a.length,1);
a = Interval(0,2,false,true);
assertEqual(a.length,2);
a = Interval(2,3,false,true);
assertEqual(a.length,1);
a = Interval(3,4,false,true);
assertEqual(a.length,1);


function test_contains %#ok<DEFNU>
% Try some examples to ensure that contains works as expected
a = Interval(0,0,false,false);
assertTrue(~a.contains(-1));
assertTrue(~a.contains(0));
assertTrue(~a.contains(0.5));
assertTrue(~a.contains(1));
assertTrue(~a.contains(2));

a = Interval(1,1,false,false);
assertTrue(~a.contains(-1));
assertTrue(~a.contains(0));
assertTrue(~a.contains(0.5));
assertTrue(~a.contains(1));
assertTrue(~a.contains(2));

a = Interval(1,1,true,true);
assertTrue(~a.contains(-1));
assertTrue(~a.contains(0));
assertTrue(~a.contains(0.5));
assertTrue(a.contains(1));
assertTrue(~a.contains(2));

a = Interval(0,1,false,false);
assertTrue(~a.contains(-1));
assertTrue(~a.contains(0));
assertTrue(a.contains(0.5));
assertTrue(~a.contains(1));
assertTrue(~a.contains(2));

a = Interval(0,1,true,false);
assertTrue(~a.contains(-1));
assertTrue(a.contains(0));
assertTrue(a.contains(0.5));
assertTrue(~a.contains(1));
assertTrue(~a.contains(2));

a = Interval(0,1,true,true);
assertTrue(~a.contains(-1));
assertTrue(a.contains(0));
assertTrue(a.contains(0.5));
assertTrue(a.contains(1));
assertTrue(~a.contains(2));

a = Interval(0,1,false,true);
assertTrue(~a.contains(-1));
assertTrue(~a.contains(0));
assertTrue(a.contains(0.5));
assertTrue(a.contains(1));
assertTrue(~a.contains(2));



function test_intersects %#ok<DEFNU>
% Uses the test cases from the example section (though, thinking about it,
% I could have made an automatic test case using the contains relation)
a = Interval(0,0,true,true);
b = Interval(0,1,true,true);
c = Interval(1,2,true,true);
d = Interval(0,2,true,true);
e = Interval(2,3,true,true);
f = Interval(3,3,true,true);
g = Interval(3,4,true,true);
h = Interval(1,1,true,true);
i = Interval(2,2,true,true);
j = Interval(0,0,false,false);
k = Interval(0,1,false,false);
l = Interval(1,1,false,false);
m = Interval(1,2,false,false);
n = Interval(0,2,false,false);
o = Interval(2,2,false,false);
p = Interval(2,3,false,false);
q = Interval(3,3,false,false);
r = Interval(3,4,false,false);
s = Interval(0,1,true,false);
t = Interval(1,2,true,false);
u = Interval(0,2,true,false);
v = Interval(2,3,true,false);
w = Interval(3,4,true,false);
x = Interval(0,1,false,true);
y = Interval(1,2,false,true);
z = Interval(0,2,false,true);
aa= Interval(2,3,false,true);
ab= Interval(3,4,false,true);
%
assertTrue(a.intersects(a));
assertTrue(a.intersects(b));
assertFalse(a.intersects(c));
assertTrue(a.intersects(d));
assertFalse(a.intersects(e));
assertFalse(a.intersects(f));
assertFalse(a.intersects(g));
assertFalse(a.intersects(h));
%
assertFalse(a.intersects(i));
assertFalse(a.intersects(j));
assertFalse(a.intersects(k));
assertFalse(a.intersects(l));
assertFalse(a.intersects(m));
assertFalse(a.intersects(n));
assertFalse(a.intersects(o));
assertFalse(a.intersects(p));
%
assertFalse(a.intersects(q));
assertFalse(a.intersects(r));
assertTrue(a.intersects(s));
assertFalse(a.intersects(t));
assertTrue(a.intersects(u));
assertFalse(a.intersects(v));
assertFalse(a.intersects(w));
assertFalse(a.intersects(x));
%
assertFalse(a.intersects(y));
assertFalse(a.intersects(z));
assertFalse(a.intersects(aa));
assertFalse(a.intersects(ab));
%
% Below is a tableau I used to help calculate the intersections for
% the test/example items
%
% min if exists                 0 0 1 0  2 3 3 1  2 - - -  - - - -  - - 0 1  0 2 3 -  - - - - 
% infimum                       0 0 1 0  2 3 3 1  2 0 0 1  1 0 2 2  3 3 0 1  0 2 3 0  1 0 2 3  
%
%             0              -  0 0   0             - -      -          0    0     -    -       
%             1              |    1 1 |        1      - -  - |          - 1  |     1  - | 
%             2              2      2 2  2        2        - - - -        -  - 2      2 2 - 
%             3                          3 3 3                   -  - -        - 3        3 - 
%             4                              4                        -          -          4  
%
% supremum                      0 1 2 2  3 3 4 1  2 0 1 1  2 2 2 3  3 4 1 2  2 3 4 1  2 2 3 4 
% max if exists                 0 1 2 2  3 3 4 1  2 - - -  - - - -  - - - -  - - - 1  2 2 3 4 
                         tot = [a b c d  e f g h  i j k l  m n o p  q r s t  u v w x  y z aa ab];
assertEqual(tot.intersects(a), [1 1 0 1  0 0 0 0  0 0 0 0  0 0 0 0  0 0 1 0  1 0 0 0  0 0 0 0]~=0);
assertEqual(tot.intersects(b), [1 1 1 1  0 0 0 1  0 0 1 0  0 1 0 0  0 0 1 1  1 0 0 1  0 1 0 0]~=0); 
assertEqual(tot.intersects(c), [0 1 1 1  1 0 0 1  1 0 0 0  1 1 0 0  0 0 0 1  1 1 0 1  1 1 0 0]~=0); 
assertEqual(tot.intersects(d), [1 1 1 1  1 0 0 1  1 0 1 0  1 1 0 0  0 0 1 1  1 1 0 1  1 1 0 0]~=0); 
%
assertEqual(tot.intersects(e), [0 0 1 1  1 1 1 0  1 0 0 0  0 0 0 1  0 0 0 0  0 1 1 0  1 1 1 0]~=0); 
assertEqual(tot.intersects(f), [0 0 0 0  1 1 1 0  0 0 0 0  0 0 0 0  0 0 0 0  0 0 1 0  0 0 1 0]~=0); 
assertEqual(tot.intersects(g), [0 0 0 0  1 1 1 0  0 0 0 0  0 0 0 0  0 1 0 0  0 0 1 0  0 0 1 1]~=0); 
assertEqual(tot.intersects(h), [0 1 1 1  0 0 0 1  0 0 0 0  0 1 0 0  0 0 0 1  1 0 0 1  0 1 0 0]~=0);  
%
assertEqual(tot.intersects(i), [0 0 1 1  1 0 0 0  1 0 0 0  0 0 0 0  0 0 0 0  0 1 0 0  1 1 0 0]~=0); 
assertEqual(tot.intersects(j), [0 0 0 0  0 0 0 0  0 0 0 0  0 0 0 0  0 0 0 0  0 0 0 0  0 0 0 0]~=0);                                              
assertEqual(tot.intersects(k), [0 1 0 1  0 0 0 0  0 0 1 0  0 1 0 0  0 0 1 0  1 0 0 1  0 1 0 0]~=0);   
assertEqual(tot.intersects(l), [0 0 0 0  0 0 0 0  0 0 0 0  0 0 0 0  0 0 0 0  0 0 0 0  0 0 0 0]~=0); 
%
assertEqual(tot.intersects(m), [0 0 1 1  0 0 0 0  0 0 0 0  1 1 0 0  0 0 0 1  1 0 0 0  1 1 0 0]~=0);
assertEqual(tot.intersects(n), [0 1 1 1  0 0 0 1  0 0 1 0  1 1 0 0  0 0 1 1  1 0 0 1  1 1 0 0]~=0);
assertEqual(tot.intersects(o), [0 0 0 0  0 0 0 0  0 0 0 0  0 0 0 0  0 0 0 0  0 0 0 0  0 0 0 0]~=0);
assertEqual(tot.intersects(p), [0 0 0 0  1 0 0 0  0 0 0 0  0 0 0 1  0 0 0 0  0 1 0 0  0 0 1 0]~=0);
%
assertEqual(tot.intersects(q), [0 0 0 0  0 0 0 0  0 0 0 0  0 0 0 0  0 0 0 0  0 0 0 0  0 0 0 0]~=0);
assertEqual(tot.intersects(r), [0 0 0 0  0 0 1 0  0 0 0 0  0 0 0 0  0 1 0 0  0 0 1 0  0 0 0 1]~=0);
assertEqual(tot.intersects(s), [1 1 0 1  0 0 0 0  0 0 1 0  0 1 0 0  0 0 1 0  1 0 0 1  0 1 0 0]~=0);
assertEqual(tot.intersects(t), [0 1 1 1  0 0 0 1  0 0 0 0  1 1 0 0  0 0 0 1  1 0 0 1  1 1 0 0]~=0);
%
assertEqual(tot.intersects(u), [1 1 1 1  0 0 0 1  0 0 1 0  1 1 0 0  0 0 1 1  1 0 0 1  1 1 0 0]~=0);
assertEqual(tot.intersects(v), [0 0 1 1  1 0 0 0  1 0 0 0  0 0 0 1  0 0 0 0  0 1 0 0  1 1 1 0]~=0);
assertEqual(tot.intersects(w), [0 0 0 0  1 1 1 0  0 0 0 0  0 0 0 0  0 1 0 0  0 0 1 0  0 0 1 1]~=0);
assertEqual(tot.intersects(x), [0 1 1 1  0 0 0 1  0 0 1 0  0 1 0 0  0 0 1 1  1 0 0 1  0 1 0 0]~=0);
%
assertEqual(tot.intersects(y), [0 0 1 1  1 0 0 0  1 0 0 0  1 1 0 0  0 0 0 1  1 1 0 0  1 1 0 0]~=0);
assertEqual(tot.intersects(z), [0 1 1 1  1 0 0 1  1 0 1 0  1 1 0 0  0 0 1 1  1 1 0 1  1 1 0 0]~=0);
assertEqual(tot.intersects(aa),[0 0 0 0  1 1 1 0  0 0 0 0  0 0 0 1  0 0 0 0  0 1 1 0  0 0 1 0]~=0);
assertEqual(tot.intersects(ab),[0 0 0 0  0 0 1 0  0 0 0 0  0 0 0 0  0 1 0 0  0 0 1 0  0 0 0 1]~=0);


function test_intersection_consistent_with_contains %#ok<DEFNU>
% Loops through a number of intervals on the Integers and tests
% whether intersection is consistent with contains.
for first_infimum = [0,1,3,5]
    for first_supremum = first_infimum:5
        for first_contains_min = 0:1
            for first_contains_max = 0:1
                % skip all single-point intervals where the containment disagrees
                if first_infimum ~= first_supremum || (first_infimum == first_supremum && first_contains_min == first_contains_max)
                    first = Interval(first_infimum, first_supremum, first_contains_min == 0, first_contains_max == 0);
                    % Look at only second intervals on most important points
                    % from the first interval: point before first, first point, 
                    % midpoint, last point, and point after last 
                    second_points = unique([first_infimum,first_supremum, ...
                        max(first_infimum-1,0), min(first_supremum+1,0), ...
                        round((first_infimum+first_supremum) / 2)],'R2012a');
                    for second_infimum_idx = 1:length(second_points)
                        second_infimum = second_points(second_infimum_idx);
                        for second_supremum_idx = second_infimum_idx:length(second_points)
                            second_supremum = second_points(second_supremum_idx);
                            for second_contains_min = 0:1
                                for second_contains_max = 0:1
                                    % skip all single-point intervals where the containment disagrees
                                    if second_infimum ~= second_supremum || (second_infimum == second_supremum && second_contains_min == second_contains_max)
                                        second = Interval(second_infimum, second_supremum, second_contains_min == 0, second_contains_max == 0);
                                        intersection = first.intersection(second);
                                        for test_point = 0:0.5:5
                                            assertEqual(first.contains(test_point) ...
                                                && second.contains(test_point), ...
                                                intersection.contains(test_point), ...
                                                sprintf(['%s intersect %s at '...
                                                'point %g had wrong '...
                                                'containment.'], first.char(),...
                                                second.char(), test_point));
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

function test_intersection_of_multiple_intervals %#ok<DEFNU>
% Checks that intersections of multiple intervals come out as expected

a = Interval(0,5,false,true);
b = Interval([0,1,2],[0,1,2],[true,true,true],[true,true,true]);
c = Interval([0,1,2],[1,2,3],[true,true,true],[true,true,true]);
d = [ Interval(0,0,0,0), Interval(1,1,1,1), Interval(2,2,1,1) ];
e = Interval([0,1,2],[1,2,3],[false,true,true],[true,true,true]);
assertEqual(b.intersection(a), d);
assertEqual(b.intersection(c), b);
assertEqual(a.intersection(b), d);
assertEqual(c.intersection(b), b);
assertEqual(a.intersection(c), e);

function test_char %#ok<DEFNU>
% Tests output of char function
a = Interval(0,5,false,true);
b = Interval([0,1,2],[0,1,2],[true,true,true],[true,true,true]);
c = Interval([0,1,2],[1,2,3],[true,true,true],[true,true,true]);
assertEqual(a.char(), 'Interval(0,5,0,1)');
assertEqual(b.char(), '[ Interval(0,0,1,1), Interval(1,1,1,1), Interval(2,2,1,1) ]');
assertEqual(c.char(), '[ Interval(0,1,1,1), Interval(1,2,1,1), Interval(2,3,1,1) ]');

function test_eq %#ok<DEFNU>
a = Interval(0,5,false,true);
b = Interval([0,1,2],[0,1,2],[true,true,true],[true,true,true]);
c = Interval([0,1,2],[1,2,3],[true,true,true],[true,true,true]);
d = [ Interval(0,0,0,0), Interval(1,1,1,1), Interval(2,2,1,1) ];
e = Interval([0,1,2],[1,2,3],[false,true,true],[true,true,true]);
f = Interval(0,5,true,false);
assertTrue(a==a);
assertFalse(a==f);
assertTrue(all(b==b));
assertEqual(b==d, [false, true, true])
assertTrue(~any(b==c));
assertTrue(all(c==c));
assertEqual(c==e, [false, true, true]);
