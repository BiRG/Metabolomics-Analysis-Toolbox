function solution = score(intensitiy, L_in_group, S_in_window)

baseY = L_in_group;
sampleY = S_in_window;

sm = sum((sampleY-baseY).^2)/length(intensities);
%Calculate sum useing baseY and sampleY
% for i=1:length(intensity)
%     sum = sum + (sampleY - baseY);
% end

%Calculates final score and stores in returning variable.
solution = sm;