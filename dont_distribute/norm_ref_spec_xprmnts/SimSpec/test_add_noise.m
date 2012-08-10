function test_suite = test_add_noise%#ok<STOUT>
%matlab_xUnit tests excercising add_noise
%
% Usage:
%   runtests test_add_noise
initTestSuite;

function oldRandStr = setRepeatableGen()
oldRandStr = RandStream.getDefaultStream;
randStr=RandStream('mt19937ar','Seed',2877617297);
RandStream.setDefaultStream(randStr);


function test_template_function %#ok<DEFNU>
% Description here
oldRandStr = setRepeatableGen;
RandStream.setDefaultStream(oldRandStr);


function test1Col1Std %#ok<DEFNU>
% 1 Collection perturbed by noise of standard deviation 1
oldRandStr = setRepeatableGen;

f.Y = zeros(2,2);
f = add_noise({f}, 1);

assertElementsAlmostEqual(f{1}.Y, ...
    [-0.883668, 1.66787; 0.193256, 1.24484]', ...
    'absolute', 1e-5);

RandStream.setDefaultStream(oldRandStr);

function test1Col2Std %#ok<DEFNU>
% 1 Collection perturbed by noise of standard deviation 2
oldRandStr = setRepeatableGen;

f.Y = zeros(2,2);
f = add_noise({f}, 2);

assertElementsAlmostEqual(f{1}.Y, ...
    [-1.76734, 3.33574; 0.386512, 2.48968,]', ...
    'absolute', 1e-5);

RandStream.setDefaultStream(oldRandStr);

function test2Col2Std %#ok<DEFNU>
% 1 Collection perturbed by noise of standard deviation 2
oldRandStr = setRepeatableGen;

f.Y = zeros(2,2);
g.Y = 5;
f = add_noise({f,g}, 2);


assertElementsAlmostEqual(f{1}.Y, ...
    [-1.76734, 3.33574; 0.386512, 2.48968,]', ...
    'absolute', 1e-5);

assertElementsAlmostEqual(f{2}.Y, ...
    2.92292, ...
    'absolute', 1e-5);

RandStream.setDefaultStream(oldRandStr);

