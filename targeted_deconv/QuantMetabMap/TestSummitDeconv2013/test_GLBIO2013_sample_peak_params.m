function test_suite = test_GLBIO2013_sample_peak_params %#ok<STOUT>
%matlab_xUnit tests excercising GLBIO2013_sample_peak_params
%
% Usage:
%   runtests test_GLBIO2013_sample_peak_params
initTestSuite;

function testFirstSeed %#ok<DEFNU>
% Test examples generated from the first seed
old_rng = RandStream.getGlobalStream();
RandStream.setGlobalStream(RandStream('mt19937ar','Seed',2285939723));
expected_area = [0.000455465167320337602, 0.00283372546300850008, 5.48463335672862309e-06, 0.00285321671544267689, 0.00107912373977725484, 0.00346771282470378613, 0.000944073280512421694];
expected_height = [0.138002254598869417, 0.140076854286452612, 0.00073119204559806035, 0.817099018266628896, 0.351120513226838737, 1.00018104608378833, 0.129637234087246145];
expected_width = [0.00232335448925882152, 0.0164649545566358177, 0.00553825322897061496, 0.00245546253300162531, 0.00232786101318629719, 0.00220721516668261931, 0.00529804291421557844];
expected_lorentzianness = [0.70324413966156929, 0.324276186983734616, 0.572595170451478341, 0.70630302568384451, 0.505182127439105733, 0.999999683466445188, 0.612413251855141061];
expected_location = [1.55151569412105061, 1.85126888730743611, 1.29222246215581227, 1.93611885990057631, 1.22403291280391935, 2.39955488161231933, 3.09333650687846351];
[actual_area, actual_height, actual_width, actual_lorentzianness, actual_location]=GLBIO2013_sample_peak_params(0.1,1);
assertEqual(expected_area, actual_area);
assertEqual(expected_height, actual_height);
assertEqual(expected_width, actual_width);
assertEqual(expected_lorentzianness, actual_lorentzianness);
assertEqual(expected_location, actual_location);


[actual_area, ~, ~, ~, ~]=GLBIO2013_sample_peak_params(0.1,2);
assertEqual(length(actual_area),14);
assertEqual(actual_area(14), 0.00135283134532436316);

RandStream.setGlobalStream(old_rng);
