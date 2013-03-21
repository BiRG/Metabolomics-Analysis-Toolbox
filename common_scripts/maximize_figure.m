function maximize_figure( figure_num, num_monitors)
% Maximize the specified figure
% 
% Usage: maximize_figure( figure_num, num_monitors)
%
% -----------------------------------------
% Input Args
% -----------------------------------------
%
% figure_num - the number of the figure to maximize pass
%
% num_monitors - the number of monitors being used under linux
%
% -----------------------------------------
% Output Args
% -----------------------------------------
%
% None
%
% 
% -----------------------------------------
% Examples
% -----------------------------------------
%
% >> maximize_figure( gcf, 1)
%
% Maximizes the current figure on a single monitor system
%
% 
% -----------------------------------------
% Author
% -----------------------------------------
%
% Eric Moyer (March 2013)

screen_size = get(0,'Screensize');
set(figure_num, 'Position', [screen_size(1:2),screen_size(3)/num_monitors, screen_size(4)]); % Maximize figure in a dual monitor unix environment - which will be a half-width, full height window in a single monitor environment.

end

