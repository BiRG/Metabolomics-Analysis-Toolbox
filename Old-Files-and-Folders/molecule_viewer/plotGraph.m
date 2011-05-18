function plotGraph()

% Load in the file.
load('x188');
i = 4;
figure
x = x188(:,1);
y = x188(:,2);
plot(x,y,'k')

% Why reverse this?
set(gca,'xdir','reverse');


% Populate with the library molecules.
hold on

MGPX = [];
loc_of_height = 0;
min_height = Inf;
for p = 1:length(molecules(i).ppm)
    if molecules(i).peakHeight(p) < min_height
        loc_of_height = molecules(i).ppm(p);
        min_height = molecules(i).peakHeight(p);
    end
    MGPX = [MGPX,molecules(i).peakHeight(p),0.005,0,molecules(i).ppm(p)];
end
[mn,inx] = min(abs(x-loc_of_height));
max_height = y(inx);
MGPX(1:4:end) = max_height*MGPX(1:4:end);
y_peaks = global_model(MGPX,x,length(molecules(i).ppm),[]);
plot(x,y_peaks);

xlabel('Chemical shift, ppm')
ylabel('Peak Height')

hold off