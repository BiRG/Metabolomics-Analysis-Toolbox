library(baselineWavelet)
library(methods)
library(R.matlab)

args = commandArgs(trailingOnly=TRUE)
mat <- readMat(args[1])
y = mat$y

scales <- seq(1, 70, 1)
wCoefs <- cwt(y, scales=scales, wavelet='mexh')

localMax <- getLocalMaximumCWT(wCoefs)
ridgeList <- getRidge(localMax, gapTh=3, skip=2)

majorPeakInfo = identifyMajorPeaks(y, ridgeList, wCoefs, SNR.Th=1, ridgeLength=5)
peakWidth = widthEstimationCWT(y, majorPeakInfo)

backgr = baselineCorrectionCWT(y, peakWidth, lambda=1000, differences=1)
corrected = y - backgr 

writeMat(con = args[2], y_corrected = corrected, background = backgr)
