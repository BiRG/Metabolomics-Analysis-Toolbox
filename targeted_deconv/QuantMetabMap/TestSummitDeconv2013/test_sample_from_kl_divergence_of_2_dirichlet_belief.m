function test_suite = test_sample_from_kl_divergence_of_2_dirichlet_belief %#ok<STOUT>
%matlab_xUnit tests excercising sample_from_kl_divergence_of_2_dirichlet_belief
%
% Usage:
%   runtests test_sample_from_kl_divergence_of_2_dirichlet_belief
initTestSuite;

function testFirstSeed %#ok<DEFNU>
% Test examples generated from the first seed
old_rng = RandStream.getGlobalStream();
RandStream.setGlobalStream(RandStream('mt19937ar','Seed',2285939723));
expected = [0.145000456599631511; 0.13515767671095702; 0.136633961140914528; 0.150836472052194526; 0.115501621139295463; 0.0677451560028482225; 0.13362145670457759; 0.151476667902091744; 0.133231316066103334; 0.0812563651847380553];
actual = sample_from_kl_divergence_of_2_dirichlet_belief([10,20,70],[100,200,300], 10);
assertEqual(expected, actual);

RandStream.setGlobalStream(old_rng);

function testSecondSeed %#ok<DEFNU>
% Test examples generated from the first seed
old_rng = RandStream.getGlobalStream();
RandStream.setGlobalStream(RandStream('mt19937ar','Seed',3497910223));
expected = [3.32254352851448775; 0.528404218884088284; 0.585271448714964615; 0.117380101047158514; 0.526136750022773159; 0.876667939156432929; 0.0579358274202196322; 0.998178794964621918; 0.692903191153450448; 0.00331987556342003276];
actual = sample_from_kl_divergence_of_2_dirichlet_belief([0.5,0.5],[1,1], 10);
assertEqual(expected, actual);

RandStream.setGlobalStream(old_rng);
