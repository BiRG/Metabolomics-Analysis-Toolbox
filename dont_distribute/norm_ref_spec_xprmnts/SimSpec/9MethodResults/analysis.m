%% Load data file
load('9MethodExp-2012-08Aug-02.mat');
res=results_Aug_02;
res.short_method_names={...
    'Sum Norm', ...
    'PQN A A', ...
    'PQN C A', ...
    'PQN A 3 iqr', ...
    'PQN A 2 iqr', ...
    'Hist log cnt', ...
    'Hist equ cnt', ...
    'Hist log prb', ...
    'Hist equ prb' ...
    };

%% Set up some variables
num_meth = 9;
assert(num_meth == length(res.short_method_names));
num_spec_col = 1; % Number of spectra column
pct_ctl_col = 2; % Percent control column
trt_grp_col = 3; % Identifier for which spectra were used as the treatment group
cdil_col = 4; %Control dilution range column
tdil_col = 5; %Treatment dilution range column
meth_col = 7;
rmse_col = 8;
rmse_l_col = 9;

meth_names = res.short_method_names;
dil_name = {'None','Small','Large','Extreme'}; %Names for dilution ranges
pct_ctl_vals = unique(d(:, pct_ctl_col));

%% Fix miscalculation in of RMSE and RMSE_Log
% The original code forgot to divide by the number of spectra before taking
% the square root, this can be fixed in post processing by dividing by the
% square root of the number of spectra

for row = 1:size(res.data,1)
    cor_fac = sqrt(res.data(row, num_spec_col));
    res.data(row, rmse_col) = res.data(row, rmse_col) / cor_fac;
    res.data(row, rmse_l_col) = res.data(row, rmse_l_col) / cor_fac;
end

%% Split by method only
figure(1);
d = res.data;
assert(num_meth == length(res.short_method_names));
for m=1:num_meth
    subplot(3,3,m);
    vals = d(d(:,meth_col) == m, rmse_l_col);
    edgs = 0:0.025:9;
    centers = (edgs(1:end-1)+edgs(2:end))/2;
    counts = histc(vals, edgs);
    bar(centers, counts(1:end-1), 'FaceColor','r','EdgeColor', 'none');
    xlim([0, 9]);
    ylim([0, 1000]);
    xlabel('RMSE (Log)');
    ylabel('# Spec Set');
    title(res.short_method_names{m});
end
mtit(1,'Error Per Method', 'xoff',0, 'yoff', 0.05);

%% Looking only at reasonable dilutions
figure(2);
d = res.data;
for m=1:num_meth
    subplot(3,3,m);
    vals = d(d(:,meth_col) == m & d(:,cdil_col)<= 2 & d(:,tdil_col) <=2, rmse_l_col);
    edgs = 0:0.025:9;
    centers = (edgs(1:end-1)+edgs(2:end))/2;
    counts = histc(vals, edgs);
    bar(centers, counts(1:end-1), 'FaceColor','r','EdgeColor', 'none');
    xlim([0, 9]);
    ylim([0, 1000]);
    xlabel('RMSE (Log)');
    ylabel('# Spec Set');
    title(res.short_method_names{m});
end
mtit(2,'Error Per Method (Reasonable dilutions)', 'xoff',0, 'yoff', 0.03);

%% Looking only at where treatment and control dilutions are both large or extreme
figure(3);
d = res.data;
for m=1:num_meth
    subplot(3,3,m);
    vals = d(d(:,meth_col) == m & d(:,cdil_col)> 2 & d(:,tdil_col) > 2, rmse_l_col);
    edgs = 0:0.025:9;
    centers = (edgs(1:end-1)+edgs(2:end))/2;
    counts = histc(vals, edgs);
    bar(centers, counts(1:end-1), 'FaceColor','r','EdgeColor', 'none');
    xlim([0, 9]);
    ylim([0, 1000]);
    xlabel('RMSE (Log)');
    ylabel('# Spec Set');
    title(res.short_method_names{m});
end
mtit(3,'Error Per Method (Unreasonable dilutions)', 'xoff',0, 'yoff', 0.03);

%% Looking when control is normal and treatment is large
figure(4);
d = res.data;
for m=1:num_meth
    subplot(3,3,m);
    vals = d(d(:,meth_col) == m & d(:,cdil_col)<= 2 & d(:,tdil_col) == 3, rmse_l_col);
    edgs = 0:0.025:9;
    centers = (edgs(1:end-1)+edgs(2:end))/2;
    counts = histc(vals, edgs);
    bar(centers, counts(1:end-1), 'FaceColor','r','EdgeColor', 'none');
    xlim([0, 9]);
    ylim([0, 450]);
    xlabel('RMSE (Log)');
    ylabel('# Spec Set');
    title(res.short_method_names{m});
end
mtit(4,'Error Per Method (Control normal, treatement large)', 'xoff',0, 'yoff', 0.03);

%% Looking when control is normal and treatment is extreme
figure(5);
d = res.data;
for m=1:num_meth
    subplot(3,3,m);
    vals = d(d(:,meth_col) == m & d(:,cdil_col)<= 2 & d(:,tdil_col) == 4, rmse_l_col);
    edgs = 0:0.025:9;
    centers = (edgs(1:end-1)+edgs(2:end))/2;
    counts = histc(vals, edgs);
    bar(centers, counts(1:end-1), 'FaceColor','r','EdgeColor', 'none');
    xlim([0, 9]);
    ylim([0, 450]);
    xlabel('RMSE (Log)');
    ylabel('# Spec Set');
    title(res.short_method_names{m});
end
mtit(5,'Error Per Method (Control normal, treatement extreme)', 'xoff',0, 'yoff', 0.03);

%% Looking when control is large and treatment is normal
figure(6);
d = res.data;
for m=1:num_meth
    subplot(3,3,m);
    vals = d(d(:,meth_col) == m & d(:,cdil_col)== 3 & d(:,tdil_col) <= 2, rmse_l_col);
    edgs = 0:0.025:9;
    centers = (edgs(1:end-1)+edgs(2:end))/2;
    counts = histc(vals, edgs);
    bar(centers, counts(1:end-1), 'FaceColor','r','EdgeColor', 'none');
    xlim([0, 9]);
    ylim([0, 450]);
    xlabel('RMSE (Log)');
    ylabel('# Spec Set');
    title(res.short_method_names{m});
end
mtit(6,'Error Per Method (Control large, treatement normal)', 'xoff',0, 'yoff', 0.03);

%% Looking at all combinations of control and treatment dilutions
figure(7);
d = res.data;
edgs = 0:0.075:9;
centers = (edgs(1:end-1)+edgs(2:end))/2;
colors = {[0.5,0.5,0.5],'m',[0.5,0,0],'r','y','g','b','c',[0,0,0.5]};
for cdil = 1:4
    for tdil = 1:4
        subplot(4,4,((cdil-1)*4)+tdil);
        hold off;

        for m = 1:num_meth
            vals = d(d(:,meth_col) == m & ...
                d(:,cdil_col) == cdil &...
                d(:,tdil_col) == tdil, rmse_l_col);
            counts = histc(vals, edgs);
            bars=bar(centers, counts(1:end-1), 'FaceColor',colors{m},...
                'DisplayName', res.short_method_names{m}, ...
                'EdgeColor', 'none', 'BarWidth',1);
            if m==1
                hold on;
            end
        end
        alpha(0.5);
        xlim([0, 9]);
        ylim([0, 350]);
        xlabel('RMSE (Log)');
        ylabel('# Spec Set');
        title(sprintf('c:%s t:%s',dil_name{cdil},dil_name{tdil}));
    end
end
hold off;
mtit(7,'Effect of different dilution combinations on different methods', 'xoff',0, 'yoff', 0.03);

%% Looking at all combinations of control and treatment dilutions, but ignoring the prob histogram matching
figure(8);
d = res.data;
edgs = 0:0.0625:6;
centers = (edgs(1:end-1)+edgs(2:end))/2;
colors = {[0.5,0.5,0.5],'m',[0.5,0,0],'r','y','g','b'};
bar_objs = cell(1,16);
for cdil = 1:4
    for tdil = 1:4
        plot_num = ((cdil-1)*4)+tdil;
        subplot(4,4, plot_num);
        hold off;

        for m = 1:num_meth-2
            vals = d(d(:,meth_col) == m & ...
                d(:,cdil_col) == cdil &...
                d(:,tdil_col) == tdil, rmse_l_col);
            counts = histc(vals, edgs);
            bar_objs=bar(centers, counts(1:end-1), 'FaceColor',colors{m},...
                'DisplayName', res.short_method_names{m}, ...
                'BarWidth',1, ...
                'EdgeColor', 'none');
            if m==1
                hold on;
            end
        end
        alpha(0.5);
        xlim([0, 6]);
        ylim([0, 500]);
        xlabel('RMSE (Log)');
        ylabel('# Spec Set');
        title(sprintf('c:%s t:%s',dil_name{cdil},dil_name{tdil}));
    end
end
hold off;
mtit(8,'Effect of different dilution combinations on different methods (ignoring 2 worst)', 'xoff',0, 'yoff', 0.03);

%% Look only at summary statistics for the different dilutions rather than plotting full pdfs (still ignore bad methods)
figure(9);
d = res.data;
for cdil = 1:4
    for tdil = 1:4
        plot_num = ((cdil-1)*4)+tdil;
        subplot(4,4, plot_num);

        groups = d(d(:,meth_col) <= 7 & ...
            d(:,cdil_col) == cdil &...
            d(:,tdil_col) == tdil, meth_col);
        vals = d(d(:,meth_col) <= 7 & ...
            d(:,cdil_col) == cdil &...
            d(:,tdil_col) == tdil, rmse_l_col);
        boxplot(vals,groups,'notch','on');
        ylim([0, 3]);
        xlabel('Method');
        ylabel('RMSE (Log)');
        title(sprintf('c:%s t:%s',dil_name{cdil},dil_name{tdil}));
    end
end
hold off;
mtit(9,'Effect of different dilution combinations on different methods', 'xoff',0, 'yoff', 0.05);

%% Look at effect of number of spectra on the different methods for only normal and no dilution - num_spec in subplots
figure(10);
d = res.data;
for num_spec_idx=1:2
    num_spec=num_spec_idx * 10;
    subplot(1,2, num_spec_idx);

    selected = d(:,meth_col) <= 7 & ...
        d(:, cdil_col) <= 2 & ...
        d(:, tdil_col) <= 2 & ...
        d(:, num_spec_col) == num_spec;
    groups = d(selected, meth_col);
    vals = d(selected, rmse_l_col);
    boxplot(vals,groups,'notch','on');
    ylim([0, .82]);
    xlabel('Method');
    ylabel('RMSE (Log)');
    title(sprintf('%d Spectra',num_spec));
end
hold off;
mtit(10,'Effect different # spectra', 'xoff',0, 'yoff', 0.05);

%% Look at effect of number of spectra on the different methods for only normal and no dilution - method in subplots
figure(11);
d = res.data;

for method = 1:7
    subplot(2,4, method);

    selected = d(:,meth_col) <= 7 & ...
        d(:, cdil_col) <= 2 & ...
        d(:, tdil_col) <= 2 & ...
        d(:,meth_col) == method;
    groups = d(selected, num_spec_col);
    vals = d(selected, rmse_l_col);
    boxplot(vals,groups,'notch','on');
    ylim([0, .82]);
    xlabel('# Spectra');
    ylabel('RMSE (Log)');
    title(sprintf('%s',meth_names{method}));
end
hold off;
mtit(11,'Effect different # spectra', 'xoff',0, 'yoff', 0.05);

%% Just print the summary statistics rather than plotting the data summarized for num_spectra and method
d = res.data;

fprintf('Table showing change in medians for groups with different numbers of spectra\n');
fprintf('%-12s %-8s %-8s %-8s\n','Method','#Spectra', 'Median', 'IQR');
for method = 1:7
    for num_spec_idx = 1:2
        num_spec = 10*num_spec_idx;
        
        selected = d(:,meth_col) <= 7 & ...
            d(:, cdil_col) <= 2 & ...
            d(:, tdil_col) <= 2 & ...
            d(:,meth_col) == method & ...
            d(:,num_spec_col) == num_spec;
        errs = d(selected, rmse_l_col);
        
        fprintf('%-12s %-8d %#8g %#8g\n', ...
            meth_names{method}, num_spec ,median(errs), iqr(errs));
    end
end

%% Now print the % change in the summary statistics for change in num spectra
d = res.data;

fprintf('Table showing %% change in median and iqr when going from 10 to 20 spectra\n');
fprintf('%-12s %9s %9s\n','Method', 'd Median', 'd IQR');
for method = 1:7        
    selected_10 = d(:,meth_col) <= 7 & ...
        d(:, cdil_col) <= 2 & ...
        d(:, tdil_col) <= 2 & ...
        d(:,meth_col) == method & ...
        d(:,num_spec_col) == 10;
    selected_20 = d(:,meth_col) <= 7 & ...
        d(:, cdil_col) <= 2 & ...
        d(:, tdil_col) <= 2 & ...
        d(:,meth_col) == method & ...
        d(:,num_spec_col) == 20;
    errs_10 = d(selected_10, rmse_l_col);
    errs_20 = d(selected_20, rmse_l_col);

    fprintf('%-12s %#7.4g %% %#7.4g %%\n', ...
        meth_names{method},...
        100*(median(errs_20)-median(errs_10))/median(errs_10), ...
        100*(iqr(errs_20)-iqr(errs_10))/iqr(errs_10));
end


%% Look at effect of percent control on the different methods for only normal and no dilution - % control in subplots
figure(12);
d = res.data;
assert(length(pct_ctl_vals) == 3);
for pct_ctl_idx = 1:3
    pct_ctl = pct_ctl_vals(pct_ctl_idx);
    
    subplot(1,3, pct_ctl_idx);

    selected = d(:,meth_col) <= 7 & ...
        d(:, cdil_col) <= 2 & ...
        d(:, tdil_col) <= 2 & ...
        d(:, pct_ctl_col) == pct_ctl;
    groups = d(selected, meth_col);
    vals = d(selected, rmse_l_col);
    boxplot(vals,groups,'notch','on');
    ylim([0, .82]);
    xlabel('Method');
    ylabel('RMSE (Log)');
    title(sprintf('%d%% control',pct_ctl));
end
hold off;
mtit(12,'Effect different percent control group', 'xoff',0, 'yoff', 0.05);


%% Look at effect of percent control on the different methods for only normal and no dilution - method in subplots
figure(13);
d = res.data;

for method = 1:7
    subplot(2,4, method);

    selected = d(:,meth_col) <= 7 & ...
        d(:, cdil_col) <= 2 & ...
        d(:, tdil_col) <= 2 & ...
        d(:,meth_col) == method;
    groups = d(selected, pct_ctl_col);
    vals = d(selected, rmse_l_col);
    boxplot(vals,groups,'notch','on');
    ylim([0, .82]);
    xlabel('% Conrol');
    ylabel('RMSE (Log)');
    title(sprintf('%s',meth_names{method}));
end
hold off;
mtit(13,'Effect different percent control group', 'xoff',0, 'yoff', 0.05);

%% Just print the summary statistics rather than plotting the data summarized for percent control and method
d = res.data;

fprintf('Table showing medians for groups with different percentages of control spectra\n');
fprintf('%-12s %-8s %-8s %-8s\n','Method','%Control', 'Median', 'IQR');
for method = 1:7
    for pct_ctl_idx = 1:3
        pct_ctl = pct_ctl_vals(pct_ctl_idx);
        
        selected = d(:,meth_col) <= 7 & ...
            d(:, cdil_col) <= 2 & ...
            d(:, tdil_col) <= 2 & ...
            d(:,meth_col) == method & ...
            d(:,pct_ctl_col) == pct_ctl;
        errs = d(selected, rmse_l_col);
        
        fprintf('%-12s %-8d %#8g %#8g\n', ...
            meth_names{method}, pct_ctl ,median(errs), iqr(errs));
    end
end

