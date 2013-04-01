function test_suite = test_GLBIO2013_calc_param_error_list %#ok<STOUT>
% matlab_xUnit tests excercising GLBIO2013_calc_param_error_list
%
% Usage:
%   runtests test_GLBIO2013_calc_param_error_list 
initTestSuite;

function test_high_cong_10 %#ok<DEFNU>
% Check that the stats extracted for the high_cong_10 set of results is correct

% Load high_cong_10 and most_cong_10
load('test_GLBIO2013_calc_param_error_list.mat');

pe = GLBIO2013_calc_param_error_list(high_cong_10);
assertEqual(length(pe), length(high_cong_10)*3*5);

% Collision prob field correct?
assertEqual([pe.collision_prob],repmat([repmat(0.8,1,15) repmat(0.9,1,15)],1,5));

% Peak picker correct?
names_for_one_result = {'pp_gold_standard', 'pp_gold_standard', 'pp_gold_standard', 'pp_gold_standard', 'pp_gold_standard', 'pp_noisy_gold_standard', 'pp_noisy_gold_standard', 'pp_noisy_gold_standard', 'pp_noisy_gold_standard', 'pp_noisy_gold_standard', 'pp_smoothed_local_max', 'pp_smoothed_local_max', 'pp_smoothed_local_max', 'pp_smoothed_local_max', 'pp_smoothed_local_max'};
assertEqual({pe.peak_picking_name}, repmat(names_for_one_result,1,10));

% Parameter name correct?
names_for_one_deconv = {'height','width-at-half-height','lorentzianness','location','area'};
assertEqual({pe.parameter_name}, repmat(names_for_one_deconv, 1, 30));

% Datum id correct?
ids = {'mired secretively setback', 'hungriest dualism benefactor', 'holdup normally temped', 'corralled suntan liquefy', 'fullback unmindful visibility', 'manufacture conversation mystification', 'rend hosed huddled', 'unrehearsed exclamation coarsely', 'blacker outweigh theosophy', 'relocate dachshund swag'};
for i = 1:length(ids)
    pe_from_same_datum = pe((i-1)*15+1:(i)*15);
    assertEqual({pe_from_same_datum.datum_id}, repmat(ids(i), 1, 15));
end

% Are the mean parameter errors calculated correctly for the first
% deconvolution of the 7th result?
orig_aligned_heights   = [0.0480357704952010522, 0.225200334809844277, 0.14065463012247123, 0.990611983399242391, 0.536017424412529864, 0.232444943897812145, 0.266274377669234286];
deconv_aligned_heights = [0.0924988282085133645, 0.100335834595510043, 0.911477542930895113, 0.0494066396052888004, 0.535375380621094354, 0.233757645038925183, 0.266179325668604028];
abs_err = abs(orig_aligned_heights - deconv_aligned_heights);
assertEqual(pe((7-1)*15+1).mean_error_anderson, mean(abs_err));

orig_aligned_widths    = [0.005605565090969402, 0.00339383386541163403, 0.00395178178714130236, 0.00545591226880782522, 0.00330544306897216037, 0.00237788764655726473, 0.00497314396480305707];
deconv_aligned_widths  = [3.57016180202701961e-05, 0.0312642560247505044, 0.00516925102784783312, 0.00576450771969795345, 0.00329740752051164336, 0.0023922937199442329, 0.00499123128194428698];
abs_err = abs(orig_aligned_widths - deconv_aligned_widths);
assertEqual(pe((7-1)*15+2).mean_error_anderson, mean(abs_err));

orig_aligned_lors    = [0.713738350036012381, 0.999999999999977685, 0.999999999999977685, 0.648623435906133805, 0.693544130619223154, 6.50831986496108926e-10, 0.999999999999977796];
deconv_aligned_lors  = [0.129935029792715873, 6.39407339017747684e-08, 0.428083317282860865, 0.736536531030049901, 0.705331179938574415, 0.0107685406991098968, 0.999999999999871214];
abs_err = abs(orig_aligned_lors - deconv_aligned_lors);
assertEqual(pe((7-1)*15+3).mean_error_anderson, mean(abs_err));

orig_aligned_locations    = [1.08574011207279231, 1.01958296071948173, 1.03354132583882019, 1.04178328909898821, 1.11544838117966028, 1.11789462385503446, 1.14954236932638754];
deconv_aligned_locations  = [1.0938382932302706, 1.03352581106867913, 1.0417936345100558, 1.0857159923112909, 1.11544376343197782, 1.11788782645148665, 1.14954011339540618];
abs_err = abs(orig_aligned_locations - deconv_aligned_locations);
assertEqual(pe((7-1)*15+4).mean_error_anderson, mean(abs_err));

orig_aligned_areas    = [0.000383936248490201646, 0.00120054788737912997, 0.000873105784207620929, 0.00752810951710673228, 0.00250817572231254882, 0.000588360684957584695, 0.00208008119094804655];
deconv_aligned_areas  = [3.73251283511682143e-06, 0.00333915354200190568, 0.00603665946799407209, 0.000409377803025285584, 0.00250961717588144484, 0.00059831708595129633, 0.00208690121568641963];
abs_err = abs(orig_aligned_areas - deconv_aligned_areas);
assertEqual(pe((7-1)*15+5).mean_error_anderson, mean(abs_err));

% Are the mean parameter errors calculated correctly for the second
% deconvolution of the 7th result?
orig_aligned_heights=[0.225200334809844277, 0.14065463012247123, 0.990611983399242391, 0.0480357704952010522, 0.536017424412529864, 0.232444943897812145, 0.266274377669234286];
deconv_aligned_heights=[0.223840385604963693, 0.141344052130987857, 0.98970112498628493, 0.0463148351106922526, 0.53352391311957692, 0.234644350214039787, 0.265501923171389653];
abs_err = abs(orig_aligned_heights - deconv_aligned_heights);
assertEqual(pe((7-1)*15+1).mean_error_summit, mean(abs_err));

orig_aligned_half_height_widths=[0.00339383386541163403, 0.00395178178714130236, 0.00545591226880782522, 0.005605565090969402, 0.00330544306897216037, 0.00237788764655726473, 0.00497314396480305707];
deconv_aligned_half_height_widths=[0.00341456600861890763, 0.00394518607038146438, 0.0054560093227813437, 0.00561240057799662195, 0.0032926672428202357, 0.00239994578415123798, 0.00497002756633832966];
abs_err = abs(orig_aligned_half_height_widths - deconv_aligned_half_height_widths);
assertEqual(pe((7-1)*15+2).mean_error_summit, mean(abs_err));

orig_aligned_lorentziannesss=[0.999999999999977685, 0.999999999999977685, 0.648623435906133805, 0.713738350036012381, 0.693544130619223154, 6.50831986496108926e-10, 0.999999999999977796];
deconv_aligned_lorentziannesss=[0.977461897393896662, 0.999999889704187406, 0.637918543235459601, 0.459404494045141609, 0.675237933522635281, 7.96098547099362863e-06, 0.985309142725972253];
abs_err = abs(orig_aligned_lorentziannesss- deconv_aligned_lorentziannesss);
assertEqual(pe((7-1)*15+3).mean_error_summit, mean(abs_err));

orig_aligned_locations=[1.01958296071948173, 1.03354132583882019, 1.04178328909898821, 1.08574011207279231, 1.11544838117966028, 1.11789462385503446, 1.14954236932638754];
deconv_aligned_locations=[1.01958542812350195, 1.03354735587871871, 1.0417839918579348, 1.08573287316768208, 1.11544153209831487, 1.11789229022304926, 1.14954188841435201];
abs_err = abs(orig_aligned_locations - deconv_aligned_locations);
assertEqual(pe((7-1)*15+4).mean_error_summit, mean(abs_err));

orig_aligned_areas=[0.00120054788737912997, 0.000873105784207620929, 0.00752810951710673228, 0.000383936248490201646, 0.00250817572231254882, 0.000588360684957584695, 0.00208008119094804655];
deconv_aligned_areas=[0.00119186538227143549, 0.00087592090283254351, 0.00749205318240847139, 0.000337158826970474846, 0.00247057571914104969, 0.00059943954140541779, 0.00206293187155527809];
abs_err = abs(orig_aligned_areas - deconv_aligned_areas);
assertEqual(pe((7-1)*15+5).mean_error_summit, mean(abs_err));

% Is error_diff the difference in the individual errors?
assertEqual([pe.error_diff], [pe.mean_error_anderson] - [pe.mean_error_summit]);



function test_most_cong_10 %#ok<DEFNU>
% Check that the stats extracted for the most_cong_10 set of results is correct

% Load most_cong_10 and most_cong_10
load('test_GLBIO2013_calc_param_error_list.mat');

pe = GLBIO2013_calc_param_error_list(most_cong_10);
assertEqual(length(pe), length(most_cong_10)*3*5);

% Collision prob field correct?
assertEqual([pe.collision_prob],ones(1,150));

% Peak picker correct?
names_for_one_result = {'pp_gold_standard', 'pp_gold_standard', 'pp_gold_standard', 'pp_gold_standard', 'pp_gold_standard', 'pp_noisy_gold_standard', 'pp_noisy_gold_standard', 'pp_noisy_gold_standard', 'pp_noisy_gold_standard', 'pp_noisy_gold_standard', 'pp_smoothed_local_max', 'pp_smoothed_local_max', 'pp_smoothed_local_max', 'pp_smoothed_local_max', 'pp_smoothed_local_max'};
assertEqual({pe.peak_picking_name}, repmat(names_for_one_result,1,10));

% Parameter name correct?
names_for_one_deconv = {'height','width-at-half-height','lorentzianness','location','area'};
assertEqual({pe.parameter_name}, repmat(names_for_one_deconv, 1, 30));

% Datum id correct?
ids = {'rawest prank baccalaureate', 'annihilate electromagnet continence', 'piggybacked tomb wrongly', 'mulish gimmickry inveigh', 'resistance blurry whippersnapper', 'pterodactyl equalized parenthetical', 'maturity deprave paranoid', 'quailed editorial misunderstand', 'complacently largely spurred', 'rivet until shuffled'};
for i = 1:length(ids)
    pe_from_same_datum = pe((i-1)*15+1:(i)*15);
    assertEqual({pe_from_same_datum.datum_id}, repmat(ids(i), 1, 15));
end

% Is error_diff the difference in the individual errors?
assertEqual([pe.error_diff], [pe.mean_error_anderson] - [pe.mean_error_summit]);

% Are the mean parameter errors calculated correctly for the sixth
% deconvolution of the 2nd result?
orig_aligned_heights=[0.628400019525780729, 0.672218361720759217];
deconv_aligned_heights=[0.501147619867081451, 0.926636508157661076];
abs_err = abs(orig_aligned_heights - deconv_aligned_heights);
assertEqual(pe((2-1)*15+10+1).mean_error_summit, mean(abs_err));

orig_aligned_half_height_widths=[0.00236369458321089836, 0.00257600954424892607];
deconv_aligned_half_height_widths=[0.0019783147588927478, 0.00454206373980442675];
abs_err = abs(orig_aligned_half_height_widths - deconv_aligned_half_height_widths);
assertEqual(pe((2-1)*15+10+2).mean_error_summit, mean(abs_err));

orig_aligned_lorentziannesss=[0.746683218290186246, 0.694708689496241316];
deconv_aligned_lorentziannesss=[0.514852243710319568, 0.774549342410628117];
abs_err = abs(orig_aligned_lorentziannesss- deconv_aligned_lorentziannesss);
assertEqual(pe((2-1)*15+10+3).mean_error_summit, mean(abs_err));

orig_aligned_locations=[1.00722897467409278, 1.00961929236177528];
deconv_aligned_locations=[1.00713018414370103, 1.00953183698986515];
abs_err = abs(orig_aligned_locations - deconv_aligned_locations);
assertEqual(pe((2-1)*15+10+4).mean_error_summit, mean(abs_err));

orig_aligned_areas=[0.00214266262131242559, 0.00245238170784044165];
deconv_aligned_areas=[0.00131379224403512201, 0.00613078478486858529];
abs_err = abs(orig_aligned_areas - deconv_aligned_areas);
assertEqual(pe((2-1)*15+10+5).mean_error_summit, mean(abs_err));

% Are the mean parameter errors calculated correctly for the fifth
% deconvolution of the 2nd result?
orig_aligned_heights=[0.175604724395883011, 0.672218361720759217];
deconv_aligned_heights=[0.451764415983826439, 0.785637349096286131];
abs_err = abs(orig_aligned_heights - deconv_aligned_heights);
assertEqual(pe((2-1)*15+10+1).mean_error_anderson, mean(abs_err));

orig_aligned_half_height_widths=[0.00333812932529209058, 0.00257600954424892607];
deconv_aligned_half_height_widths=[0.00290170412479189704, 0.00526354656056269177];
abs_err = abs(orig_aligned_half_height_widths - deconv_aligned_half_height_widths);
assertEqual(pe((2-1)*15+10+2).mean_error_anderson, mean(abs_err));

orig_aligned_lorentziannesss=[0.999999999999977685, 0.694708689496241316];
deconv_aligned_lorentziannesss=[0.709117196746681389, 0.485293169323519236];
abs_err = abs(orig_aligned_lorentziannesss- deconv_aligned_lorentziannesss);
assertEqual(pe((2-1)*15+10+3).mean_error_anderson, mean(abs_err));

orig_aligned_locations=[1.00780415866038475, 1.00961929236177528];
deconv_aligned_locations=[1.00753121840671778, 1.00955178919871358];
abs_err = abs(orig_aligned_locations - deconv_aligned_locations);
assertEqual(pe((2-1)*15+10+4).mean_error_anderson, mean(abs_err));

orig_aligned_areas=[0.000920787109683523933, 0.00245238170784044165];
deconv_aligned_areas=[0.00186606531444538258, 0.00541792852191624007];
abs_err = abs(orig_aligned_areas - deconv_aligned_areas);
assertEqual(pe((2-1)*15+10+5).mean_error_anderson, mean(abs_err));

