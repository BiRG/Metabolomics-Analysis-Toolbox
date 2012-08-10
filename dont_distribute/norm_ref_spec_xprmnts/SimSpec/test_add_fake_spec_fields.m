function test_suite = test_add_fake_spec_fields%#ok<STOUT>
%matlab_xUnit tests excercising add_fake_spec_fields
%
% Usage:
%   runtests test_add_fake_spec_fields
initTestSuite;

function testSimpleCase %#ok<DEFNU>
% The case I used in bench-testing

s.Y=[1,2; 3,4; 5,6];

expected = cell2struct({[1, 2; 3, 4; 5, 6]; ...
    {'Collection ID', 'Type', 'Description', 'Processing log', ...
    'Base sample ID', 'Time', 'Classification', 'Sample ID', ...
    'Subject ID', 'Sample Description', 'Weight', 'Units of weight', ...
    'Species'}; ...
    {'collection_id', 'type', 'description', 'processing_log', ...
    'base_sample_id', 'time', 'classification', 'sample_id', ...
    'subject_id', 'sample_description', 'weight', 'units_of_weight', ...
    'species'}; ...
    'Hey'; ...
    'SpectraCollection'; ...
    'Description for col id Hey.'; ...
    'Added fake fields to col id Hey.'; ...
    2; ...
    [2, 4]; [2, 4]; [2, 4]; [2, 4]; [2, 4]; [-1; 5.5; 12]; ...
    {'stone', 'stone'}; ...
    {'Classification for sample id 2', 'Classification for sample id 4'}; ...
    {'Description for sample id 2', 'Description for sample id 4'}; ...
    {'Species for sample id 2', 'Species for sample id 4'}}, ...
    ...
    ...
    {'Y'; 'input_names'; 'formatted_input_names'; 'collection_id'; ...
    'type'; 'description'; 'processing_log'; 'num_samples'; ...
    'time'; 'sample_id'; 'subject_id'; 'weight'; 'base_sample_id'; ...
    'x'; 'units_of_weight'; 'classification'; 'sample_description'; ...
    'species'}, 1);

assertEqual(add_fake_spec_fields(s, 'Hey', 2), expected);

function testExceptionWhenNoY %#ok<DEFNU>
% Ensure exception is thrown when Y field is absent
s.x = [1;2;3];
f = @() add_fake_spec_fields(s, 'Hey', 2);
assertExceptionThrown(f, 'add_fake_spec_fields:cant_fake_y');
