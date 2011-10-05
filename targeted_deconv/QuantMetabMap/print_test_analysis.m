function print_test_analysis( correct_collection_fn, eval_collection_fn )
% Prints an analysis of eval_collection when compared with correct_collection
%
% Reads two collections one from correct_collection_fn and the other from
% eval_collection_fn.  They should have the same x-values and number of
% spectra.  Then compares the two, reporting % error, mean % error, 
% standard deviation of %error, mean % difference, and standard dev of %
% difference for each x.  Both collections must be text
% files in the xy format.
%
% -------------------------------------------------------------------------
% Input arguments
% -------------------------------------------------------------------------
%
% correct_collection_fn  Filename for the collection holding the
%                        gold-standard correct data
%
% eval_collection_fn     Filename for the collection holding the erroneous
%                        data
%
% -------------------------------------------------------------------------
% Output parameters
% -------------------------------------------------------------------------
%
% No ooutput parameters
%
% -------------------------------------------------------------------------
% Examples
% -------------------------------------------------------------------------
%
% print_test_analysis('foo.dec.correct.xy.txt', 'foo.dec.xy.txt')
%
% Prints the analysis based on the default filenames for
% write_test_collection_to_foo_files

% Load the gold-standard collection
gold_col = load_collection(correct_collection_fn, '');

% Load the evaluation collection
eval_col = load_collection(eval_collection_fn, '');

% Set up count variables
num_x = length(eval_col.x);

% Calculate the error statistics
pct_err = 100*abs(eval_col.Y - gold_col.Y) ./ gold_col.Y;

mean_pct_err = mean(pct_err, 2); % Mean value of each row

std_dev_pct_err = std(pct_err, 0, 2); % Sample standard deviation of each row 


pct_diff = 100*(eval_col.Y - gold_col.Y) ./ gold_col.Y;

mean_pct_diff = mean(pct_diff, 2); % Mean value of each row

std_dev_pct_diff = std(pct_diff, 0, 2); % Sample standard deviation of each row 

% Print the results

fprintf('Raw percent errors:\n');
for x_idx = 1:num_x
    fprintf('%d:%s\n', eval_col.x(x_idx), sprintf('\t%5.2f',pct_err(x_idx,:)));
end

fprintf('\n\nSummarized Errors:\n');
fprintf('ID           Mean pct Std dev Mn %%dif Std dev\n');
for x_idx = 1:num_x
    fprintf('%d:\t%5.2f\t%5.2f\t%5.2f\t%5.2f\n', eval_col.x(x_idx), ...
        mean_pct_err(x_idx), std_dev_pct_err(x_idx), ...
        mean_pct_diff(x_idx), std_dev_pct_diff(x_idx));
end

