function test_suite = test_eliminate_outlier_bins%#ok<STOUT>
%matlab_xUnit tests excercising eliminate_outlier_bins
%
% Usage:
%   runtests test_eliminate_outlier_bins
initTestSuite;

function testOneBigValue %#ok<DEFNU>
% Check that a bin is elminated if one spectrum has one value that is a big
% outlier.

cols{1}.x = 1:7;
cols{1}.Y=[2,1,0.4;1,0.5,0.2;10,5,200000;20,40,60;10,5,2;1,0.5,0.2;3,1.5,0.6];
cols{2} = cols{1};
cols{2}.Y=[2,5;1,1;10,21;20,39;10,21;1,1;3,5];
use_spectra = {[true, true, true],[true, true]};
use_bins    = [true, true, true, true, true, true, true];
inlier_bins = eliminate_outlier_bins(cols, 47, use_spectra, use_bins, 3);

assertEqual(inlier_bins, [true true false true true true true]);

function testOneBigValueWithEarlierExclusion %#ok<DEFNU>
% Check that a bin is elminated if one spectrum has one value that is a big
% outlier - and that earlier exclusions are left alone.

cols{1}.x = 1:7;
cols{1}.Y=[2,1,0.4;1,0.5,0.2;10,5,200000;20,40,60;10,5,2;1,0.5,0.2;3,1.5,0.6];
cols{2} = cols{1};
cols{2}.Y=[2,5;1,1;10,21;20,39;10,21;1,1;3,5];
use_spectra = {[true, true, true],[true, true]};
use_bins    = [true, true, true, true, true, false, true];
inlier_bins = eliminate_outlier_bins(cols, 47, use_spectra, use_bins, 3);

assertEqual(inlier_bins, [true true false true true false true]);

function testColumnVectorUseBins %#ok<DEFNU>
% Check that correct output is produced even when use_bins is a column
% vector

cols{1}.x = 1:7;
cols{1}.Y=[2,1,0.4;1,0.5,0.2;10,5,200000;20,40,60;10,5,2;1,0.5,0.2;3,1.5,0.6];
cols{2} = cols{1};
cols{2}.Y=[2,5;1,1;10,21;20,39;10,21;1,1;3,5];
use_spectra = {[true, true, true],[true, true]};
use_bins    = [true, true, true, true, true, false, true]';
inlier_bins = eliminate_outlier_bins(cols, 47, use_spectra, use_bins, 3);

assertEqual(inlier_bins, [true true false true true false true]);

function testSingleSpectrum %#ok<DEFNU>
% Check that correct output is produced when only a single spectrum is
% input

cols{1}.x = 1:7;
cols{1}.Y=[2;1;10;20;10;1;3];
use_spectra = {[true, true, true],[true, true]};
use_bins    = [true, true, true, true, true, false, true]';
inlier_bins = eliminate_outlier_bins(cols, 47, use_spectra, use_bins, 3);

assertEqual(inlier_bins, [true true true true true false true]);

function testSingleBin %#ok<DEFNU>
% Check that correct output is generated when only a single bin is given as
% input (no bins should be eliminated)

cols{1}.x = 1:7;
cols{1}.Y=[2,1,0.4;1,0.5,0.2;10,5,200000;20,40,60;10,5,2;1,0.5,0.2;3,1.5,0.6];
cols{2} = cols{1};
cols{2}.Y=[2,5;1,1;10,21;20,39;10,21;1,1;3,5];
use_spectra = {[true, true, true],[true, true]};
use_bins    = [false, false, true, false, false, false, false];
inlier_bins = eliminate_outlier_bins(cols, 47, use_spectra, use_bins, 3);

assertEqual(inlier_bins, [false false true false false false false]);

function testNotEliminateEverything %#ok<DEFNU>
% Check that the routine won't eliminate all bins

cols{1}.x = 1:7;
cols{1}.Y=[2,1,0.4;1,0.5,0.2;10,5,200000;20,40,60;10,5,2;1,0.5,0.2;3,1.5,0.6];
cols{2} = cols{1};
cols{2}.Y=[2,5;1,1;10,21;20,39;10,21;1,1;3,5];
use_spectra = {[true, true, true],[true, true]};
use_bins    = [true, true, true, true, true, false, true];
inlier_bins = eliminate_outlier_bins(cols, 47, use_spectra, use_bins, -3);

assertEqual(inlier_bins, [true true true true true false true]);
