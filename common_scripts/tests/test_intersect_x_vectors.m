function test_suite = test_intersect_x_vectors%#ok<STOUT>
%matlab_xUnit tests excercising intersect_x_vectors
%
% Usage:
%   runtests test_intersect_x_vectors
initTestSuite;

function testEx01 %#ok<DEFNU>
% Runs the first example from the documentation. (Tests normal operation with 3 collections)
in={cell2struct({[1, 2, 3]; [1; 2; 3]}, {'x'; 'Y'}, 1), ...
     cell2struct({[0, 1, 2, 3, 4]; [0; 2; 4; 6; 8]}, {'x'; 'Y'}, 1), ...
     cell2struct({[0, 1, 3, 4]; [0; 3; 9; 12]}, {'x'; 'Y'}, 1)};
expected={cell2struct({[1, 3]; [1; 3]; 'Intersected x coordinate vectors.'}, {'x'; 'Y'; 'processing_log'}, 1), ...
     cell2struct({[1, 3]; [2; 6]; 'Intersected x coordinate vectors.'}, {'x'; 'Y'; 'processing_log'}, 1), ...
     cell2struct({[1, 3]; [3; 9]; 'Intersected x coordinate vectors.'}, {'x'; 'Y'; 'processing_log'}, 1)};
 
assertEqual(intersect_x_vectors(in), expected);

function testEx02 %#ok<DEFNU>
% Runs the second example from the documentation. (Tests normal operation with 2 collections)
in={ cell2struct({[0, 1, 2, 3, 4]; [0; 2; 4; 6; 8]},  {'x'; 'Y'}, 1), ...
     cell2struct({[0, 1,    3, 4]; [0; 3;    9; 12]}, {'x'; 'Y'}, 1)};
expected={ cell2struct({[0, 1, 3, 4]; [0; 2; 6; 8]; 'Intersected x coordinate vectors.'},  {'x'; 'Y'; 'processing_log'}, 1), ...
           cell2struct({[0, 1, 3, 4]; [0; 3; 9; 12]; 'Intersected x coordinate vectors.'}, {'x'; 'Y'; 'processing_log'}, 1)};
 
assertEqual(intersect_x_vectors(in), expected);

function testEx03 %#ok<DEFNU>
% Runs the third example from the documentation. (Tests normal operation
% with 2 collections, one of which has more than one spectrum)
in = { cell2struct({[0, 1, 2, 3, 4]; [0;   2;   4; 6;    8]},     {'x'; 'Y'}, 1), ...
       cell2struct({[0, 1,    3, 4]; [0,0; 3,8;    9,24; 12,32]}, {'x'; 'Y'}, 1)};
expected = { cell2struct({[0, 1, 3, 4]; [0;   2;   6;    8]; 'Intersected x coordinate vectors.'},     {'x'; 'Y'; 'processing_log'}, 1), ...
             cell2struct({[0, 1, 3, 4]; [0,0; 3,8; 9,24; 12,32]; 'Intersected x coordinate vectors.'}, {'x'; 'Y'; 'processing_log'}, 1)};
 
assertEqual(intersect_x_vectors(in), expected);

function testEx04 %#ok<DEFNU>
% Runs the fourth example from the documentation. (Tests when there are
% no spectra in the collections.)
 
assertEqual(intersect_x_vectors({}), {});

