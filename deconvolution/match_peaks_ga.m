function [match_ids,final_score] = match_peaks_ga(answer_maxs,calc_maxs,max_distance)
answer_mask = ones(size(answer_maxs));
calc_mask = ones(size(calc_maxs));

if isempty(calc_mask) || isempty(answer_mask)
    [match_ids,final_score] = match_peaks_dynamic(answer_maxs,calc_maxs,max_distance);
    return;
end

PopulationType = 'bitstring';
PopulationSize = 20;
InitialPopulation = {};
numTurnOff = ceil(0.1*length(calc_mask));
for p = 1:PopulationSize
    InitialPopulation{end+1} = calc_mask;
    inxs = randi(length(calc_mask),numTurnOff);
    InitialPopulation{end}(inxs) = 0;
end
options = gaoptimset('PopulationType',PopulationType,'PopulationSize',PopulationSize);

f1 = @(mask) (apply_mask_and_score(mask,answer_maxs,calc_maxs,max_distance));
f2 = @(mask) (abs(length(answer_mask) - sum(mask)));
fitness = @(mask) ([f1(mask) f2(mask)]);
[x,f,exitflag] = gamultiobj(fitness,length(calc_mask),[],[],[],[],[],[],options)
final_mask = x(1,:);
[final_score,match_ids] = apply_mask_and_score(final_mask,answer_maxs,calc_maxs,max_distance);

function [score,final_match_ids] = apply_mask_and_score(mask,answer_maxs,calc_maxs,max_distance)
inxs = find(mask == 1);
[match_ids,score] = match_peaks_dynamic(answer_maxs,calc_maxs(inxs),max_distance);
final_match_ids = match_ids;
for m = 1:length(match_ids)
    if match_ids{m}(2) ~= 0
        final_match_ids{m}(2) = inxs(match_ids{m}(2));
    end
end
inxs = find(mask == 0);
for i = 1:length(inxs)
    final_match_ids{end+1} = [0,inxs(i)];
end

function score = nearest(mask,answer_maxs,calc_maxs)
