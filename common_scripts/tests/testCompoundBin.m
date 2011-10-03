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

function testValidMultLotsOfTests %#ok<DEFNU>
% Implements the tests from the original "Examples" section of the comments
% for is_valid_multiplicity_string

% Good strings
assertTrue(CompoundBin.is_valid_multiplicity_string('d'));
assertTrue(CompoundBin.is_valid_multiplicity_string('t'));
assertTrue(CompoundBin.is_valid_multiplicity_string('half of AB d'));
assertTrue(CompoundBin.is_valid_multiplicity_string('m'));
assertTrue(CompoundBin.is_valid_multiplicity_string('m,d'));
assertTrue(CompoundBin.is_valid_multiplicity_string('s,s'));
assertTrue(CompoundBin.is_valid_multiplicity_string('dt'));
assertTrue(CompoundBin.is_valid_multiplicity_string('half of AB d,s'));


% Bad strings
assertFalse(CompoundBin.is_valid_multiplicity_string('xl'));
assertFalse(CompoundBin.is_valid_multiplicity_string('t,'));
assertFalse(CompoundBin.is_valid_multiplicity_string(',t'));
assertFalse(CompoundBin.is_valid_multiplicity_string('rv'));
assertFalse(CompoundBin.is_valid_multiplicity_string('ds'));
assertFalse(CompoundBin.is_valid_multiplicity_string('half of AB ds'));
assertFalse(CompoundBin.is_valid_multiplicity_string(''));


function testHumReadMult %#ok<DEFNU>
% Tests CompoundBin.human_readable_multiplicity
assertEqual(CompoundBin.human_readable_multiplicity('s'),'singlet');
assertEqual(CompoundBin.human_readable_multiplicity('d'),'doublet');
assertEqual(CompoundBin.human_readable_multiplicity('t'),'triplet');
assertEqual(CompoundBin.human_readable_multiplicity('q'),'quartet');
assertEqual(CompoundBin.human_readable_multiplicity('m'), ...
    'multiplet');
assertEqual(CompoundBin.human_readable_multiplicity('half of AB d'), ...
    'half of AB doublet');
assertEqual(CompoundBin.human_readable_multiplicity('m,d'), ...
    'multiplet, doublet');
assertEqual(CompoundBin.human_readable_multiplicity('s,s'), ...
    'singlet, singlet');
assertEqual(CompoundBin.human_readable_multiplicity('dt'), ... 
    'doublet of triplets');
assertEqual(CompoundBin.human_readable_multiplicity('dtq'), ... 
    'doublet of triplet of quartets');
assertEqual(CompoundBin.human_readable_multiplicity('half of AB d,s'), ... 
    'half of AB doublet, singlet');



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

function testCompoundBinConstructorMethylnicotinamide %#ok<DEFNU>
% Test that the constructor constructs what we'd expect for 1-
% methlynicotinamide

in = '1,,1,"1-Methylnicotinamide","X",9.297,9.265,"s",1,,"CH2, H2",699,"X","Lindon, year?","1H",';
c = CompoundBin(CompoundBin.csv_file_header_string,in);

assertEqual(uint64(c.id),uint64(1));
assertFalse(c.was_deleted);
assertEqual(uint64(c.compound_id), uint64(1));
assertEqual(c.compound_name, '1-Methylnicotinamide');
assertTrue(c.is_known_compound);
assertEqual(c.bin.left,9.297);
assertEqual(c.bin.right,9.265);
assertEqual(c.multiplicity, 's');
assertEqual(uint64(c.num_peaks), uint64(1));
assertTrue(isempty(c.j_values));
assertEqual(c.nucleus_assignment, 'CH2, H2');
assertEqual(uint64(c.hmdb_id),uint64(699));
assertTrue(c.chenomix_was_used);
assertEqual(c.literature, 'Lindon, year?');
assertEqual(c.nmr_isotope, '1H');
assertEqual(c.notes, '');

function testGetAsCsvStringHippurate %#ok<DEFNU>
% Test that when an object for bin 3 (hippurate) is converted to csv, the result is the same as the input 
%
% Hippurate 3 has no listed j-value

in ='3,"",4,"hippurate","X",7.857000,7.815000,"d",2,"","CH2, CH6",714,"X","Chemonx/Lindon/Measured","1H","Multiplicity is different in HMDB"';
c = CompoundBin(CompoundBin.csv_file_header_string,in);
out = c.as_csv_string;

assertEqual(in, out);


function testGetAsCsvStringMalate %#ok<DEFNU>
% Test that when an object for bin 6 (malate) is converted to csv, the result is the same as the input 
%
% Malate has two known j-values
in = '6,"",42,"Malate","X",4.335000,4.300000,"dd",4,"10.230000, 2.980000","CH",156,"","","1H","HMDB puts this dd at 4.29 and the range as 4.27-4.32. Needs checking - Eric adapted from old bin-map"';
c = CompoundBin(CompoundBin.csv_file_header_string,in);
out = c.as_csv_string;

assertEqual(in, out);


function testEqualObjObj %#ok<DEFNU>
% Test that object == object works

inH ='3,"",4,"hippurate","X",7.857000,7.815000,"d",2,"","CH2, CH6",714,"X","Chemonx/Lindon/Measured","1H","Multiplicity is different in HMDB"';
inHDel ='3,"X",4,"hippurate","X",7.857000,7.815000,"d",2,"","CH2, CH6",714,"X","Chemonx/Lindon/Measured","1H","Multiplicity is different in HMDB"';
inM = '6,"",42,"Malate","X",4.335000,4.300000,"dd",4,"10.230000, 2.980000","CH",156,"","","1H","HMDB puts this dd at 4.29 and the range as 4.27-4.32. Needs checking - Eric adapted from old bin-map"';
cH = CompoundBin(CompoundBin.csv_file_header_string,inH);
cHDel = CompoundBin(CompoundBin.csv_file_header_string,inHDel);
cM = CompoundBin(CompoundBin.csv_file_header_string,inM);

assertTrue(cH == cH);
assertFalse(cM == cH);
assertFalse(cH == cHDel);

function testEqualObjAry %#ok<DEFNU>
% Test that object == array(object) works

inH ='3,"",4,"hippurate","X",7.857000,7.815000,"d",2,"","CH2, CH6",714,"X","Chemonx/Lindon/Measured","1H","Multiplicity is different in HMDB"';
inHDel ='3,"X",4,"hippurate","X",7.857000,7.815000,"d",2,"","CH2, CH6",714,"X","Chemonx/Lindon/Measured","1H","Multiplicity is different in HMDB"';
inM = '6,"",42,"Malate","X",4.335000,4.300000,"dd",4,"10.230000, 2.980000","CH",156,"","","1H","HMDB puts this dd at 4.29 and the range as 4.27-4.32. Needs checking - Eric adapted from old bin-map"';
cH = CompoundBin(CompoundBin.csv_file_header_string,inH);
cHDel = CompoundBin(CompoundBin.csv_file_header_string,inHDel);
cM = CompoundBin(CompoundBin.csv_file_header_string,inM);

ary = [cH cHDel cM];
assertEqual(cHDel == ary, [false true false]);



function testEqualAryObj %#ok<DEFNU>
% Test that array(object) == object works

inH ='3,"",4,"hippurate","X",7.857000,7.815000,"d",2,"","CH2, CH6",714,"X","Chemonx/Lindon/Measured","1H","Multiplicity is different in HMDB"';
inHDel ='3,"X",4,"hippurate","X",7.857000,7.815000,"d",2,"","CH2, CH6",714,"X","Chemonx/Lindon/Measured","1H","Multiplicity is different in HMDB"';
inM = '6,"",42,"Malate","X",4.335000,4.300000,"dd",4,"10.230000, 2.980000","CH",156,"","","1H","HMDB puts this dd at 4.29 and the range as 4.27-4.32. Needs checking - Eric adapted from old bin-map"';
cH = CompoundBin(CompoundBin.csv_file_header_string,inH);
cHDel = CompoundBin(CompoundBin.csv_file_header_string,inHDel);
cM = CompoundBin(CompoundBin.csv_file_header_string,inM);

ary = [cH cHDel cM];
assertEqual(ary == cH, [true false false]);



function testEqualAryAry %#ok<DEFNU>
% Test that array(object) == array(object) works

inH ='3,"",4,"hippurate","X",7.857000,7.815000,"d",2,"","CH2, CH6",714,"X","Chemonx/Lindon/Measured","1H","Multiplicity is different in HMDB"';
inHDel ='3,"X",4,"hippurate","X",7.857000,7.815000,"d",2,"","CH2, CH6",714,"X","Chemonx/Lindon/Measured","1H","Multiplicity is different in HMDB"';
inM = '6,"",42,"Malate","X",4.335000,4.300000,"dd",4,"10.230000, 2.980000","CH",156,"","","1H","HMDB puts this dd at 4.29 and the range as 4.27-4.32. Needs checking - Eric adapted from old bin-map"';
cH = CompoundBin(CompoundBin.csv_file_header_string,inH);
cHDel = CompoundBin(CompoundBin.csv_file_header_string,inHDel);
cM = CompoundBin(CompoundBin.csv_file_header_string,inM);

ary1 = [cH cHDel cM];
ary2 = [cH cHDel cH];
assertEqual(ary1 == ary2, [true true false]);

