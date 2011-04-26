function [left_noise,right_noise] = get_noise(calling_gcf)
left_noise_cursor = getappdata(calling_gcf,'left_noise_cursor');
right_noise_cursor = getappdata(calling_gcf,'right_noise_cursor');
if isempty(left_noise_cursor) || isempty(right_noise_cursor)
    msgbox('Set the noise cursors');
    left_noise = NaN;
    right_noise = NaN;
    error_set_noise_cursors
    return
end
left_noise = GetCursorLocation(calling_gcf,left_noise_cursor);
right_noise = GetCursorLocation(calling_gcf,right_noise_cursor);
if right_noise > left_noise
    t = left_noise;
    left_noise = right_noise;
    right_noise = t;
end
