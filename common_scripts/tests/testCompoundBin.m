function test_suite = testCompoundBin %#ok<STOUT>
%matlab_xUnit tests excercising CompoundBin
%
% Usage:
%   runtest testCompoundBin
initTestSuite;

function dir=data_dir
% Return the directory in which this test case data is located
thisfile = mfilename('fullpath');
dir=regexprep(thisfile,'/[^/]*$','');

function testReadAll %#ok<DEFNU>
% Tests whether load_metabmap (which uses CompoundBin) reads the correct
% number of entries from a test file

map = load_metabmap(fullfile(data_dir, 'testCompoundBin.01.readall.csv'));
assertEqual(length(map),78);
    
function testParseCSVBoolX %#ok<DEFNU>
% Test if CompoundBin.parse_csv_bool parses an x input correctly

assertTrue(CompoundBin.parse_csv_bool('X',''));
assertTrue(CompoundBin.parse_csv_bool('x',''));

function testParseCSVBoolNull %#ok<DEFNU>
% Test if CompoundBin.parse_csv_bool parses an "" input correctly

assertFalse(CompoundBin.parse_csv_bool('',''));

function testParseCSVBoolBlank %#ok<DEFNU>
% Test if CompoundBin.parse_csv_bool parses an " " input correctly

assertFalse(CompoundBin.parse_csv_bool(' ',''));

function testParseCSVBoolGarbage %#ok<DEFNU>
% Test if CompoundBin.parse_csv_bool parses an "garbage" input correctly

f=@() CompoundBin.parse_csv_bool('bad','some input var');
assertExceptionThrown(f,'CompoundBin:bad_bool');

function testValidMultABDoubletNoConcat %#ok<DEFNU>
% Test that 'half of AB d' concatenated with something is not valid

assertFalse(CompoundBin.is_valid_multiplicity_string('half of AB ds'));
            
function testCompoundBinConstructor %#ok<DEFNU>
% Test that the constructor constructs what we'd expect

in = ['1,"",101,"Unobtanium","X",'...
    '101.1,100.0,'...
	'"t",2,"50","CH5",,"X","Some refs",'...
	'"1H","Here are some notes to read"'];

c = CompoundBin(CompoundBin.csv_file_header_string,in);

assertEqual(uint64(c.id),uint64(1));
assertFalse(c.was_deleted);
assertEqual(uint64(c.compound_id), uint64(101));
assertEqual(c.compound_name, 'Unobtanium');
assertTrue(c.is_known_compound);
assertEqual(c.bin.left,101.1);
assertEqual(c.bin.right,100.0);
assertEqual(c.multiplicity, 't');
assertEqual(uint64(c.num_peaks), uint64(2));
assertEqual(c.j_values, 50);
assertEqual(c.nucleus_assignment, 'CH5');
assertTrue(isnan(c.hmdb_id));
assertTrue(c.chenomix_was_used);
assertEqual(c.literature, 'Some refs');
assertEqual(c.nmr_isotope, '1H');
assertEqual(c.notes, 'Here are some notes to read');

function testCompoundBinConstructorRevTruth %#ok<DEFNU>
% Test that the constructor constructs what we'd expect when the truth
% values of the booleans are reversed

in = ['1,"X",101,"Unobtanium"," ",'...
    '101.1,100.0,'...
	'"t",2,"50","CH5",," ","Some refs",'...
	'"1H","Here are some notes to read"'];

c = CompoundBin(CompoundBin.csv_file_header_string,in);

assertEqual(uint64(c.id),uint64(1));
assertTrue(c.was_deleted);
assertEqual(uint64(c.compound_id), uint64(101));
assertEqual(c.compound_name, 'Unobtanium');
assertFalse(c.is_known_compound);
assertEqual(c.bin.left,101.1);
assertEqual(c.bin.right,100.0);
assertEqual(c.multiplicity, 't');
assertEqual(uint64(c.num_peaks), uint64(2));
assertEqual(c.j_values, 50);
assertEqual(c.nucleus_assignment, 'CH5');
assertTrue(isnan(c.hmdb_id));
assertFalse(c.chenomix_was_used);
assertEqual(c.literature, 'Some refs');
assertEqual(c.nmr_isotope, '1H');
assertEqual(c.notes, 'Here are some notes to read');




