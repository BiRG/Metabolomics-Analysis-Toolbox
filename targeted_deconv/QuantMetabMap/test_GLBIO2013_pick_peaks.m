function test_suite = test_GLBIO2013_pick_peaks %#ok<STOUT>
% matlab_xUnit tests excercising GLBIO2013_pick_peaks
%
% Usage:
%   runtests test_GLBIO2013_pick_peaks 
initTestSuite;

function test_result_2 %#ok<DEFNU>
% Check peak picking for result 2 of the May 7 experiment.

old_rng = RandStream.getGlobalStream();
RandStream.setGlobalStream(RandStream('mt19937ar','Seed',1288700689));

spec = cell2struct({[1.02608373204270209, 1.02590004378888033, 1.02571635553505836, 1.0255326672812366, 1.02534897902741462, 1.02516529077359286, 1.02498160251977111, 1.02479791426594913, 1.02461422601212737, 1.02443053775830539, 1.02424684950448364, 1.02406316125066188, 1.0238794729968399, 1.02369578474301814, 1.02351209648919617, 1.02332840823537441, 1.02314471998155265, 1.02296103172773067, 1.02277734347390892, 1.02259365522008694, 1.02240996696626518, 1.02222627871244343, 1.02204259045862145, 1.02185890220479969, 1.02167521395097771, 1.02149152569715596, 1.0213078374433342, 1.02112414918951222, 1.02094046093569046, 1.02075677268186849, 1.02057308442804673, 1.02038939617422497, 1.02020570792040299, 1.02002201966658124, 1.01983833141275926, 1.0196546431589375, 1.01947095490511574, 1.01928726665129377, 1.01910357839747201, 1.01891989014365003, 1.01873620188982827, 1.01855251363600652, 1.01836882538218454, 1.01818513712836278, 1.0180014488745408, 1.01781776062071905, 1.01763407236689729, 1.01745038411307531, 1.01726669585925356, 1.01708300760543158, 1.01689931935160982, 1.01671563109778806, 1.01653194284396609, 1.01634825459014433, 1.01616456633632235, 1.01598087808250059, 1.01579718982867884, 1.01561350157485686, 1.0154298133210351, 1.01524612506721312, 1.01506243681339137, 1.01487874855956961, 1.01469506030574763, 1.01451137205192587, 1.0143276837981039, 1.01414399554428214, 1.01396030729046038, 1.0137766190366384, 1.01359293078281665, 1.01340924252899467, 1.01322555427517291, 1.01304186602135093, 1.01285817776752918, 1.01267448951370742, 1.01249080125988544, 1.01230711300606369, 1.01212342475224171, 1.01193973649841995, 1.01175604824459819, 1.01157235999077622, 1.01138867173695446, 1.01120498348313248, 1.01102129522931072, 1.01083760697548897, 1.01065391872166699, 1.01047023046784523, 1.01028654221402325, 1.0101028539602015, 1.00991916570637974, 1.00973547745255776, 1.009551789198736, 1.00936810094491403, 1.00918441269109227, 1.00900072443727051, 1.00881703618344853, 1.00863334792962678, 1.0084496596758048, 1.00826597142198304, 1.00808228316816129, 1.00789859491433931, 1.00771490666051755, 1.00753121840669557, 1.00734753015287382, 1.00716384189905206, 1.00698015364523008, 1.00679646539140832, 1.00661277713758635, 1.00642908888376459, 1.00624540062994283, 1.00606171237612085, 1.0058780241222991, 1.00569433586847712, 1.00551064761465536, 1.00532695936083361, 1.00514327110701163, 1.00495958285318987, 1.00477589459936789, 1.00459220634554613, 1.00440851809172438, 1.0042248298379024, 1.00404114158408064, 1.00385745333025866, 1.00367376507643691, 1.00349007682261515, 1.00330638856879317, 1.00312270031497142, 1.00293901206114944, 1.00275532380732768, 1.00257163555350592, 1.00238794729968395, 1.00220425904586219, 1.00202057079204021, 1.00183688253821845, 1.0016531942843967, 1.00146950603057472, 1.00128581777675296, 1.00110212952293098, 1.00091844126910923, 1.00073475301528747, 1.00055106476146549, 1.00036737650764374, 1.00018368825382176, 1]; [0.101910095119830971; 0.114436114908123429; 0.128018960220258493; 0.142727778556609508; 0.163587014375505269; 0.186545113702191734; 0.213617969557603482; 0.248927585991677108; 0.288699395059676678; 0.338978285305369165; 0.397908507713795268; 0.469894049604865527; 0.555406279091827382; 0.646095642554221139; 0.743142309617502494; 0.834110054096184883; 0.895798520582701485; 0.924129995637281487; 0.901364172953399101; 0.843433277603792941; 0.759029207737416556; 0.667945128692524648; 0.580097249608421572; 0.504087956051209263; 0.434031286289736029; 0.379214619227500549; 0.330911347824810964; 0.292849159934977843; 0.260876061630855083; 0.235401594732126934; 0.212070188149601463; 0.194723179673637004; 0.178782472764007383; 0.164043239082622194; 0.1522355560274673; 0.140593080865509146; 0.131169498455154077; 0.122876174594420656; 0.113889410573246405; 0.107401403144310917; 0.099167097187864886; 0.0929426083930581515; 0.0861388696789446573; 0.0809821594998016703; 0.07572179135478245; 0.0714705817341788202; 0.0681925964838306226; 0.0623209395001411912; 0.0606680022705395408; 0.0585479449578443223; 0.0548880714987437374; 0.0523552054569694642; 0.0502436640854526731; 0.0486733372000235781; 0.0466736224249897427; 0.045664723071553906; 0.0458097756874803336; 0.045611756484274471; 0.0458298833444507545; 0.0442750768698465871; 0.0451393533479759537; 0.0443768170224569866; 0.0442972389671899211; 0.0463688466370713731; 0.0463192386637388334; 0.0493018524387814003; 0.05109343737867892; 0.0497869840667636981; 0.0513079901634253682; 0.0533498141563197789; 0.0524042990129157532; 0.0528764313364668281; 0.055440467133633882; 0.0565477792682639244; 0.0570590591369156547; 0.057424044489902043; 0.061358946620524539; 0.0640540289305358418; 0.0670808824092281875; 0.0702394924994704517; 0.0731998544820881974; 0.0772789851511893472; 0.0808822020162934946; 0.0871170604449296171; 0.0920375447791167978; 0.0998503424980567433; 0.106816760244333397; 0.116328273281745692; 0.126146530313507199; 0.140038999361404265; 0.153107633003482069; 0.167732690438716636; 0.182309385806749269; 0.204968020389010686; 0.226606871266690713; 0.250045661801780172; 0.274611123257674949; 0.303618656457631586; 0.332941727291998169; 0.363156906507538624; 0.394960682902196825; 0.427522848143605916; 0.457353542832479032; 0.483753255969811335; 0.510717466960741828; 0.529792753681254003; 0.543830934918735576; 0.554229843797942712; 0.556250556140627683; 0.557850761009787477; 0.552748150994236798; 0.549650311792650892; 0.544942662436850411; 0.542005486530200309; 0.54129482596665679; 0.54710849476528467; 0.554877799579854614; 0.570187139321067238; 0.588748438010076258; 0.613920748440584418; 0.645323076996157319; 0.679233292756832197; 0.717610734180676779; 0.760321187920278252; 0.806400802657452953; 0.850892300339735619; 0.895418690379620408; 0.930900286752518791; 0.964382140892512507; 0.986760255028028332; 1.00135089342406802; 1.00200834396289884; 0.987270228020955543; 0.963439175711418683; 0.92712093642441018; 0.881761666940352073; 0.829448230530270836; 0.773484300242628375; 0.71360647978071845; 0.653317327930890257; 0.594753209374394798; 0.535921280855176985; 0.483780588077756812]; {'Collection ID', 'Type', 'Description', 'Processing log', 'Base sample ID', 'Time', 'Classification', 'Sample ID', 'Subject ID', 'Sample Description', 'Weight', 'Units of weight', 'Species'}; {'collection_id', 'type', 'description', 'processing_log', 'base_sample_id', 'time', 'classification', 'sample_id', 'subject_id', 'sample_description', 'weight', 'units_of_weight', 'species'}; '-1563'; 'SpectraCollection'; 'Random spectrum for evaluating deconvolution'; 'Created by random_spec_From_nssd_data.'; 1; 0; {'Random spectrum'}; 1; 1; {'Random spectrum'}; 1; {'No weight unit'}; {'No species'}; 1}, {'x'; 'Y'; 'input_names'; 'formatted_input_names'; 'collection_id'; 'type'; 'description'; 'processing_log'; 'num_samples'; 'time'; 'classification'; 'sample_id'; 'subject_id'; 'sample_description'; 'weight'; 'units_of_weight'; 'species'; 'base_sample_id'}, 1);
peaks = GaussLorentzPeak([0.0383993, 0.00553981, 2.3099e-14, 1.02131, 0.115648, 0.00398805, 0.0942914, 1.00612, 0.00511459, 0.00248777, 0.355497, 1.0136, 0.866691, 0.00219883, 0.92097, 1.02296, 0.349603, 0.00390749, 0.857857, 1.00662, 0.0248744, 0.0053008, 0.0915811, 1.02119, 0.943138, 0.00395569, 0.460361, 1.00203]);
noise_std = 0.00100000000000000002;

picked = GLBIO2013_pick_peaks(spec, peaks, noise_std);

assertEqual(GLBIO2013Deconv.peak_picking_method_names, {'pp_gold_standard', 'pp_noisy_gold_standard', 'pp_smoothed_local_max'}, 'The test will only work if the expected pickers are implemented');

% Gold standard
assertEqual(picked{1}, sort([peaks.location]));

% Noisy gold standard
mean_peak_width = 0.00453630122481774988; % Width of the mean peak in ppm
expected_vals_from_randn = [1.36556131320763297, -2.98515413955462838, -1.08285682953608475, -0.966852558541249296, -0.572809259587081177, 0.0235933842178434154, 1.11547660751602895];
expected_noise = (mean_peak_width/16).*expected_vals_from_randn;
assertEqual(picked{2}, sort([peaks.location]+expected_noise));

% Smoothed local max
expected_local_max = [1.00220425904586219, 1.00606171237612085, 1.02296103172773067];
assertEqual(picked{3}, sort(expected_local_max));

RandStream.setGlobalStream(old_rng);
