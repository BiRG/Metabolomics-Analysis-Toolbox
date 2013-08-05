function test_suite = test_random_spec_from_nssd_data %#ok<STOUT>
% matlab_xUnit tests excercising some parts of random_spec_from_nssd_data
%
% Usage:
%   runtests test_random_spec_from_nssd_data 
initTestSuite;

function id = assert_id
% Return the identifier used for assertion failures - this is different
% between different Matlab versions, so I calculate it here
try
    assert(false);
catch ME
    id = ME.identifier;
end

function test_num_peaks_less_than_0 %#ok<DEFNU>
% Check that gives error when less than 0 peaks requested
old_rng = RandStream.getGlobalStream();
RandStream.setGlobalStream(RandStream('mt19937ar','Seed',1288700689));

f=@() random_spec_from_nssd_data(-1,-1,1,100,1);
assertExceptionThrown(f, assert_id);

RandStream.setGlobalStream(old_rng);

function test_num_peaks_equal_to_0 %#ok<DEFNU>
% Check that gives flat spectrum when 0 peaks selected.
old_rng = RandStream.getGlobalStream();
RandStream.setGlobalStream(RandStream('mt19937ar','Seed',1288700689));
noise = randn(100,1);
RandStream.setGlobalStream(RandStream('mt19937ar','Seed',1288700689));

% Just noise
[s,p] = random_spec_from_nssd_data(0,-1,1,100,1);
assertEqual(noise , s.Y);
assertEqual(fliplr(linspace(-1,1,100)), s.x);
assertEqual(length(p), 0);

% 0 when noise mag is 0
[s,p] = random_spec_from_nssd_data(0,-1,1,100,0);
assertEqual(zeros(1,100)', s.Y);
assertEqual(fliplr(linspace(-1,1,100)), s.x);
assertEqual(length(p), 0);


RandStream.setGlobalStream(old_rng);

