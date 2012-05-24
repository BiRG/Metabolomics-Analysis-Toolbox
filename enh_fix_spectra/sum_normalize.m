function sum_normalize 
% Multiplies every spectrum so its area matches a user-specified constant
%
% Helper routine for the fix_spectra program. Intended to be called from
% within it.
%
% Presents a prompt to the user asking to what constant to normalize the
% data to, then calculates the results. Finally, after updating the output
% parameters, calls plot_all
%
% -------------------------------------------------------------------------
% Input arguments
% -------------------------------------------------------------------------
% 
% getappdata(gcf, collections) - the output of a call to loadcollections.m
%                                a cell array of spectra
%
% -------------------------------------------------------------------------
% Output parameters
% -------------------------------------------------------------------------
%
% sets appdata fields to reflect the results of sum-normalization and the
% metadata to be added.
%
% setappdata(gcf,'collections',...)
%    - sets collections to a new set with Y_fixed being the sum-normalized
%      values
%
% setappdata(gcf,'add_processing_log', ...)
%    - sets add_processing_log to contain text describing the sum
%      normalization
%
% setappdata(gcf,'temp_suffix','_sum_normalize') 
%    - sets the temp_suffix appdata so that the suffixes of the saved files
%      will reflect the operations performed on them
%
%
% -------------------------------------------------------------------------
% Examples
% -------------------------------------------------------------------------
%
% >> sum_normalize
% 
% this should only be called from within the fixed_spectra program
%
% -------------------------------------------------------------------------
% Authors
% -------------------------------------------------------------------------
%
% Paul Anderson (May 2012) pauleanderson@gmail.com
%
% Eric Moyer (May 2012) eric_moyer@yahoo.com
%

prompt={'Sum:'};
name='Normalize to what sum';
numlines=1;
defaultanswer={'1000'};
answer=inputdlg(prompt,name,numlines,defaultanswer);
target_sum = str2double(answer{1});

collections = getappdata(gcf,'collections');
for c = 1:length(collections)
    collections{c}.Y_fixed = collections{c}.Y;
    for s = 1:collections{c}.num_samples
        sm = sum(collections{c}.Y(:,s));
        collections{c}.Y_fixed(:,s) = collections{c}.Y(:,s)/sm*target_sum;
    end
end
setappdata(gcf,'collections',collections);
setappdata(gcf,'add_processing_log',sprintf('Sum normalized to %g.',target_sum));
setappdata(gcf,'temp_suffix','_sum_normalize');
plot_all
