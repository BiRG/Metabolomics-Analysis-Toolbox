function collection = quantify(collection,reference)
inxs1 = find(reference.include_mask == 1);
xvs = reference.max_ids(inxs1);
collection.Y = zeros(length(xvs),length(collection.BETA));
for s = 1:length(collection.BETA)
    BETA = collection.BETA{s};
    match_ids = collection.match_ids{s};
    for j = 1:length(xvs)
        xv = xvs(j);
        inxs2 = find(match_ids == xv);
        for k = 1:length(inxs2)
            p = inxs2(k);
            collection.Y(j,s) = collection.Y(j,s) + sum(one_peak_model(BETA(4*(p-1)+(1:4)),collection.x));
        end
    end
end
collection.x = xvs;

