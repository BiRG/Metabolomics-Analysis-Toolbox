function fix_negative_points
%fix_negative_points adjust baseline so that negative points are set to 0.
collections = getappdata(gcf,'collections');
prompt={'Noise region for threshold (blank for none)'};
name='Threshold Noise Region';
x_left = collections{1}.x(1);
x_right = collections{1}.x(30);
noise_range = {[num2str(x_left) ',' num2str(x_right)]};
answer = inputdlg(prompt, name, [1, 35], noise_range);
if(isempty(answer))
    return
end
if (~isempty(answer{1}))
    noise_xval = str2double(strsplit(answer{1}, ','));
else
    noise_xval = [];
end


for c = 1:length(collections)
    for s = 1:collections{c}.num_samples
        if ~isempty(noise_xval)
            noise_min = get_noise_min(collections{c}.Y_fixed(:,s), collections{c}.x, noise_xval);
        else
            noise_min = 0;
        end
        inds = collections{c}.Y_fixed(:,s) < noise_min;
        collections{c}.Y_fixed(inds,s) = 0;
        collections{c}.Y_baseline(inds,s) = collections{c}.Y(inds,s) - collections{c}.Y_fixed(inds,s);
    end
end
setappdata(gcf,'collections',collections);
plot_all
end

function noise_min = get_noise_min(x, y, noise_range)
%noise_range is [largest, smallest]
noise_min = min(y(x <= noise_range(1) & x >= noise_range(2)));
end
