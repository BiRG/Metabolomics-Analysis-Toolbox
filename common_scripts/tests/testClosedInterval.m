function test_suite = testClosedInterval %#ok<STOUT>
%matlab_xUnit tests excercising ClosedInterval
%
% Usage:
%   runtests testClosedInterval
initTestSuite;

function id = assert_id
% Return the identifier used for assertion failures - this is different
% between different Matlab versions, so I calculate it here
try
    assert(false);
catch ME
    id = ME.identifier;
end

function testConstructor %#ok<DEFNU>
% Tests the inputs of the constructor and if it fails appropriately

c=ClosedInterval(-1,1);
assertTrue(isa(c, 'ClosedInterval'));
assertEqual(c.min,-1);
assertEqual(c.max, 1);

d=ClosedInterval(0.57,2);
assertTrue(isa(d, 'ClosedInterval'));
assertEqual(d.min,0.57);
assertEqual(d.max,2);

e=ClosedInterval(0.2,0.2);
assertTrue(isa(e, 'ClosedInterval'));
assertEqual(e.min,0.2);
assertEqual(e.max,0.2);

f=ClosedInterval(); %Ensure default constructor is implemented
assertTrue(isa(f, 'ClosedInterval'));

f=@() ClosedInterval(1,-1);
assertExceptionThrown(f, assert_id);
f=@() ClosedInterval([-1,1],1);
assertExceptionThrown(f, assert_id);
f=@() ClosedInterval(2,[-1,1]);
assertExceptionThrown(f, assert_id);
f=@() ClosedInterval([-1,1]);
assertExceptionThrown(f, assert_id);

function testLength %#ok<DEFNU>
% Tests that the length function operates as expected
assertEqual(ClosedInterval(-1,1).length,2);
assertEqual(ClosedInterval(0.57,2).length,2-0.57);
assertEqual(ClosedInterval(0.2,0.2).length,0);

function testContains %#ok<DEFNU>
% Tests that the contains operations operates as expected
assertTrue(ClosedInterval(-1,1).contains(1));
assertTrue(ClosedInterval(-1,1).contains(-1));
assertTrue(ClosedInterval(-1,1).contains(0.2));
assertTrue(ClosedInterval(-1,1).contains(-0.1));
assertFalse(ClosedInterval(-1,1).contains(1.1));
assertFalse(ClosedInterval(-1,1).contains(-100));

assertTrue(ClosedInterval(3.444,7.221).contains(7.221));
assertTrue(ClosedInterval(3.444,7.221).contains(3.444));
assertTrue(ClosedInterval(3.444,7.221).contains(3.6));
assertTrue(ClosedInterval(3.444,7.221).contains(4));
assertFalse(ClosedInterval(3.444,7.221).contains(8.212));
assertFalse(ClosedInterval(3.444,7.221).contains(-7.22500));

function testChar %#ok<DEFNU>
assertEqual(ClosedInterval(-1,1).char,'ClosedInterval(-1,1)');
assertEqual(ClosedInterval(0.57,2).char,'ClosedInterval(0.57,2)');
assertEqual(ClosedInterval(0.2,0.2).char,'ClosedInterval(0.2,0.2)');

function testIntersects %#ok<DEFNU>
% Use the items from the examples for ClosedInterval.intersects to verify
% the performance
a = ClosedInterval(0,0);
b = ClosedInterval(0,1);
c = ClosedInterval(1,2);
d = ClosedInterval(0,2);
e = ClosedInterval(2,3);
f = ClosedInterval(3,3);
g = ClosedInterval(3,4);
tot = [a b c d e f g];  
assertTrue(a.intersects(a));
assertTrue(a.intersects(b));
assertFalse(a.intersects(c));
assertTrue(a.intersects(d));
assertFalse(a.intersects(e));
assertFalse(a.intersects(f));
assertFalse(a.intersects(g));
assertEqual(tot.intersects(a), [true,true,false,true,false,false,false]);
%
assertTrue(b.intersects(a));
assertTrue(b.intersects(b));
assertTrue(b.intersects(c));
assertTrue(b.intersects(d));
assertFalse(b.intersects(e));
assertFalse(b.intersects(f));
assertFalse(b.intersects(g));
assertEqual(tot.intersects(b), [true,true,true,true,false,false,false]);
%
assertFalse(c.intersects(a));
assertTrue(c.intersects(b));
assertTrue(c.intersects(c));
assertTrue(c.intersects(d));
assertTrue(c.intersects(e));
assertFalse(c.intersects(f));
assertFalse(c.intersects(g));
assertEqual(tot.intersects(c), [false,true,true,true,true,false,false]);
%
assertTrue(d.intersects(a));
assertTrue(d.intersects(b));
assertTrue(d.intersects(c));
assertTrue(d.intersects(d));
assertTrue(d.intersects(e));
assertFalse(d.intersects(f));
assertFalse(d.intersects(g));
assertEqual(tot.intersects(d), [true,true,true,true,true,false,false]);
%
assertFalse(e.intersects(a));
assertFalse(e.intersects(b));
assertTrue(e.intersects(c));
assertTrue(e.intersects(d));
assertTrue(e.intersects(e));
assertTrue(e.intersects(f));
assertTrue(e.intersects(g));
assertEqual(tot.intersects(e), [false,false,true,true,true,true,true]);
%
assertFalse(f.intersects(a));
assertFalse(f.intersects(b));
assertFalse(f.intersects(c));
assertFalse(f.intersects(d));
assertTrue(f.intersects(e));
assertTrue(f.intersects(f));
assertTrue(f.intersects(g));
assertEqual(tot.intersects(f), [false,false,false,false,true,true,true]);
%
assertFalse(g.intersects(a));
assertFalse(g.intersects(b));
assertFalse(g.intersects(c));
assertFalse(g.intersects(d));
assertTrue(g.intersects(e));
assertTrue(g.intersects(f));
assertTrue(g.intersects(g));
assertEqual(tot.intersects(g), [false,false,false,false,true,true,true]);

function testIntersection %#ok<DEFNU>
% Test the intersection method using the examples from the documentation

a = ClosedInterval(0,0);
b = ClosedInterval(0,1);
c = ClosedInterval(1,2);
d = ClosedInterval(0,2);
e = ClosedInterval(2,3);
f = ClosedInterval(3,3);
g = ClosedInterval(3,4);
tot = [a b c d e f g];
assertEqual(a.intersection(a), a);
assertEqual(a.intersection(b), a);
assertEqual(a.intersection(d), a);
a_intersectors = tot(tot.intersects(a));
assertEqual(a_intersectors.intersection(a), [a,a,a]);
%
assertEqual(b.intersection(a), a);
assertEqual(b.intersection(b), b);
assertEqual(b.intersection(c), ClosedInterval(1,1));
assertEqual(b.intersection(d), b);
b_intersectors = tot(tot.intersects(b));
assertEqual(b_intersectors.intersection(b), [a, b, ClosedInterval(1,1), b]);
%
assertEqual(c.intersection(b), ClosedInterval(1,1));
assertEqual(c.intersection(c), c);
assertEqual(c.intersection(d), c);
assertEqual(c.intersection(e), ClosedInterval(2,2));
c_intersectors = tot(tot.intersects(c));
assertEqual(c_intersectors.intersection(c), [ClosedInterval(1,1),c,c,ClosedInterval(2,2)]);
%
assertEqual(d.intersection(a), a);
assertEqual(d.intersection(b), b);
assertEqual(d.intersection(c), c);
assertEqual(d.intersection(d), d);
assertEqual(d.intersection(e), ClosedInterval(2,2));
d_intersectors = tot(tot.intersects(d));
assertEqual(d_intersectors.intersection(d), [a,b,c,d,ClosedInterval(2,2)]);
%
assertEqual(e.intersection(c), ClosedInterval(2,2));
assertEqual(e.intersection(d), ClosedInterval(2,2));
assertEqual(e.intersection(e), e);
assertEqual(e.intersection(f), f);
assertEqual(e.intersection(g), f);
e_intersectors = tot(tot.intersects(e));
assertEqual(e_intersectors.intersection(e), [ClosedInterval(2,2),ClosedInterval(2,2),e,f,f]);
%
assertEqual(f.intersection(e), f);
assertEqual(f.intersection(f), f);
assertEqual(f.intersection(g), f);
f_intersectors = tot(tot.intersects(f));
assertEqual(f_intersectors.intersection(f), [f,f,f]);
%
assertEqual(g.intersection(e), f);
assertEqual(g.intersection(f), f);
assertEqual(g.intersection(g), g);
g_intersectors = tot(tot.intersects(g));
assertEqual(g_intersectors.intersection(g), [f,f,g]);

function testEq %#ok<DEFNU>
% Test the == operator

% Test single closed interval objects
assertTrue(ClosedInterval(1,1) == ClosedInterval(1,1));
assertTrue(~(ClosedInterval(0,1) == ClosedInterval(1,1)));
assertTrue(~(ClosedInterval(1,2) == ClosedInterval(1,1)));
assertTrue(~(ClosedInterval(2,2) == ClosedInterval(1,1)));

% Test equal sized vectors of two closed intervals
assertTrue(all([ClosedInterval(1,1),ClosedInterval(2,2)]==[ClosedInterval(1,1),ClosedInterval(2,2)]));
assertTrue(~any([ClosedInterval(1,1),ClosedInterval(2,2)]==[ClosedInterval(0,1),ClosedInterval(0,1)]));
assertTrue(~any([ClosedInterval(1,1),ClosedInterval(1,1)]==[ClosedInterval(1,2),ClosedInterval(2,2)]));

% Test vectors of two closed intervals versus a single closed interval
assertTrue(all([ClosedInterval(1,1),ClosedInterval(1,1)]==ClosedInterval(1,1)));
assertEqual(([ClosedInterval(1,2),ClosedInterval(1,1)]==ClosedInterval(1,1)), [false, true]);

% Test a single closed interval versus vectors of two closed intervals 
assertTrue(all(ClosedInterval(1,1)==[ClosedInterval(1,1),ClosedInterval(1,1)]));
assertEqual((ClosedInterval(1,1)==[ClosedInterval(1,2),ClosedInterval(1,1)]), [false, true]);
