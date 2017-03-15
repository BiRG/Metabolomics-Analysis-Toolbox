function plot_corrected()
    
    spectrum_inx = getappdata(gcf,'spectrum_inx');
    collections = getappdata(gcf, 'collections');
    [x, Y] = combine_collections(collections);
    y = Y(:, spectrum_inx);
    
%     save('raman_scripts/raman_in.mat', 'y');
%     system('Rscript raman_scripts/adjustsignal.R raman_scripts/raman_in.mat raman_scripts/raman_out.mat');
%     load('raman_scripts/raman_out.mat');
%     delete('raman_scripts/raman_in.mat', 'raman_scripts/raman_out.mat');
    
    %[background, y_corrected] = raman_correction(y);
    
    background = rollingball(y);
    background = spline(x, background, x(1:(0.05 / 0.0005):numel(x)))';
    
    y_corrected = y - background;
    
%     ind = find(x > 3.5 & x < 4.5);
%     xx = x(ind)';
%     yy = y(ind);
%     [background, y_corrected] = FreeIModPoly(yy, xx);
    
    hold on;
    plot(x,background,'b');
    plot(x,y_corrected,'r');
    hold off;
end


function output = rollingball(input)
% performs rolling ball filter for ball below input
% input is a column vector of sample values
% radius is the radius of the ball rolling under graph
% deltax is spacing of sample points

    prompt = {'Enter the radius of the ball:'};
    name = 'Rolling ball';
    numlines = 1;
    defaultanswer = {'0.05'};
    answer = inputdlg(prompt, name, numlines, defaultanswer);
    if(isempty(answer))
        return
    end
    radius = str2double(answer{1});

    prompt = {'Enter delta x:'};
    name = 'Rolling ball';
    numlines = 1;
    defaultanswer = {'0.0005'};
    answer = inputdlg(prompt, name, numlines, defaultanswer);
    if(isempty(answer))
        return
    end
    deltax = str2double(answer{1});

    N = size(input, 1); % input(1),...,input(N)
    K = floor(radius / deltax); % K is number of neighbors
	output = input - radius; % Constrain from each point

    for k = 1:K % Constrain from kth left/right neighbors
        st = k + 1; en = N - k; % start and end markers
        V = input - sqrt(radius^2 - (k * deltax)^2);
        output(1:en) = min(output(1:en), V(st:N)); % left
        output(st:N) = min(output(st:N), V(1:en)); % right
    end
    
    output = output + radius;
end
