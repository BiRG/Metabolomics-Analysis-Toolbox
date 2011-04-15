main_h = figure;
load('x188');
x = x188(:,1);
y = x188(:,2);
 
%plots the x and y data
plot(x,y);
set(gca,'xdir','reverse');
main_ax = gca;

%adds a title, x-axis description, and y-axis description
xlabel('Chemical shift, ppm');
ylabel('Peak Height');

h_molecules = GUIMainV1;
setappdata(h_molecules,'main_h',main_h);
setappdata(h_molecules,'main_ax',main_ax);
setappdata(h_molecules,'x',x);
setappdata(h_molecules,'y',y);