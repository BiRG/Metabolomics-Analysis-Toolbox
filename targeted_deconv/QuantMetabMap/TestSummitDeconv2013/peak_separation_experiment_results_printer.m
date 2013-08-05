function str=peak_separation_experiment_results_printer()
% Print the peak_separation_experiment_results.mat file
% Usage: str=peak_separation_experiment_results_printer()
%
% Loads previous_results from peak_separation_experiment_results.mat and
% prints its contents to the screen and returns them as a string
%
% ----------------------------------
% Examples:
% ----------------------------------
% >> peak_separation_experiment_results_printer;
%
% Prints the experiment results to the screen
%
% >> s = peak_separation_experiment_results_printer;
%
% Stores a string representation of the results in s but does not print
% them to the screen.

load('peak_separation_experiment_results.mat');
round10=@(x) round(x*10)/10; % Round to nearest 10th
str = sprintf(...
    '%-20.18g %-8.6g [ %-6.4g , %-6.4g ]  %-7d / %-7d %8.4f %%\n',...
    cell2mat(arrayfun(...
    @(x) [...
        x.width; x.exp.prob; x.exp.shortestCredibleInterval(0.95).min; ...
        x.exp.shortestCredibleInterval(0.95).max; ...
        x.exp.successes; x.exp.trials; ...
        x.exp.probThatParamInRange(...
            max(0,round10(x.exp.prob)-0.001),...
            min(1,round10(x.exp.prob)+0.001))*100 ...
    ], ...
    previous_results, 'UniformOutput',false)));
if nargout == 0
    fprintf('%s', str);
end

end

