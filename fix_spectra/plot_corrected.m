function plot_corrected(mode)
    
    spectrum_inx = getappdata(gcf,'spectrum_inx');
    collections = getappdata(gcf, 'collections');
    [x, Y] = combine_collections(collections);
    y = Y(:, spectrum_inx);
    
    if (strcmp(mode, 'rb'))
        background = rollingball(x, y);
    end
    
    y_corrected = y - background;
    
    hold on;
    plot(x,background,'b');
    plot(x,y_corrected,'r');
    hold off;
end


function output = rollingball(x, y)
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
    
    deltax = mode(diff(x));
    
    N = size(y, 1); % input(1),...,input(N)
    K = floor(radius / deltax); % K is number of neighbors
	output = y - radius; % Constrain from each point
    
    for k = 1:K % Constrain from kth left/right neighbors
        st = k + 1; en = N - k; % start and end markers
        V = y - sqrt(radius^2 - (k * deltax)^2);
        output(1:en) = min(output(1:en), V(st:N)); % left
        output(st:N) = min(output(st:N), V(1:en)); % right
    end
    
    output = output + radius;
end
