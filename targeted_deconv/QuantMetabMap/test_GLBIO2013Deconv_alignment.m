function test_suite = test_GLBIO2013Deconv_alignment %#ok<STOUT>
% matlab_xUnit tests excercising the alignment functions in GLBIO2013Deconv 
%
% Usage:
%   runtests test_GLBIO2013Deconv_alignment 
initTestSuite;

function assertSingleAssignment(l1, l2, exponent, correct)
% Assert that l2(correct) is the calculated minimum assignment from l1 to l2 with the given lp norm exponent
[a,c]=GLBIO2013Deconv.l_p_norm_assignment(l1,l2, exponent);
assertEqual(a, correct);
assertEqual(c, sum(abs(l1(a > 0)-l2(a(a > 0))).^exponent));


function test_location_alignment %#ok<DEFNU>
% Check that lists of locations are aligned correctly and with the correct costs.

exponent = 2;
assertSingleAssignment([1,2,3], [3.2,0.2  ,3.1], exponent, [2,3,1]);
assertSingleAssignment([1,2,3], [3.1,2.8  ,1.8], exponent, [3,2,1]);
assertSingleAssignment([1,2,3], [3.1,2.99 ,1.8], exponent, [3,2,1]);
assertSingleAssignment([1,2,3], [3.1,3.101,1.8], exponent, [3,1,2]);
assertSingleAssignment([1,2,3,4],[3.1,3.101,1.8], exponent, [0,3,1,2]);
assertSingleAssignment([1,2,3,4],[1,2,3], exponent, [1,2,3,0]);
assertSingleAssignment([],[1,2,3], exponent, zeros(1,0));
assertSingleAssignment([1,2,3,4],[], exponent, [0,0,0,0]);
assertSingleAssignment([1,2,3,4],2, exponent, [0,1,0,0]);
assertSingleAssignment(3, 2, exponent, 1);
assertSingleAssignment(3, [1,4,7], exponent, 2);
assertSingleAssignment(3, [1,4], exponent, 2);
assertSingleAssignment(2, [1,4], exponent, 1);
assertSingleAssignment([1,2,3], [1,2,3], exponent, [1,2,3]);
assertSingleAssignment([2,1,3], [1,2,3], exponent, [2,1,3]);
assertSingleAssignment([2,3,1], [1,2,3], exponent, [2,3,1]);
assertSingleAssignment([3,2,1], [1,2,3], exponent, [3,2,1]);
assertSingleAssignment([3,1,2], [1,2,3], exponent, [3,1,2]);
assertSingleAssignment([1,3,2], [1,2,3], exponent, [1,3,2]);

exponent = 1;
assertSingleAssignment([1,2,3], [3.8,2.3  ,2.1], exponent, [2,3,1]);
assertSingleAssignment([1,2,3], [3.2,0.2  ,3.1], exponent, [2,1,3]);
assertSingleAssignment([1,2,3], [3.1,2.8  ,1.8], exponent, [3,2,1]);
assertSingleAssignment([1,2,3], [3.1,2.99 ,1.8], exponent, [3,2,1]);
assertSingleAssignment([1,2,3], [3.1,3.101,1.8], exponent, [3,1,2]);
assertSingleAssignment([1,2,3,4],[3.1,3.101,1.8], exponent, [0,3,1,2]);
assertSingleAssignment([1,2,3,4],[1,2,3], exponent, [1,2,3,0]);
assertSingleAssignment([],[1,2,3], exponent, zeros(1,0));
assertSingleAssignment([1,2,3,4],[], exponent, [0,0,0,0]);
assertSingleAssignment([1,2,3,4],2, exponent, [0,1,0,0]);
assertSingleAssignment(3, 2, exponent, 1);
assertSingleAssignment(3, [1,4,7], exponent, 2);
assertSingleAssignment(3, [1,4], exponent, 2);
assertSingleAssignment(2, [1,4], exponent, 1);
assertSingleAssignment([1,2,3], [1,2,3], exponent, [1,2,3]);
assertSingleAssignment([2,1,3], [1,2,3], exponent, [2,1,3]);
assertSingleAssignment([2,3,1], [1,2,3], exponent, [2,3,1]);
assertSingleAssignment([3,2,1], [1,2,3], exponent, [3,2,1]);
assertSingleAssignment([3,1,2], [1,2,3], exponent, [3,1,2]);
assertSingleAssignment([1,3,2], [1,2,3], exponent, [1,3,2]);

exponent = 0.5;
assertSingleAssignment([1,2,3], [3.8,2.3  ,2.1], exponent, [2,3,1]);
assertSingleAssignment([1,2,3], [3.2,0.2  ,3.1], exponent, [2,1,3]);
assertSingleAssignment([1,2,3], [3.1,2.8  ,1.8], exponent, [3,2,1]);
assertSingleAssignment([1,2,3], [3.1,2.99 ,1.8], exponent, [1,3,2]);
assertSingleAssignment([1,2,3], [3.1,3.101,1.8], exponent, [2,3,1]);
assertSingleAssignment([1,2,3,4],[3.1,3.101,1.8], exponent, [0,3,1,2]);
assertSingleAssignment([1,2,3,4],[1,2,3], exponent, [1,2,3,0]);
assertSingleAssignment([],[1,2,3], exponent, zeros(1,0));
assertSingleAssignment([1,2,3,4],[], exponent, [0,0,0,0]);
assertSingleAssignment([1,2,3,4],2, exponent, [0,1,0,0]);
assertSingleAssignment(3, 2, exponent, 1);
assertSingleAssignment(3, [1,4,7], exponent, 2);
assertSingleAssignment(3, [1,4], exponent, 2);
assertSingleAssignment(2, [1,4], exponent, 1);
assertSingleAssignment([1,2,3], [1,2,3], exponent, [1,2,3]);
assertSingleAssignment([2,1,3], [1,2,3], exponent, [2,1,3]);
assertSingleAssignment([2,3,1], [1,2,3], exponent, [2,3,1]);
assertSingleAssignment([3,2,1], [1,2,3], exponent, [3,2,1]);
assertSingleAssignment([3,1,2], [1,2,3], exponent, [3,1,2]);
assertSingleAssignment([1,3,2], [1,2,3], exponent, [1,3,2]);





function test_peak_alignment %#ok<DEFNU>
% Chech that sets of peaks are aligned correctly
%TODO: stub
