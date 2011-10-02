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

function testCompoundBinConstructor %#ok<DEFNU>
% Test that the constructor constructs what we'd expect

in = {1,'',101,'Unobtanium','X',101.1,100.0,...
	't',2,50,'CH5',[],'X','Some refs',...
	'1H','Here are some notes to read'};

c = CompoundBin(in);

assertEqual(c.id,1);

            


