function test_suite = test_normalization_error%#ok<STOUT>
%matlab_xUnit tests excercising normalization_error
%
% Usage:
%   runtests test_normalization_error
initTestSuite;

function testNoErrorCase%#ok<DEFNU>
% Does it give no error when there is an exact multiple? 

[rmse,rmse_log]=normalization_error([1,2,3,4,5,6,7,8,9,10],...
    [10,20,30,40,50,60,70,80,90,100]);
assertElementsAlmostEqual([rmse, rmse_log], [0,0]);

function testErrorCase %#ok<DEFNU>
% Test a hand-calculated case where the multiplication coeficient is 10 but
% there have been errors of +/- 10% added.
[rmse,rmse_log]=normalization_error([1,2,3,4,5,6,7,8,9,10],...
    [ 9 18 33 44 45 54 63 88 99 110]);
assertElementsAlmostEqual([rmse, rmse_log], ...
    [5.679765863109170,0.100335347731076]);

function testExceptionRowVec %#ok<DEFNU>
% Ensure that an exception is thown when one of the input arguments is not 
% a row vector
assertExceptionThrown(@() normalization_error([1;2;3],[1,2,3]), ...
    'normalization_error:row_vec');
assertExceptionThrown(@() normalization_error([1,2,3],[1;2;3]), ...
    'normalization_error:row_vec');
assertExceptionThrown(@() normalization_error([1;2;3],[1;2;3]), ...
    'normalization_error:row_vec');

function testExceptionSameSize %#ok<DEFNU>
% Ensure that an exception is thown when the input arguments have different
% sizes
assertExceptionThrown(@() normalization_error([1,3],[1,2,3]), ...
    'normalization_error:same_size');
