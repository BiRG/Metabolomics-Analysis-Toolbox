function solutions = walkerCalc(plot_inxs,L_in_group, S_in_window)

%Window for each group
window_inxs{g} = plot_inxs;
% This is done already in show_molecules on plot_inxs
% [(group_inxs(1)-shift_inxs),(group_inxs(1)+shift_inxs)];

%Determine the intensities
%Fix this later, cheating!
deltaStep = .001;
intensities = [0.00001, deltaStep, max(y)];
solutions(length(intensities));
%Compute scores of given position
%(Set of shifts and heights)
solutions = {};
for i=1:length(intensities)
    intensity = intensities(i);
    
    %Need shift values for each window, get max score
    %Input: intensity, Output: Shift + Score
    for w=1:length(window_inxs)
        solutions(i) = score(intensitiy, L_in_group, S_in_window);
    end
    
end
    
    
    