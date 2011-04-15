function [] = S_plot(T, X, SE)
cov = [];
corr = [];

for i=1:length(X)
    cov(i) = (T'*X(:,i))/(T'*T);
    corr(i) = (T'*X(:,i))/ (norm(T) * norm(X(:,i)));
    CIJF(1,i) = mean(SE(:,i)) - (std(SE(:,i))/sqrt(fold))*(tinv(.975,fold-1));
    CIJF(2,i) = mean(SE(:,i)) + (std(SE(:,i))/sqrt(fold))*(tinv(.975,fold-1));
end;

%[asel_bins,stats] = perm_cutoff(Y,X,100,.02,fold);
figure;
hold on;
for i=1:length(cov)
    if (CIJF(1,i)<0) && (CIJF(2,i)>0)
        scatter(cov(i), corr(i),'o','b');
    else
        scatter(cov(i), corr(i),'o','r');
    end
end
scatter(cov(asel_bins(1:10)), corr(asel_bins(1:10)),'o','r');
hold off;

