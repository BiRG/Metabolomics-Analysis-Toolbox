function test_suite = test_GLBIO2013Deconv %#ok<STOUT>
% matlab_xUnit tests excercising some of the non-alignment functions in GLBIO2013Deconv
%
% See test_GLBIO2013Deconv_alignment.m for the alignment functions.
%
% Usage:
%   runtests test_GLBIO2013Deconv 
initTestSuite;

function id = assert_id
% Return the identifier used for assertion failures - this is different
% between different Matlab versions, so I calculate it here
try
    assert(false);
catch ME
    id = ME.identifier;
end

function test_no_arg_constructor %#ok<DEFNU>
% Tests the GLBIO2013Deconv no argument constructor
g = GLBIO2013Deconv;
assertEqual(sort(fields(g)), sort({'peak_picker_name'; 'picked_locations'; 'starting_point_name'; 'starting_point'; 'starting_point_lb'; 'starting_point_ub'; 'peaks'; 'aligned_indices'; 'datum_id'}));
all_fields = fields(g);
for f_idx = 1:length(all_fields)
    assertEqual(g.(all_fields{f_idx}),[]);
end

function test_constructor_bad_starting_point %#ok<DEFNU>
% Tests that calling the constructor with an unknown starting point
% violates an assertion

old_rng = RandStream.getGlobalStream();
RandStream.setGlobalStream(RandStream('mt19937ar','Seed',1288700689));

[spec, peaks] = random_spec_from_nssd_data(7,-1,1,100,1);

fails = @() GLBIO2013Deconv('baby aardvark tree', spec,...
            peaks, 'pp_gold_standard', sort([peaks.location]), 'dsp_not_a_starting_point');
    
assertExceptionThrown(fails, assert_id);        
        
RandStream.setGlobalStream(old_rng);
