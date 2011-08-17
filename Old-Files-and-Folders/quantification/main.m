% main.m
%
% This script is intended to visualize and quantify NMR spectra.
%
% Key press documentation:
%   r - resets the zoom
%   u - updates the children figures
%   pageup - zooms out the x axis
%   pagedown - zoom in the x axis
%   home - zooms out the y axis
%   down - zooms in the y axis
addpath('../common_scripts');
addpath('../common_scripts/cursors');
addpath('molecule_viewer');

% Start
figure
set(gca,'xdir','reverse')
xlabel('Chemical shift, ppm')
ylabel('Intensity')
myfunc = @(hObject, eventdata, handles) (click_menu(gcf,gca));
set(gca,'ButtonDownFcn',myfunc)
myfunc = @(hObject, eventdata, handles) (key_press(gcf,gca));
set(gcf,'KeyPressFcn',myfunc);
set(gcf,'CloseRequestFcn',@closing_main_window);
main_h = gcf;
h_options = options;
setappdata(main_h,'h_options',h_options);
set(h_options,'Visible','off');
figure(main_h);
myfunc = @(src,evnt) (set(h_options,'Visible','off')); 
set(h_options,'CloseRequestFcn',myfunc);