%function [backgr, corrected] = raman_correction(y)
function raman_correction(y)
    
    scales = 1:1:70;
    wCoefs = zhang_cwt(y, scales);
    
    localMax = getLocalMaximumCWT(wCoefs, scales, 5, 0);
    
    ridgeList = getRidge(localMax, ncol(localMax), -1, 1, 5, 3, 2);
    
    %majorPeakInfo = identifyMajorPeaks(y, ridgeList, wCoefs, SNR.Th = 1, ridgeLength = 5);
    %peakWidth = widthEstimationCWT(y, majorPeakInfo);
    
    %backgr = baselineCorrectionCWT(y, peakWidth, lambda = 1000, differences = 1);
    %corrected = y - backgr;
end


function wCoefs = zhang_cwt(ms, scales)
    
    ms = ms';
    psi_xval = linspace(-8, 8, 1024);
    psi = (2/sqrt(3) .* pi.^(-0.25)) .* (1 - psi_xval.^2) .* exp(-psi_xval.^2/2);
    
    oldLen = numel(ms);
    
    % To increase the computation effeciency of FFT, extend it as the power of 2
    nR = numel(ms);
    nR1 = 2^nextpow2(nR);
    if nR ~= nR1
        ms = [ms, ms(nR:-1:(2 * nR - nR1 + 1))];
    end
    
    len = numel(ms);
    
    wCoefs = zeros(numel(scales), len);
    
    psi_xval = psi_xval - psi_xval(1);
    dxval = psi_xval(2);
    xmax  = psi_xval(end);
    for i = 1:numel(scales)
        scalei = scales(i);
        f = zeros(1, len);
        j = 1 + floor((0:(scalei * xmax))/(scalei * dxval));
        if numel(j) == 1
            j = [1, 1];
        end
        lenWave = numel(j);
        f(1:lenWave) = wrev(psi(j)) - mean(psi(j));
        if numel(f) > len
            disp('scale is too large!');
            return
        end
        wCoefsi = 1/sqrt(scalei) .* wrev(cconv(wrev(ms),f,numel(ms)));
        
        % Shift the position with half wavelet width
        wCoefsi = [wCoefsi((len-floor(lenWave/2) + 1) : len), wCoefsi(1:(len-floor(lenWave/2)))];
        wCoefs(i, :) = wCoefsi;
    end
    
    wCoefs = wCoefs(1:end, 1:oldLen)';
end


function localMax = getLocalMaximumCWT(wCoefs, scales, minWinSize, ampThresh)
    
    localMax = zeros(size(wCoefs));
    
    for i = 1:numel(scales)
        winSize = scales(i) * 2 + 1;
        if winSize < minWinSize
            winSize = minWinSize;
        end
        temp = localMaximum(wCoefs(:,i), winSize)';
        localMax(:, i) = temp;
    end
    
    % Set the values less than peak threshold as 0
	localMax(wCoefs < ampThresh) = 0;
end


function localMax = localMaximum(x, winSize)
    
    len = numel(x);
    rNum = ceil(len / winSize);
    
    % Transform the vector as a matrix with column length equals winSize
	% and find the maximum position at each row.
    y = reshape([x; ones(rNum * winSize - len, 1) * x(end)], winSize, rNum);
    [~, ymaxInd] = max(y);
    
    % Only keep the maximum value larger than the boundary values
    selInd = find(max(y) > y(1, :) & max(y) > y(end, :));
    
    % keep the result
    localMax = zeros(1, len);
    localMax((selInd - 1) * winSize + ymaxInd(selInd)) = 1;
    
    % Shift the vector with winSize/2 and do the same operation
	shift = floor(winSize / 2);
    rNum = ceil((len + shift) / winSize);
    y = reshape([ones(shift, 1) * x(1); x; ones(rNum * winSize - len - shift, 1) * x(end)], winSize, rNum);
    [~, ymaxInd] = max(y);
    
    % Only keep the maximum value larger than the boundary values
    selInd = find(max(y) > y(1, :) & max(y) > y(end, :));
    localMax((selInd - 1) * winSize + ymaxInd(selInd) - shift) = 1;
    
    % Check whether there is some local maxima have in between distance less than winSize
    maxInd = find(localMax > 0);
    selInd = find(diff(maxInd) < winSize);
    
    if numel(selInd) > 0
        selMaxInd1 = maxInd(selInd);
		selMaxInd2 = maxInd(selInd + 1);
        temp = x(selMaxInd1) - x(selMaxInd2);
		localMax(selMaxInd1(temp <= 0)) = 0;
		localMax(selMaxInd2(temp > 0)) = 0;
    end
end

function abc = getRidge(localMax, iInit, step, iFinal, minWinSize, gapTh, skip)
end