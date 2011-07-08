function pN = minP(Pr,num_samples,N)
if ~exist('N')
    N = 1000; % Iterations
end
% 0 %
v = num_samples - 1; % deg freedom (equal variance)
NP = length(Pr);
count = zeros(size(Pr));

% 4 %
for j = 1:N
    Pstar = zeros(size(Pr));
    Qstar = zeros(size(Pr));
    
    % 1 %
    Y1 = randn(1, NP);
    Y2 = chi2rnd(v, 1, NP);
    for k = 1:NP
        %Pstar{k} = 2 * tcdf(-abs(Y1(k) / sqrt(Y2(k) / v)), samplesz-1);
        Pstar(k) = 2 * tcdf(-abs(Y1(k) / sqrt(Y2(k) / v)), v);
    end

    % 2 %
    Qstar(NP) = Pstar(NP);
    for q = NP-1:-1:1
        Qstar(q) = min([Qstar(q+1),Pstar(q)]);
    end
    
    % 3 %
    for i = 1:NP
        if Qstar(i) <= Pr(i)
            count(i) = count(i) + 1;
        end
    end
end

pN = zeros(size(Pr));
% 4 %
for i = 1:NP
    pN(i) = count(i)/N;
end

% 5 %
for k = 2:NP
    pN(k) = max([pN(k-1),pN(k)]);
end

%pN