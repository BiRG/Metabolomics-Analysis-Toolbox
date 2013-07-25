function test_suite = test_GLBIO2013_sample_from_kl_divergence_of_dirichlet_belief%#ok<STOUT>
%matlab_xUnit tests excercising GLBIO2013_sample_from_kl_divergence_of_dirichlet_belief
%
% Usage:
%   runtests test_GLBIO2013_sample_from_kl_divergence_of_dirichlet_belief
initTestSuite;

function testFirstSeed %#ok<DEFNU>
% Test examples generated from the first seed
old_rng = RandStream.getGlobalStream();
RandStream.setGlobalStream(RandStream('mt19937ar','Seed',2285939723));
expected = [0.0251335709493795273; 0.00318292042708180623; 0.0919646348178946305; 0.0567803489905464587; 0.154939323858843847; 0.188252232203803382; 0.0646361666284000214; 0.0377320928923714216; 0.283906349453522777; 0.212078374643552059];
actual = GLBIO2013_sample_from_kl_divergence_of_dirichlet_belief([0.1,0.2,0.7],[1,2,3], 10);
assertEqual(expected, actual);

RandStream.setGlobalStream(old_rng);

function testSecondSeed %#ok<DEFNU>
% Test examples generated from the first seed
old_rng = RandStream.getGlobalStream();
RandStream.setGlobalStream(RandStream('mt19937ar','Seed',3497910223));
expected = [1.07091406757945062; 2.5950983149290785; 1.18847444424372761; 0.174384652432903853; 1.11430272450414902; 0.230955225551407906; 0.368838962409812898; 0.221727522479871098; 0.06239645598605148; 0.982297783071875097];
actual = GLBIO2013_sample_from_kl_divergence_of_dirichlet_belief([0.5,0.5],[1,1], 10);
assertEqual(expected, actual);

RandStream.setGlobalStream(old_rng);