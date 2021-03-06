function test_suite = testBinomialExperiment %#ok<STOUT>
%matlab_xUnit tests excercising BinomialExperiment
%
% Usage:
%   runtests testBinomialExperiment
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

c=BinomialExperiment(1,2,3,0.5);
assertTrue(isa(c, 'BinomialExperiment'));
assertEqual(c.successes,1);
assertEqual(c.failures, 2);
assertEqual(c.priorAlpha,3);
assertEqual(c.priorBeta,0.5);

c=BinomialExperiment(0,0,0,0);
assertTrue(isa(c, 'BinomialExperiment'));
assertEqual(c.successes, 0);
assertEqual(c.failures,  0);
assertEqual(c.priorAlpha,0);
assertEqual(c.priorBeta, 0);

f=@() BinomialExperiment(10,1);
assertExceptionThrown(f, assert_id);

f=@() BinomialExperiment(-1,1,1,1);
assertExceptionThrown(f, assert_id);
f=@() BinomialExperiment(1,-0.1,1,1);
assertExceptionThrown(f, assert_id);
f=@() BinomialExperiment(1,1,-10,1);
assertExceptionThrown(f, assert_id);
f=@() BinomialExperiment(1,1,0,-2);
assertExceptionThrown(f, assert_id);

f=@() BinomialExperiment([0,0],0,0,0);
assertExceptionThrown(f, assert_id);
f=@() BinomialExperiment(0,[0;0],0,0);
assertExceptionThrown(f, assert_id);
f=@() BinomialExperiment(0,0,[0,1],0);
assertExceptionThrown(f, assert_id);
f=@() BinomialExperiment(0,0,0,[1,1]);
assertExceptionThrown(f, assert_id);

function testProb %#ok<DEFNU>
% Tests whether the correct probability estimates are calculated
assertEqual(BinomialExperiment(1,2,0.5,0.5).prob, 0.25);
assertTrue(isnan(BinomialExperiment(0,0,0.5,0.5).prob));
assertTrue(isnan(BinomialExperiment(1,1,0,0).prob));
assertEqual(BinomialExperiment(2,2,1,1).prob, 0.5);

assertTrue(isnan(BinomialExperiment(0,0,0.3,0.5).prob));
assertEqual(BinomialExperiment(0.5,1,0,0).prob, 0);
assertEqual(BinomialExperiment(0.5,2,0,0).prob, 0);
assertEqual(BinomialExperiment(1,0.5,0,0).prob, 1);
assertEqual(BinomialExperiment(5,0.25,0,0).prob, 1);
assertEqual(BinomialExperiment(1,2,0,0).prob, 0);
assertEqual(BinomialExperiment(2,1,0,0).prob, 1);

function testCI %#ok<DEFNU>
% Tests whether the correct shortest ci is generated by the
% shortestCredibleInterval method. Note that I only use the uniform prior
% because that is what I have available to compare against online. The way
% the code works, there is not likely to be any changes caused by different
% priors.

% Note that the following interval is on the uniform distribution, and is
% not unique however, there is no shorter interval, so I count it correct.
i = BinomialExperiment(0,0,1,1).shortestCredibleInterval(0.95);
assertEqual(i.min, 0);
assertEqual(i.max, 0.95);

% The rest of the intervals match their online cousin
i = BinomialExperiment(0,1,1,1).shortestCredibleInterval(0.95);
assertEqual(i.min, 0);
assertEqual(i.max, 0.776393202250020953);

i = BinomialExperiment(1,0,1,1).shortestCredibleInterval(0.95);
assertElementsAlmostEqual(i.min, 0.223606797749979019);
assertEqual(i.max, 1);

i = BinomialExperiment(1,9999,1,1).shortestCredibleInterval(0.95);
assertElementsAlmostEqual(i.min, 4.22436540261094561e-06);
assertElementsAlmostEqual(i.max, 0.000476367771384372612);

i = BinomialExperiment(10,9990,1,1).shortestCredibleInterval(0.999);
assertElementsAlmostEqual(i.min, 0.000281246144933201803);
assertElementsAlmostEqual(i.max, 0.00244175761018746405);

i = BinomialExperiment(100,100,1,1).shortestCredibleInterval(0.98);
assertElementsAlmostEqual(i.min, 0.418605372460687131);
assertElementsAlmostEqual(i.max, 0.581394627539312703);

function testChar %#ok<DEFNU>
% Tests whether the char function for producing human readable output
% produces the correct output

assertEqual(BinomialExperiment(100,10,1,1).char, ...
    'BinomialExperiment(Succ=100, Fail=10, Uniform Prior)');

assertEqual(BinomialExperiment(3,2,0,0).char, ...
    'BinomialExperiment(Succ=3, Fail=2, Haldane Prior)');

assertEqual(BinomialExperiment(0,20,0.5,0.5).char, ...
    'BinomialExperiment(Succ=0, Fail=20, Jeffreys Prior)');

assertEqual(BinomialExperiment(0,20,0.3,0.1).char, ...
    'BinomialExperiment(Succ=0, Fail=20, Beta(0.3, 0.1) Prior)');

function testTrials %#ok<DEFNU>
% Tests whether the trials property is set correctly
assertEqual(BinomialExperiment(100,10,1,1).trials, 110);
assertEqual(BinomialExperiment(3,2,0,0).trials, 5);
assertEqual(BinomialExperiment(0,0,2,1.5).trials, 0);

function testWithMoreTrials %#ok<DEFNU>
% Tests that adding trials works as expected
b=BinomialExperiment(100,10,1,1).withMoreTrials(7,10);
assertEqual(b.successes, 107);
assertEqual(b.failures, 13);
assertEqual(b.priorAlpha, 1);
assertEqual(b.priorBeta, 1);

b=BinomialExperiment(3,5,0,0.5).withMoreTrials(0,9);
assertEqual(b.successes, 3);
assertEqual(b.failures, 14);
assertEqual(b.priorAlpha, 0);
assertEqual(b.priorBeta, 0.5);

function testProbThatParamInRange %#ok<DEFNU>
b=BinomialExperiment(100,10,1,1);
assertElementsAlmostEqual(b.probThatParamInRange(0.1,0.2), 1.43823367065437452e-58);
                                              
assertElementsAlmostEqual(b.probThatParamInRange(0.88,0.98),0.791592556244451906);

b=BinomialExperiment(3,10,0,0.5);
assertElementsAlmostEqual(b.probThatParamInRange(0.1,0.2),0.34817007670689748);
assertElementsAlmostEqual(b.probThatParamInRange(0.88,0.98),1.22246170963791201e-08);
