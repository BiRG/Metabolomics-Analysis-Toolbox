function p = collision_prob_for_width(width)
% Given a spectrum width from the list of widths I used for the 
% TestSummitDeconv2013 experiment, gives the approximate probability that a
% spectrum with seven peaks in a bin of that width will be missing
% at least one local maximum 
%
% width - the width of the spectrum
%
% p - the approximate probability of a collision

mean_peak_width = 0.00453630122481774988;
widths =    [5.75, 26.785578117253827, 37.81403585728431, 50.275739222321697, 65.69707458955628, 86.66187912294609, 116.95643024521793, 167.91940604135232, 267.69215637895581, 563.31293102047039].*mean_peak_width;
probs = 1 - [0,    0.1,                0.2,               0.3,                0.4,               0.5,               0.6,                0.7,                0.8,                0.9];
matches = abs(widths-width) < 1e-4;
if ~any(matches)
    error('TestSummitDeconv2013:collison_prob_for_width:unknown_width', ...
        'The width %.18g is not in the list known from the experiments. You likely forgot to update the list after doing a new experiment.', width);
end
if sum(matches) > 1
    error('TestSummitDeconv2013:collison_prob_for_width:more_than_one_match', ...
        'Some of the widths in the list of experimental widths are too close together leading %.18g to match more than one', width);
end
p = probs(matches);


end
