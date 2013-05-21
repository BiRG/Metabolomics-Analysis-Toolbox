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
