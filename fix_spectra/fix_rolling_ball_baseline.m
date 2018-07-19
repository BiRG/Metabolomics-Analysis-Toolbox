function fix_rolling_ball_baseline
%rolling_ball_baseline Summary of this function goes here
%   Detailed explanation goes here
prompt={'Enter min/max window:', 'Enter smoothing window:'};
name='Rolling ball';
rbparams = getappdata(gcf, 'rbparams');
if size(rbparams, 2) ~= 2
    rbparams = {'21', '13'};
answer = inputdlg(prompt, name, [1, 35], rbparams);
setappdata(gcf, 'rbparams', answer);

if(isempty(answer))
    return
end

wm = str2double(answer{1});
ws = str2double(answer{2});
collections = getappdata(gcf,'collections');
for c = 1:length(collections)
    for s = 1:collections{c}.num_samples
        y = collections{c}.Y(:,s);
        baseline = rolling_ball_baseline(y, wm, ws);
        collections{c}.Y_baseline(:,s) = baseline;
        collections{c}.Y_fixed(:,s) = y - baseline;
    end
end
%setappdata(gcf,'add_processing_log','Fixed baseline.');
setappdata(gcf,'add_processing_log',sprintf('Fix baseline (rolling ball, wm: %f, ws: %f).',wm,ws));
setappdata(gcf,'temp_suffix','_fixed_baseline');
setappdata(gcf,'collections',collections);

plot_all
end