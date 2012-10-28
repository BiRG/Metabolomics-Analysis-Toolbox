function  results = resultsOverviewExperiment( )
% Return a structure array with the results of the experiment run to give
% an overview of the characteristics affecting the different algorithms.
% The results should reflect a balanced experimental design where all
% combinations of factors have the same number of observations.
%
% Uses the data obtained from loadOverviewSpectra and the random number 
% generator seeded with the number 2336850071.
%
% The structure has fields:
%
% results.data is a numeric matrix holding the results of the experiment.
%              Each row is one set of experimental conditions, each 
%              column is a parameter in that run of the experiment.
% 
% results.schema a cell array of strings. results.schema{i} is the name of
%                the parameter stored in column i of the data.
%
% results.schema_description is a cell array of strings.
%                            results.schema_description{i} describes the
%                            parameter stored in column i in more detail
%                            than results.schema{i}
%
% results.dilution_key a cell array of strings results.dilution_key{i} is a
%                      description of the distribution from which dilution
%                      factors were drawn indicated by i in the dilution 
%                      parameter.
%
% results.treatment_key a cell array of strings results.treatment_key{i} is
%                       a description of the treatment group indicated by i
%                       in the treatment group parameter.
%
% results.method_key a cell array of strings results.method_key{i} is
%                    a description of the dilution noramlization method 
%                    indicated by i in the normalization method parameter.
%

% Save the current random stream and make this experiment repeatable by 
% creating our own stream
oldRandStr = RandStream.getDefaultStream;
randStr=RandStream('mt19937ar','Seed',2336850071);
RandStream.setDefaultStream(randStr);



% Set the metadata for the experiment
results.schema = {'Number of spectra','Percent control group', ...
    'Treatment group id', ...
    'Control dilution range id', 'Treatment dilution range id', ...
    'Trial number', 'Normalization method id', ...
    'RMSE', 'RMSE_log'
    };

results.schema_description = {
    ['The total number of spectra in the trial. Includes both control ' ...
    'and treatment group spectra.'], ...
    ['The percentage of the total spectra that were selected from the ' ...
    'control group. A 10 means 10% were selected.'], ...
    ['ID of the spectrum category selected as the treatment group. See '...
    'the treatment_key field for the meaning of each id.'], ...
    ['ID of the dilution range for the spectra in the control group. ' ...
    'See the dilution_key field for the meaning of each id'], ...
    ['ID of the dilution range for the spectra in the treatment group. ' ...
    'See the dilution_key field for the meaning of each id'], ...
    ['The number of the trial on which this measurement was made. A ' ...
    'trial is a particular choice of input spectra, dilutions and ' ...
    'noise.'], ...
    ['ID of the normalization method for which the measurements were ' ...
    'taken. See the method_key field for a description.'], ...
    ['The Root-mean-squared-error of a regression of actual dilution ' ...
    'against the dilution calculated by this method for the spectra ' ...
    'in this group.'] ...
    ['The Root-mean-squared-error of a regression of the log of the actual dilution ' ...
    'against the log of the dilution calculated by this method for the spectra ' ...
    'in this group.'] ...
    };
    
results.dilution_key = { ...
    'No dilution',...
    ['Small dilution range: divide by a number uniformly chosen from 0.4 '...
    'to 2.6 (this range comes from Torgrip''s histogram equalization '...
    'paper.)'], ...
    ['Large dilution range: divide by a number uniformly chosen from 0.125 '...
    'to 8'] ...
    ['Extreme dilution range: divide by a number uniformly chosen from 0.025 '...
    'to 40'] ...
    };

results.treatment_key = { ...
    ['First control group - this should never appear because the first ' ...
    'group of control samples should always be the control group and ' ...
    'never the treatment group.'], ...
    ['No effect treatment- identical metabolite concentration ' ...
    'distribution to the control group, but samples chosen '...
    'independently.'], ...
    ['1 metabolite upregulated 20% - phenylacetylglutamine with ' ...
    'mean and standard deviation multiplied by 1.2'], ...
    ['1 metabolite upregulated 500% - phenylacetylglutamine with ' ...
    'mean and standard deviation multiplied by 5'], ...
    ['10 metabolites upregulated 500% - phenylacetylglutamine, '...
    'lysine,  citrulline,  Galactose,  beta-D-fructose,  Betaine,  '...
    'leucine,  Isoleucine,  Trimethylamine, and TMAO ' ...
    'mean and standard deviation multiplied by 5'], ...
    ['7 metabolites upregulated 500% and 8 downregulated to 1/5th - ' ...
    'phenylacetylglutamine, '...
    'lysine,  citrulline,  Galactose,  beta-D-fructose,  Betaine,  '...
    'and leucine ' ...
    'with mean and standard deviation multiplied by 5 AND' ...
    'Isoleucine,  Trimethylamine, TMAO, NMND, Hippuric_acid, ' ...
    '2_deoxycytidine, 2_deoxyadenosine, and p-cresol_sulfate' ...
    'mean and standard deviation divided by 5'], ...
    };

results.method_key = { ...
    ['Constant sum - y values are summed and multiplied by a factor to '...
    'make their sum 1000.'], ...
    ['PQN all spectra all bins - does probabilistic quotient ' ...
    'normalization using the median of all spectra and all bins from ' ...
    'those spectra to derive the dilution factor.'], ...
    ['PQN controls all bins - does probabilistic quotient ' ...
    'normalization using the median of the control spectra and all ' ...
    'bins from those spectra to derive the dilution factor.'], ...
    ['PQN all spectra 3 iqr inlier bins - does probabilistic quotient ' ...
    'normalization using the median of all spectra as the reference ' ...
    'spectrum and but removing all bins that generate outlier quotients ' ...
    'from those spectra when deriving the dilution factor. ' ...
    'A value is an outlier if it lies more than 3 iqr from the nearest '...
    'quartile'], ...
    ['PQN all spectra 2 iqr inlier bins - does probabilistic quotient ' ...
    'normalization using the median of all spectra as the reference ' ...
    'spectrum and but removing all bins that generate outlier quotients ' ...
    'from those spectra when deriving the dilution factor. ' ...
    'A value is an outlier if it lies more than 3 iqr from the nearest '...
    'quartile'], ...
    ['Histogram normalization log bins - uses Torgrip''s histogram ' ...
    'normalization with 60 bins spaced logarithmically along the y axis - ' ...
    'this is as originally published.'], ...
    ['Histogram normalization equi-bins - uses Torgrip''s histogram ' ...
    'normalization with 60 bins spaced to contain as close to an equal ' ...
    'number of samples in the reference spectrum as possible.'] ...
    ['Histogram normalization scaled log bins - uses Torgrip''s histogram ' ...
    'normalization with 60 bins spaced logarithmically along the y axis - ' ...
    'this is as originally published except that the histograms ' ...
    'are divided by the total number of sample points in the spectrum ' ...
    'before comparison.'], ...
    ['Histogram normalization scaled equi-bins - uses Torgrip''s histogram ' ...
    'normalization with 60 bins spaced to contain as close to an equal ' ...
    'number of samples in the reference spectrum as possible. ' ...
    'The histograms ' ...
    'are divided by the total number of sample points in the spectrum ' ...
    'before comparison.'] ...
    };

% Load the spectra
wait_h = waitbar(0, 'Loading spectra');
spec=loadOverviewSpectra();
wait_h = waitbar(0, wait_h, 'Binning collections');

% Calculate noise standard deviation
noise_std = median(cellfun(@(s) median(noise_for_snr(s, 1000)), spec));

% Preallocate storage for the results
num_rows = 2*3*5*4*4*50*9; %Multiply out the number of loops
results.data=zeros(num_rows, length(results.schema));

%DEBUG: Set up global variables that can be used for post-mortem debugging
global num_spectra_idx percent_control_group_idx treatment_group_id;
global control_dilution_range_id treatment_dilution_range_id;
global trial_number rng_state;
global true_dilutions cont_idxs treat_idxs diluted_spec;
global binned_diluted_spec use_bin discard_sample;
global calculated_dilutions normed_spec rmse rmse_log;


% Run the experiment
first_empty = 1;
start_time = now;
for num_spectra_idx = 1:2
    num_spectra=[20,10];
    num_spectra=num_spectra(num_spectra_idx);
    
    for percent_control_group_idx = 1:3
        percent_control_group = [10,30,50];
        percent_control_group = percent_control_group(percent_control_group_idx);
        num_control_spectra = round(num_spectra * percent_control_group / 100);
        num_treatment_spectra = num_spectra - num_control_spectra;
        
        for treatment_group_id = 2:6
    
            dilution_ranges=[1,1;0.4,2.6;0.125,8;0.025,40];
            for control_dilution_range_id = 1:4
                control_dilution_range = ...
                    dilution_ranges(control_dilution_range_id, :);
                
                for treatment_dilution_range_id = 1:4
                    treatment_dilution_range = ...
                        dilution_ranges(treatment_dilution_range_id, :);
                    
                    elapsed_time = now - start_time;
                    rows_complete = max(1,first_empty - 1);
                    days_per_row = elapsed_time / rows_complete;
                    mins_remaining = (num_rows - rows_complete)* days_per_row * 24* 60;
                    
                    waitbar((first_empty-1)/num_rows, wait_h, ...
                        sprintf('%d/%d: %d %d%% %d %d %d (%.1f mins left %.1f elapsed)', ...
                        first_empty, num_rows, num_spectra,...
                        percent_control_group, ...
                        treatment_group_id, ...
                        control_dilution_range_id, ...
                        treatment_dilution_range_id, ...
                        mins_remaining, elapsed_time*24*60 ...
                        ));
                    for trial_number = 1:50                        
                        %DEBUG: store the current state of the RNG for
                        %reproducing the bug
                        rng_state = RandStream.getDefaultStream();
                        
                        % Calculate the dilution factors
                        true_dilutions = [rand_dilutions(num_control_spectra, ...
                            control_dilution_range); ...
                            rand_dilutions(num_treatment_spectra, ...
                            treatment_dilution_range) ...
                            ]';
                                                
                        % Decide which spectra will be used for the subset
                        cont_idxs = subset_indices(num_control_spectra, spec{1});
                        treat_idxs = subset_indices(num_treatment_spectra, spec{treatment_group_id});
                        
                        % Create diluted subset
                        to_dilute = spectrum_subset(cont_idxs, spec{1}, treat_idxs, spec{treatment_group_id});
                        diluted_spec = {dilute_spectra(to_dilute{1}, true_dilutions)};
                        diluted_spec{1} = rmfield(diluted_spec{1}, 'original_multiplied_by');
                        
                        
                        % Add noise
                        diluted_spec = add_noise(diluted_spec, noise_std);
                        
                        % Uniform Bin and sum-normalize to prepare for PQN
                        binned_diluted_spec = uniform_bin_collections(diluted_spec, 0.04, false);
                        discard_sample = noise_samples(diluted_spec{1}, 30, 5);
                        use_bin = ~bins_to_discard(binned_diluted_spec{1}, ...
                            diluted_spec{1}.x(discard_sample));
                        
                        
                        for normalization_method_id_idx = 1:9
                            normalization_method_id = [1,2,3,4,5,6,7,8,9];
                            normalization_method_id = normalization_method_id(normalization_method_id_idx);
                            
                            switch(normalization_method_id)
                                case 1
                                    normed_spec = sum_normalize(diluted_spec, 1000);
                                case 2
                                    use_all_spectra = ...
                                        {true(1,size(diluted_spec{1}.Y,2))};
                                    normed_spec = pq_normalize(diluted_spec,...
                                        binned_diluted_spec, 1000, ...
                                        use_all_spectra, use_bin);
                                case 3
                                    use_control_spectra = ...
                                        {[true(1,num_control_spectra),...
                                        false(1,num_treatment_spectra)]};
                                    normed_spec = pq_normalize(diluted_spec,...
                                        binned_diluted_spec, 1000, ...
                                        use_control_spectra, use_bin);
                                case 4
                                    use_all_spectra = ...
                                        {true(1,size(diluted_spec{1}.Y,2))};
                                    use_3_inliers = eliminate_outlier_bins(...
                                        binned_diluted_spec, 1000, ...
                                        use_all_spectra, use_bin, 3);
                                    normed_spec = pq_normalize(diluted_spec,...
                                        binned_diluted_spec, 1000, ...
                                        use_all_spectra, use_3_inliers);
                                case 5
                                    use_all_spectra = ...
                                        {true(1,size(diluted_spec{1}.Y,2))};
                                    use_2_inliers = eliminate_outlier_bins(...
                                        binned_diluted_spec, 1000, ...
                                        use_all_spectra, use_bin, 2);
                                    normed_spec = pq_normalize(diluted_spec,...
                                        binned_diluted_spec, 1000, ...
                                        use_all_spectra, use_2_inliers);
                                case 6
                                    normed_spec=histogram_normalize(...
                                        diluted_spec, 30, 5, 60, false, ...
                                        'logarithmic', 'count');
                                case 7
                                    normed_spec=histogram_normalize(...
                                        diluted_spec, 30, 5, 60, false, ...
                                        'equal frequency', 'count');
                                case 8
                                    normed_spec=histogram_normalize(...
                                        diluted_spec, 30, 5, 60, false, ...
                                        'logarithmic', 'fraction of total');
                                case 9
                                    normed_spec=histogram_normalize(...
                                        diluted_spec, 30, 5, 60, false, ...
                                        'equal frequency', ...
                                        'fraction of total');
                                otherwise
                                    error('results9MethodExperiment:invalid_norm_id', ...
                                        ['The normalization method id '...
                                        '%d is unknown.'], ...
                                        normalization_method_id);
                            end
                            calculated_dilutions = normed_spec{1}.original_multiplied_by;
                            [rmse, rmse_log] = normalization_error( ...
                                true_dilutions, ...
                                calculated_dilutions);
                            
                            results.data(first_empty,:)=[ ...
                                num_spectra, ...
                                percent_control_group, ...
                                treatment_group_id, ...
                                control_dilution_range_id, ...
                                treatment_dilution_range_id, ...
                                trial_number, ...
                                normalization_method_id, ...
                                rmse, rmse_log
                                ];
                            
                            first_empty = first_empty + 1;

                        end
                        
                    end
                    
                end
                
            end
        end
    end
end

close(wait_h);

% Restore the original random stream
RandStream.setDefaultStream(oldRandStr);

end