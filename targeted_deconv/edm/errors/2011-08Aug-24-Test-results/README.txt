This directory holds the data files from an analysis of the
performance of our region deconvolution code on synthetic spectra.
The spectra were created to represent a number of circustances that
might be causing problems with the deconvolution.

The tests were done with git revision
010491e6187141a8babc9bc52fb2a4aefb8ee5b5 of targeted_identify.

20 spectra were generated and saved to files along with the correct
deconvolution.  Then targeted_identify was started up with the exact
peak locations for all peaks in the spectra marked.  This was done
through the write_test_collection_to_foo_files matlab function.  Eric
Moyer went through the spectra by hand, marking any peaks necessary
and calculating the deconvolutions and attempting to make them as good
as possible.  The results were saved in the *perfect_peaks* files.

For the next phase the targeted_deconvolution_start code was used to
load 7_bin_test.bins.csv and 7_bin_test.xy.txt.  Then Eric went
through the spectra attempting to analyze them by eye, to ignore the
fact that he knew many of the actual locations, and to perform the
deconvolutions as well as possible.  This was intended to simulate the
real conditions an analyst would face in using the software.  The
results were saved in the *detected_peaks* files.

I later created a set of bins (by eye) and quantified by summing the
values in the bins.  The binning ranges are in
7_bin_test.bins_used_for_quant_by_binning.txt.  The results of the
binning (after some hand-manipulation to put it in the right format
for my test analysis software) are in
7_bin_test.hand-binning-quant.xy.txt.

After these steps, the results were analyzed using:

print_test_analysis('7_bin_test.dec.correct.xy.txt',
                    '7_bin_test.dec.detected_peaks.xy.txt')

print_test_analysis('7_bin_test.dec.correct.xy.txt', 
                    '7_bin_test.dec.perfect_peaks.xy.txt')

print_test_analysis('7_bin_test.dec.correct.xy.txt',
                    '7_bin_test.hand-binning-quant.xy.txt')


They are below under the heading "Results".

The notes Eric took while doing the analysis follow the results under
a section titled "Notes".

Results
-------

In the summary, Mn %dif is the mean percentage difference derived by
calculating 100*d-g/d.  Where d is the area calculated from the
spectrum by targeted deconvolution and g is the gold-standard from the
generating equations.  The following std-dev is the standard deviation
of that variable.

Results for perfect_peaks:
--------------------------

Raw percent errors:
1000000000:	 2.82	 2.17	 6.04	 2.71	16.08	 9.58	 0.57	 2.28	 5.69	 0.10	 3.12	 0.86	 2.08	 3.22	 1.76	26.11	 5.49	 2.78	 5.41	 3.83
1000000001:	 2.82	 2.17	 6.04	 2.71	16.08	 9.58	 0.57	 2.28	 5.69	 0.10	 3.12	 0.86	 2.08	 3.22	 1.76	26.11	 5.49	 2.78	 5.41	 3.83
1000001000:	24.31	53.07	23.26	 5.02	 1.64	39.44	 4.49	36.96	10.03	 8.15	25.15	14.58	22.22	24.42	10.60	21.46	45.85	31.85	40.66	 3.23
1000001001:	24.31	53.07	23.26	 5.02	 1.64	39.44	 4.49	36.96	10.03	 8.15	25.15	14.58	22.22	24.42	10.60	21.46	45.85	31.85	40.66	 3.23
1000002000:	27.57	39.61	19.88	 9.71	11.49	 9.64	35.12	18.70	20.61	 7.06	 9.29	17.22	 7.59	65.31	 3.38	25.87	40.25	22.15	28.28	10.26
1000002001:	27.57	39.61	19.88	 9.71	11.49	 9.64	35.12	18.70	20.61	 7.06	 9.29	17.22	 7.59	65.31	 3.38	25.87	40.25	22.15	28.28	10.26
1000003000:	 6.17	 6.39	18.00	 9.73	 4.21	24.12	17.46	 7.70	 1.87	20.37	17.25	 7.18	 1.13	 4.54	20.45	 0.90	 9.52	 4.02	 0.11	13.11
1000003001:	 6.17	 6.39	18.00	 9.73	 4.21	24.12	17.46	 7.70	 1.87	20.37	17.25	 7.18	 1.13	 4.54	20.45	 0.90	 9.52	 4.02	 0.11	13.11
1000004000:	23.94	125.39	31.99	 0.32	21.05	94.98	14.65	 6.01	39.88	30.93	96.91	21.36	120.65	 8.47	27.73	83.62	35.20	 7.36	105.01	 8.36
1000004001:	23.94	125.39	31.99	 0.32	21.05	94.98	14.65	 6.01	39.88	30.93	96.91	21.36	120.65	 8.47	27.73	83.62	35.20	 7.36	105.01	 8.36
1000005000:	57.67	43.33	40.14	49.41	17.86	66.50	58.58	46.06	40.92	50.32	100.00	66.84	18.59	73.46	63.56	57.22	58.34	 1.52	44.03	72.09
1000005001:	57.67	43.33	40.14	49.41	17.86	66.50	58.58	46.06	40.92	50.32	100.00	66.84	18.59	73.46	63.56	57.22	58.34	 1.52	44.03	72.09
1000006000:	 4.05	15.76	 4.18	 7.48	 0.89	 1.11	40.83	45.37	 1.58	 1.01	 1.41	 0.99	 1.84	 3.24	 6.62	10.69	 0.95	11.24	 3.98	 7.63
1000006001:	 4.05	15.76	 4.18	 7.48	 0.89	 1.11	40.83	45.37	 1.58	 1.01	 1.41	 0.99	 1.84	 3.24	 6.62	10.69	 0.95	11.24	 3.98	 7.63


Summarized Errors:
ID           Mean pct Std dev Mn %dif Std dev
1000000000:	 5.14	 6.11	-3.64	 7.15
1000000001:	 5.14	 6.11	-3.64	 7.15
1000001000:	22.32	15.24	-18.88	19.53
1000001001:	22.32	15.24	-18.88	19.53
1000002000:	21.45	15.05	 1.41	26.62
1000002001:	21.45	15.05	 1.41	26.62
1000003000:	 9.71	 7.48	-1.65	12.34
1000003001:	 9.71	 7.48	-1.65	12.34
1000004000:	45.19	41.91	19.90	59.07
1000004001:	45.19	41.91	19.90	59.07
1000005000:	51.32	21.94	-49.46	26.05
1000005001:	51.32	21.94	-49.46	26.05
1000006000:	 8.54	12.54	-7.07	13.47
1000006001:	 8.54	12.54	-7.07	13.47





Results for detected_peaks:
---------------------------

Raw percent errors:
1000000000:	 3.18	 2.57	 6.04	 2.68	16.09	 9.17	 0.57	 2.26	 5.66	 0.10	 3.12	 0.86	 2.00	 3.22	 1.74	26.11	 5.51	 2.77	 5.41	 3.18
1000000001:	 3.18	 2.57	 6.04	 2.68	16.09	 9.17	 0.57	 2.26	 5.66	 0.10	 3.12	 0.86	 2.00	 3.22	 1.74	26.11	 5.51	 2.77	 5.41	 3.18
1000001000:	24.31	54.15	23.26	 5.02	 2.83	39.44	 4.49	36.96	10.03	 8.15	25.13	14.58	21.14	24.42	10.60	18.71	44.93	31.85	41.58	 3.23
1000001001:	24.31	54.15	23.26	 5.02	 2.83	39.44	 4.49	36.96	10.03	 8.15	25.13	14.58	21.14	24.42	10.60	18.71	44.93	31.85	41.58	 3.23
1000002000:	27.57	39.69	19.88	 9.04	11.97	 8.68	30.75	19.10	 8.78	 7.11	 9.29	17.22	 7.61	65.31	 3.38	25.87	40.25	21.74	28.28	10.26
1000002001:	27.57	39.69	19.88	 9.04	11.97	 8.68	30.75	19.10	 8.78	 7.11	 9.29	17.22	 7.61	65.31	 3.38	25.87	40.25	21.74	28.28	10.26
1000003000:	 6.17	 6.39	18.00	 9.73	 4.21	24.12	17.46	 7.70	 1.87	20.37	17.25	 7.18	 1.13	 4.54	20.45	 0.90	 9.52	 4.02	 0.11	13.11
1000003001:	 6.17	 6.39	18.00	 9.73	 4.21	24.12	17.46	 7.70	 1.87	20.37	17.25	 7.18	 1.13	 4.54	20.45	 0.90	 9.52	 4.02	 0.11	13.11
1000004000:	23.94	 9.36	31.98	100.00	21.05	94.73	14.65	 6.01	39.88	30.93	96.91	21.36	120.65	 8.47	27.73	83.62	35.20	 7.36	105.01	 8.36
1000004001:	23.94	 9.36	31.98	100.00	21.05	94.73	14.65	 6.01	39.88	30.93	96.91	21.36	120.65	 8.47	27.73	83.62	35.20	 7.36	105.01	 8.36
1000005000:	22.54	10.76	 0.82	 6.54	15.61	 4.33	 5.37	 8.72	 2.09	 9.90	22.05	14.96	126.60	52.60	 5.80	18.81	114.89	102.28	30.14	46.00
1000005001:	22.54	10.76	 0.82	 6.54	15.61	 4.33	 5.37	 8.72	 2.09	 9.90	22.05	14.96	126.60	52.60	 5.80	18.81	114.89	102.28	30.14	46.00
1000006000:	46.51	 7.39	10.40	25.01	47.61	45.19	45.30	45.76	44.14	45.12	42.81	35.46	 2.88	 3.55	49.83	50.08	37.17	11.10	 2.68	 7.23
1000006001:	46.51	 7.39	10.40	25.01	47.61	45.19	45.30	45.76	44.14	45.12	42.81	35.46	 2.88	 3.55	49.83	50.08	37.17	11.10	 2.68	 7.23


Summarized Errors:
ID           Mean pct Std dev Mn %dif Std dev
1000000000:	 5.11	 6.09	-3.67	 7.10
1000000001:	 5.11	 6.09	-3.67	 7.10
1000001000:	22.24	15.28	-18.80	19.55
1000001001:	22.24	15.28	-18.80	19.55
1000002000:	20.59	15.18	 1.88	25.94
1000002001:	20.59	15.18	 1.88	25.94
1000003000:	 9.71	 7.48	-1.65	12.34
1000003001:	 9.71	 7.48	-1.65	12.34
1000004000:	44.36	39.18	 8.19	59.46
1000004001:	44.36	39.18	 8.19	59.46
1000005000:	31.04	38.69	25.57	42.70
1000005001:	31.04	38.69	25.57	42.70
1000006000:	30.26	18.84	-29.99	19.28
1000006001:	30.26	18.84	-29.99	19.28


Results for summing over hand-selected bins:
--------------------------------------------

Raw percent errors:
1000000000:	 9.02	10.23	11.47	12.42	 5.05	12.43	 7.59	11.91	15.85	 7.10	10.45	14.04	 5.33	10.01	11.34	11.78	15.47	 9.40	 9.74	 8.96
1000000001:	 9.02	10.23	11.47	12.42	 5.05	12.43	 7.59	11.91	15.85	 7.10	10.45	14.04	 5.33	10.01	11.34	11.78	15.47	 9.40	 9.74	 8.96
1000001000:	29.58	36.31	23.42	24.37	25.15	21.90	26.17	27.23	16.20	21.32	23.78	17.72	25.08	16.80	21.63	17.38	30.91	20.81	18.56	25.14
1000001001:	29.58	36.31	23.42	24.37	25.15	21.90	26.17	27.23	16.20	21.32	23.78	17.72	25.08	16.80	21.63	17.38	30.91	20.81	18.56	25.14
1000002000:	14.68	 5.20	22.74	11.81	16.28	15.77	 6.65	18.65	 6.63	 7.56	12.57	 7.43	 7.32	 1.87	 7.48	13.01	 4.29	30.15	13.13	10.63
1000002001:	14.68	 5.20	22.74	11.81	16.28	15.77	 6.65	18.65	 6.63	 7.56	12.57	 7.43	 7.32	 1.87	 7.48	13.01	 4.29	30.15	13.13	10.63
1000003000:	 1.38	 2.82	 7.39	 4.77	 0.08	24.76	12.26	 9.23	 4.72	17.43	 6.84	 1.89	14.52	 2.69	13.55	 1.33	19.84	 5.46	 0.65	 3.28
1000003001:	 1.38	 2.82	 7.39	 4.77	 0.08	24.76	12.26	 9.23	 4.72	17.43	 6.84	 1.89	14.52	 2.69	13.55	 1.33	19.84	 5.46	 0.65	 3.28
1000004000:	14.64	 3.13	 3.06	10.76	26.04	41.39	 1.40	45.69	31.79	12.76	30.77	 5.15	15.52	18.62	 8.63	52.52	 0.45	15.40	 6.01	36.58
1000004001:	14.64	 3.13	 3.06	10.76	26.04	41.39	 1.40	45.69	31.79	12.76	30.77	 5.15	15.52	18.62	 8.63	52.52	 0.45	15.40	 6.01	36.58
1000005000:	56.63	56.59	54.46	54.02	52.38	55.83	55.41	57.85	57.95	56.18	51.72	53.63	51.02	54.53	51.77	53.19	54.40	55.61	52.57	53.74
1000005001:	56.63	56.59	54.46	54.02	52.38	55.83	55.41	57.85	57.95	56.18	51.72	53.63	51.02	54.53	51.77	53.19	54.40	55.61	52.57	53.74
1000006000:	 8.39	 7.82	 5.22	 6.89	 6.91	 6.09	 6.08	 6.11	 6.28	 5.35	 7.75	 7.51	 7.47	 6.45	 8.74	 7.63	 5.95	10.51	 7.07	 9.07
1000006001:	 8.39	 7.82	 5.22	 6.89	 6.91	 6.09	 6.08	 6.11	 6.28	 5.35	 7.75	 7.51	 7.47	 6.45	 8.74	 7.63	 5.95	10.51	 7.07	 9.07


Summarized Errors:
ID           Mean pct Std dev Mn %dif Std dev
1000000000:	10.48	 2.92	-10.48	 2.92
1000000001:	10.48	 2.92	-10.48	 2.92
1000001000:	23.47	 5.11	-23.47	 5.11
1000001001:	23.47	 5.11	-23.47	 5.11
1000002000:	11.69	 6.80	-11.26	 7.53
1000002001:	11.69	 6.80	-11.26	 7.53
1000003000:	 7.74	 7.07	 1.76	10.48
1000003001:	 7.74	 7.07	 1.76	10.48
1000004000:	19.02	15.86	-7.07	24.07
1000004001:	19.02	15.86	-7.07	24.07
1000005000:	54.47	 2.02	54.47	 2.02
1000005001:	54.47	 2.02	54.47	 2.02
1000006000:	 7.16	 1.33	-7.16	 1.33
1000006001:	 7.16	 1.33	-7.16	 1.33


Notes
-----

The notes Eric took while doing the deconvolution are typed below.


Bin 0: Not much problem

Bin 1: Gets baseline wrong and when peak is moved only slightly tries
       to approximate whole spectrum with the baseline

Bin 2: Similar baseline troubles to Bin 1

Bin 3: More baseline troubles, but not so much of a problem due to the
       narrowness and height of the peak.

Bin 4: Baseline problems again.  In the perfect_peaks condition,
       spectrum 7 was especially bad.

Bin 5: Too much ambiguity in the area of the main peak leads to great
       variations in its size.

       Without knowing that the big peaks were composed of a number of
       small peaks, I would have left a number of clearly wrong
       decompositions.

       In the detected_peaks condition, I evaluated the peaks naiively
       - taking only the number of apparent peaks rather than the
       number of peaks I knew to exist.

Bin 6: In the perfect peak condition: problems with the baseline in
       spectra 2,7, and 8.  [Those spectra turned out to be the
       spectra with the worst problems]

       In the detected peak condition, there were many more baseline problems.

       The algorithm has a great temptation to create a wide and low
       peak using the baseline.


Files
-----

* 7_bin_test.bins.csv

  Holds the bin descriptions for the 7 bin test

* 7_bin_test.bins_used_for_quant_by_binning.txt

  The bin ranges used in generating 7_bin_test.hand-binning-quant.xy.txt

* 7_bin_test.dec.correct.xy.txt
  
  Holds the areas of the peaks from which the spectrum was generated
  in xy format

* 7_bin_test.dec.detected_peaks.xy.txt

  Holds the areas of the peaks as calculated by the region
  deconvolution software using peaks the software detected.

* 7_bin_test.dec.perfect_peaks.xy.txt

  Holds the areas of the peaks as calculated by the region
  deconvolution software using the peak locations from which the
  spectrum was generated

* 7_bin_test.detected_peaks.session

  The session file saved just before the deconvolution software
  generated its output files enabling one to go back and see the
  deconvolutions that were used.  This session file is for the session
  using the peaks detected by the targeted deconvolution software.

  The session files are likely to change enough as not to be backward
  compatible.  This file is readable with git revision:
  010491e6187141a8babc9bc52fb2a4aefb8ee5b5

* 7_bin_test.excel.dec.detected_peaks.csv

  The same data as 7_bin_test.dec.detected_peaks.csv, but in an excel
  friendly csv.

* 7_bin_test.excel.dec.perfect_peaks.csv

  The same data as 7_bin_test.dec.perfect_peaks.csv, but in an excel
  friendly csv.

* 7_bin_test.hand-binning-quant.xy.txt

  The peak areas generated by binning over some hand-selected bins.

* 7_bin_test.perfect_peaks.session

  The session file saved just before the deconvolution software
  generated its output files enabling one to go back and see the
  deconvolutions that were used.  This session file is for the session
  that started with the original peak locations used to generate the
  spectra.

  The session files are likely to change enough as not to be backward
  compatible.  This file is readable with git revision:
  010491e6187141a8babc9bc52fb2a4aefb8ee5b5

* 7_bin_test.resid.detected_peaks.xy.txt

  Residuals from the detected_peaks deconvolution (see above)

* 7_bin_test.resid.perfect_peaks.xy.txt

  Residuals from the perfect_peaks deconvolution (see above)

* 7_bin_test.xy.txt

  The spectral data used in the 7_bin_test
