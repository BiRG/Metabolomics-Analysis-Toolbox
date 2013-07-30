function test_suite = test_deconvolution_quality %#ok<STOUT>
% matlab_xUnit tests excercising deconvolution_quality
%
% Usage:
%   runtests test_deconvolution_quality 
initTestSuite;

function id = assert_id
% Return the identifier used for assertion failures - this is different
% between different Matlab versions, so I calculate it here
try
    assert(false);
catch ME
    id = ME.identifier;
end


function test_examples %#ok<DEFNU>
% Ensures that examples come out as expected

assertEqual(1.17617678929704539e-06, deconvolution_quality([ 1 100 2 99 3 98 ]));
assertEqual(37.9903399404048514, deconvolution_quality([3     3     1     8     8     9    10]));
assertEqual(3.92310771694772686, deconvolution_quality([3     3     1     8]));
assertEqual(99.9993408456785744, deconvolution_quality([577; 864; 366; 152; 385; 149; 748; 401; 593; 701]));

function test_exceptions %#ok<DEFNU>
% Ensures that code rejects a few known input problems

% Too few items in the residual
f=@() deconvolution_quality([ 1 2 3 ]);
assertExceptionThrown(f, assert_id); 
f=@() deconvolution_quality([ 1 2 ]);
assertExceptionThrown(f, assert_id); 
f=@() deconvolution_quality( 1);
assertExceptionThrown(f, assert_id); 
f=@() deconvolution_quality([ ]);
assertExceptionThrown(f, assert_id); 

% Not a vector
f=@() deconvolution_quality([ 1 2 3; 4 5 6 ]);
assertExceptionThrown(f, assert_id); 

