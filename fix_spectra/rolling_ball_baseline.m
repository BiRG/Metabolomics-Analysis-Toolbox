function baseline = rolling_ball_baseline(y, wm, ws)
%rolling_ball_baseline Summary of this function goes here
% y is a column vector representing a spectrum
% wm is the width of min/max window
% ws is the width of the smoothing window
% Based on the rolling ball baseline implemented in the R package baseline
    [m, ~] = size(y);
    T1 = zeros(size(y)); % minimizers
    T2 = zeros(size(y)); % maximizers
    baseline = zeros(size(y));

    % minimize
    u1 = ceil((wm+1) / 2) + 1;
    T1(1) = min(y(1:u1));
    % start of spectrum
    for i=2:wm
        u2 = u1 + 1 + mod(i, 2);
        T1(i) = min(min(y(u1+1:u2)), T1(i-1));
        u1 = u2;
    end
    % middle of spectrum
    for i = wm+1:m-wm
        if ((y(u1+1) <= T1(i-1)) && (y(u1-wm) ~= T1(i-1)))
            T1(i) = y(u1+1); % next is smaller
        else
            T1(i) = min(y(i-wm:i+wm));
        end
        u1 = u1 + 1;
    end
    % end of spectrum
    u1 = m - 2*wm - 1;
    for i = m-wm+1:m
        u2 = u1 + 1 + mod(i+1, 2);
        if min(y(u1:u2-1)) > T1(i-1)
            T1(i) = T1(i-1); % removed is larger
        else
            T1(i) = min(y(u2:m));
        end
        u1 = u2;
    end

    % maximize
    u1 = ceil((wm+1)/2) + 1;
    % start of spectrum
    T2(1) = max(T1(1:u1));
    for i = 2:wm
        u2 = u1 + 1 + mod(i, 2);
        T2(i) = max(max(T1(u1+1:u2)), T2(i-1));
        u1 = u2;
    end
    % middle of spectrum
    for i = wm+1:m-wm
        if (T1(u1+1) >= T2(i-1)) && (T1(u1-wm) ~= T2(i-1))
            T2(i) = T1(u1+1);
        else
            T2(i) = max(T1(i-wm:i+wm));
        end
        u1 = u1 + 1;
    end
    % end of spectrum
    u1 = m - 2*wm - 1;
    for i = m-wm+1:m
        u2 = u1 + 1 + mod(i+1, 2);
        if max(T1(u1:u2-1)) < T2(i-1)
            T2(i) = T2(i-1);
        else
            T2(i) = max(T1(u2:m));
        end
        u1 = u2;
    end

    % Smoothing
    u1 = ceil(ws/2);
    % start of spectrum
    v = sum(T2(1:u1));
    for i = 1:ws
        u2 = u1 + 1 + mod(i, 2);
        v = v + sum(T2(u1+1:u2));
        baseline(i) = v/u2;
        u1 = u2;
    end
    % middle of spectrum
    v = sum(T2(1:2*ws+1));
    baseline(ws+1) = v/(2*ws+1);
    for i = ws+2:m-ws
        v = v - T2(i-ws-1) + T2(i+ws);
        baseline(i) = v/(2*ws+1);
    end
    u1 = m - 2*ws+1;
    v = v - T2(u1); % sum so far
    baseline(m-ws+1) = v/(2*ws); % mean so far
    % end of spectrum
    for i = m-ws+2:m
        u2 = u1+ 1 + mod(i+1,2);
        v = v - sum(T2(u1:u2-1));
        baseline(i) = v/(m-u2+1);
        u1 = u2;
    end

end

