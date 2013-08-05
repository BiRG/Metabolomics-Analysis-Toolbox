function width = width_for_collision_prob(prob)
% Given the approximate probability that a spectrum with seven peaks in a 
% bin of that width will be missing at least one local maxima, gives the
% width of used to produce that probability in the TestSummitDeconv2013
% experiment.
%
% width - the width of the spectrum
%
% prob - the approximate probability of a collision (rounded to nearest
%     0.1)

mean_peak_width = 0.00453630122481774988;
widths =    [5.75, 26.785578117253827, 37.81403585728431, 50.275739222321697, 65.69707458955628, 86.66187912294609, 116.95643024521793, 167.91940604135232, 267.69215637895581, 563.31293102047039].*mean_peak_width;
probs = 1 - [0,    0.1,                0.2,               0.3,                0.4,               0.5,               0.6,                0.7,                0.8,                0.9];
matches = abs(probs-prob) < 1e-4;
if ~any(matches)
    error('width_for_collision_prob:unknown_prob', ...
        'The collision probability %.18g is not in the list known from the experiments. You likely forgot to update the list after doing a new experiment.', prob);
end
if sum(matches) > 1
    error('width_for_collision_prob:more_than_one_match', ...
        'Some of the probabilities in the list of experimental widths are too close together leading %.18g to match more than one', prob);
end
width = widths(matches);


end
