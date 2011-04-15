%% Prepare input
load('data');
load('y_baseline');
load('y_noise');
x = data(:,1);
y = data(:,2);
inxs = find(y == 0);
y = y + y_baseline + y_noise;
y(inxs) = 0;
regions = [11.6,9.5;0.4,-2];

[y_fixed,y_calc_baseline] = fix_baseline(x,y,regions,20);

%% Display the results
plot(x,y,x,y_fixed,x,y_calc_baseline,x,y_baseline);
legend('y','y fixed','y calc baseline','y baseline');
set(gca,'xdir','reverse');
nm = size(regions);
for i = 1:nm(1)
    line([regions(i,1),regions(i,1)],ylim,'Color','g');
    line([regions(i,2),regions(i,2)],ylim,'Color','r');
end
