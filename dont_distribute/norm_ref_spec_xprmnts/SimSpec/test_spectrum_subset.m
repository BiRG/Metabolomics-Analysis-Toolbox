function test_suite = test_spectrum_subset%#ok<STOUT>
%matlab_xUnit tests excercising spectrum_subset
%
% Usage:
%   runtests test_spectrum_subset
initTestSuite;

function [f,g] = sample_spec
% Return two sample spectra
% f(i,j) = i+2*j 
f.Y = repmat((1:10)', 1,5);
f.Y = f.Y + repmat(2.*(1:5),10,1); 
f = add_fake_spec_fields(f, 'f', 100);

% g(i,j) = i+20*j
g.Y = repmat((1:10)', 1,6);
g.Y = g.Y + repmat(20.*(1:6),10,1); 
g = add_fake_spec_fields(g, 'g', 50);


function testSimpleCase %#ok<DEFNU>
% The case I used in bench-testing
[f,g] = sample_spec;

expected.Y= ...
    [3, 7, 101, 121; ...
    4, 8, 102, 122; ...
    5, 9, 103, 123; ...
    6, 10, 104, 124; ...
    7, 11, 105, 125; ...
    8, 12, 106, 126; ...
    9, 13, 107, 127; ...
    10, 14, 108, 128; ...
    11, 15, 109, 129; ...
    12, 16, 110, 130];
expected.base_sample_id = [100, 300, 250, 300];
expected.classification = {'Classification for sample id 100', 'Classification for sample id 300', 'Classification for sample id 250', 'Classification for sample id 300'};
expected.sample_description = {'Description for sample id 100', 'Description for sample id 300', 'Description for sample id 250', 'Description for sample id 300'};
expected.sample_id = [100, 300, 250, 300];
expected.species = {'Species for sample id 100', 'Species for sample id 300', 'Species for sample id 250', 'Species for sample id 300'}; 
expected.subject_id = [100, 300, 250, 300];
expected.time = [100, 300, 250, 300];
expected.units_of_weight = {'stone', 'stone', 'stone', 'stone'};
expected.weight = [100, 300, 250, 300];
expected.x = [-1; 0.444444; 1.88889; 3.33333; 4.77778; 6.22222; 7.66667; 9.11111; 10.5556; 12];
expected.num_samples = 4;
expected.input_names = {'Collection ID', 'Type', 'Description', 'Processing log', 'Base sample ID', 'Time', 'Classification', 'Sample ID', 'Subject ID', 'Sample Description', 'Weight', 'Units of weight', 'Species'};
expected.formatted_input_names = {'collection_id', 'type', 'description', 'processing_log', 'base_sample_id', 'time', 'classification', 'sample_id', 'subject_id', 'sample_description', 'weight', 'units_of_weight', 'species'};
expected.collection_id = 'f+g';
expected.type = 'SpectraCollection';
expected.description = 'Collection created as subset of two collections with ids f and g';
expected.processing_log = 'Created by joining collection id f and g.';
expected = {expected};

actual = spectrum_subset([1,3],f, [5,6],g);

assertEqual(fieldnames(actual{1}), fieldnames(expected{1}));
fns={'collection_id', 'type', 'description', 'processing_log', 'base_sample_id', 'time', 'classification', 'sample_id', 'subject_id', 'sample_description', 'weight', 'units_of_weight', 'species'};
for i = 1:length(fns)
    q = fns{i};
    assertEqual(actual{1}.(q), expected{1}.(q), sprintf('Diff in field %s', q));
end


function testExceptionDiffX %#ok<DEFNU>
% Ensure that different x vectors for the two spectra are rejected
[f,g] = sample_spec;
g.x = (1:length(f.x))';

assertExceptionThrown(@() spectrum_subset([1,3],f, [5,6],g), ...
    'spectrum_subset:one_x');

function testExceptionInputsAreStruct %#ok<DEFNU>
% Ensure that exceptions are thrown when non-structs are passed for f and g
[f,g] = sample_spec;
assertExceptionThrown(@() spectrum_subset([1,3],{f}, [5,6],g), ...
    'spectrum_subset:struct');
assertExceptionThrown(@() spectrum_subset([1,3],f, [5,6],{g}), ...
    'spectrum_subset:struct');
assertExceptionThrown(@() spectrum_subset([1,3],{f}, [5,6],{g}), ...
    'spectrum_subset:struct');
assertExceptionThrown(@() spectrum_subset([1,3],5, [5,6],g), ...
    'spectrum_subset:struct');
assertExceptionThrown(@() spectrum_subset([1,3],f, [5,6],7), ...
    'spectrum_subset:struct');

function testExceptionHasRequiredFields %#ok<DEFNU>
% Ensure that inputs without the right collection of fields are rejected
req_fields = {'time', 'classification', 'sample_id', 'subject_id', ...
    'sample_description', 'weight', 'units_of_weight', 'species', ...
    'base_sample_id','Y','x','collection_id'};
[f,g]=sample_spec;
for i = 1:length(req_fields)
    ff=rmfield(f,req_fields{i});
    gg=rmfield(g,req_fields{i});
    assertExceptionThrown(@() spectrum_subset([1,3],ff, [5,6],g), ...
        'spectrum_subset:fields');
    assertExceptionThrown(@() spectrum_subset([1,3],f, [5,6],gg), ...
        'spectrum_subset:fields');
    assertExceptionThrown(@() spectrum_subset([1,3],ff, [5,6],gg), ...
        'spectrum_subset:fields');
end
