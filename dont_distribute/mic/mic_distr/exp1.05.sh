echo `date` ": started experiment1/00250_spike_x000_y000.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0 -ystd 0 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 1864103438389197867 > experiment1/00250_spike_x000_y000.ser
echo `date` ": finished experiment1/00250_spike_x000_y000.ser" >> experiment1/log
echo `date` ": started experiment1/00250_spike_x000_y010.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0 -ystd 0.1 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 8433670146745625977 > experiment1/00250_spike_x000_y010.ser
echo `date` ": finished experiment1/00250_spike_x000_y010.ser" >> experiment1/log
echo `date` ": started experiment1/00250_spike_x000_y030.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0 -ystd 0.3 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 5065339889960270000 > experiment1/00250_spike_x000_y030.ser
echo `date` ": finished experiment1/00250_spike_x000_y030.ser" >> experiment1/log
echo `date` ": started experiment1/00250_spike_x010_y000.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.1 -ystd 0 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 373655996514710982 > experiment1/00250_spike_x010_y000.ser
echo `date` ": finished experiment1/00250_spike_x010_y000.ser" >> experiment1/log
echo `date` ": started experiment1/00250_spike_x010_y010.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.1 -ystd 0.1 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 2843923574763542529 > experiment1/00250_spike_x010_y010.ser
echo `date` ": finished experiment1/00250_spike_x010_y010.ser" >> experiment1/log
echo `date` ": started experiment1/00250_spike_x010_y030.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.1 -ystd 0.3 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 1763077711366601598 > experiment1/00250_spike_x010_y030.ser
echo `date` ": finished experiment1/00250_spike_x010_y030.ser" >> experiment1/log
echo `date` ": started experiment1/00250_spike_x030_y000.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.3 -ystd 0 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 311399926607444179 > experiment1/00250_spike_x030_y000.ser
echo `date` ": finished experiment1/00250_spike_x030_y000.ser" >> experiment1/log
echo `date` ": started experiment1/00250_spike_x030_y010.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.3 -ystd 0.1 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 2153106095949889637 > experiment1/00250_spike_x030_y010.ser
echo `date` ": finished experiment1/00250_spike_x030_y010.ser" >> experiment1/log
echo `date` ": started experiment1/00250_spike_x030_y030.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.3 -ystd 0.3 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 2396837108663620831 > experiment1/00250_spike_x030_y030.ser
echo `date` ": finished experiment1/00250_spike_x030_y030.ser" >> experiment1/log
echo `date` ": started experiment1/00300_sigmoid_x000_y000.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0 -ystd 0 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 774049983650939485 > experiment1/00300_sigmoid_x000_y000.ser
echo `date` ": finished experiment1/00300_sigmoid_x000_y000.ser" >> experiment1/log
echo `date` ": started experiment1/00300_sigmoid_x000_y010.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0 -ystd 0.1 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 723543626486668920 > experiment1/00300_sigmoid_x000_y010.ser
echo `date` ": finished experiment1/00300_sigmoid_x000_y010.ser" >> experiment1/log
echo `date` ": started experiment1/00300_sigmoid_x000_y030.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0 -ystd 0.3 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 2828656466754051650 > experiment1/00300_sigmoid_x000_y030.ser
echo `date` ": finished experiment1/00300_sigmoid_x000_y030.ser" >> experiment1/log
echo `date` ": started experiment1/00300_sigmoid_x010_y000.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.1 -ystd 0 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 7911546303925556354 > experiment1/00300_sigmoid_x010_y000.ser
echo `date` ": finished experiment1/00300_sigmoid_x010_y000.ser" >> experiment1/log
echo `date` ": started experiment1/00300_sigmoid_x010_y010.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.1 -ystd 0.1 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 2344359885403649267 > experiment1/00300_sigmoid_x010_y010.ser
echo `date` ": finished experiment1/00300_sigmoid_x010_y010.ser" >> experiment1/log
echo `date` ": started experiment1/00300_sigmoid_x010_y030.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.1 -ystd 0.3 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 8379222382457393092 > experiment1/00300_sigmoid_x010_y030.ser
echo `date` ": finished experiment1/00300_sigmoid_x010_y030.ser" >> experiment1/log
echo `date` ": started experiment1/00300_sigmoid_x030_y000.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.3 -ystd 0 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 936793263773532666 > experiment1/00300_sigmoid_x030_y000.ser
echo `date` ": finished experiment1/00300_sigmoid_x030_y000.ser" >> experiment1/log
echo `date` ": started experiment1/00300_sigmoid_x030_y010.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.3 -ystd 0.1 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 530532522944431003 > experiment1/00300_sigmoid_x030_y010.ser
echo `date` ": finished experiment1/00300_sigmoid_x030_y010.ser" >> experiment1/log
echo `date` ": started experiment1/00300_sigmoid_x030_y030.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.3 -ystd 0.3 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 7374141905307419172 > experiment1/00300_sigmoid_x030_y030.ser
echo `date` ": finished experiment1/00300_sigmoid_x030_y030.ser" >> experiment1/log
echo `date` ": started experiment1/00350_L_x000_y000.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0 -ystd 0 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 1487728765012724485 > experiment1/00350_L_x000_y000.ser
echo `date` ": finished experiment1/00350_L_x000_y000.ser" >> experiment1/log
echo `date` ": started experiment1/00350_L_x000_y010.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0 -ystd 0.1 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 5276179941327390769 > experiment1/00350_L_x000_y010.ser
echo `date` ": finished experiment1/00350_L_x000_y010.ser" >> experiment1/log
echo `date` ": started experiment1/00350_L_x000_y030.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0 -ystd 0.3 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 6104824519550421938 > experiment1/00350_L_x000_y030.ser
echo `date` ": finished experiment1/00350_L_x000_y030.ser" >> experiment1/log
echo `date` ": started experiment1/00350_L_x010_y000.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.1 -ystd 0 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 3172115787289913009 > experiment1/00350_L_x010_y000.ser
echo `date` ": finished experiment1/00350_L_x010_y000.ser" >> experiment1/log
echo `date` ": started experiment1/00350_L_x010_y010.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.1 -ystd 0.1 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 6564525228792023531 > experiment1/00350_L_x010_y010.ser
echo `date` ": finished experiment1/00350_L_x010_y010.ser" >> experiment1/log
echo `date` ": started experiment1/00350_L_x010_y030.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.1 -ystd 0.3 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 4459944860363642073 > experiment1/00350_L_x010_y030.ser
echo `date` ": finished experiment1/00350_L_x010_y030.ser" >> experiment1/log
echo `date` ": started experiment1/00350_L_x030_y000.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.3 -ystd 0 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 4526831968163266942 > experiment1/00350_L_x030_y000.ser
echo `date` ": finished experiment1/00350_L_x030_y000.ser" >> experiment1/log
echo `date` ": started experiment1/00350_L_x030_y010.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.3 -ystd 0.1 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 2605391821533969006 > experiment1/00350_L_x030_y010.ser
echo `date` ": finished experiment1/00350_L_x030_y010.ser" >> experiment1/log
echo `date` ": started experiment1/00350_L_x030_y030.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.3 -ystd 0.3 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 3193207037603686133 > experiment1/00350_L_x030_y030.ser
echo `date` ": finished experiment1/00350_L_x030_y030.ser" >> experiment1/log
echo `date` ": started experiment1/00351_L_lop_x000_y000.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0 -ystd 0 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 8381688036365718975 > experiment1/00351_L_lop_x000_y000.ser
echo `date` ": finished experiment1/00351_L_lop_x000_y000.ser" >> experiment1/log
echo `date` ": started experiment1/00351_L_lop_x000_y010.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0 -ystd 0.1 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 2871674959144021063 > experiment1/00351_L_lop_x000_y010.ser
echo `date` ": finished experiment1/00351_L_lop_x000_y010.ser" >> experiment1/log
echo `date` ": started experiment1/00351_L_lop_x000_y030.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0 -ystd 0.3 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 8760113450698358754 > experiment1/00351_L_lop_x000_y030.ser
echo `date` ": finished experiment1/00351_L_lop_x000_y030.ser" >> experiment1/log
echo `date` ": started experiment1/00351_L_lop_x010_y000.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.1 -ystd 0 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 7766279372012911525 > experiment1/00351_L_lop_x010_y000.ser
echo `date` ": finished experiment1/00351_L_lop_x010_y000.ser" >> experiment1/log
echo `date` ": started experiment1/00351_L_lop_x010_y010.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.1 -ystd 0.1 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 4512282226910243658 > experiment1/00351_L_lop_x010_y010.ser
echo `date` ": finished experiment1/00351_L_lop_x010_y010.ser" >> experiment1/log
echo `date` ": started experiment1/00351_L_lop_x010_y030.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.1 -ystd 0.3 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 7814239367893047975 > experiment1/00351_L_lop_x010_y030.ser
echo `date` ": finished experiment1/00351_L_lop_x010_y030.ser" >> experiment1/log
echo `date` ": started experiment1/00351_L_lop_x030_y000.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.3 -ystd 0 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 8056106041782257653 > experiment1/00351_L_lop_x030_y000.ser
echo `date` ": finished experiment1/00351_L_lop_x030_y000.ser" >> experiment1/log
echo `date` ": started experiment1/00351_L_lop_x030_y010.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.3 -ystd 0.1 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 6125157943033770759 > experiment1/00351_L_lop_x030_y010.ser
echo `date` ": finished experiment1/00351_L_lop_x030_y010.ser" >> experiment1/log
echo `date` ": started experiment1/00351_L_lop_x030_y030.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.3 -ystd 0.3 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 5232589849834517452 > experiment1/00351_L_lop_x030_y030.ser
echo `date` ": finished experiment1/00351_L_lop_x030_y030.ser" >> experiment1/log
echo `date` ": started experiment1/00408_slsin0811116_x000_y000.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0 -ystd 0 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 1676740052271130303 > experiment1/00408_slsin0811116_x000_y000.ser
echo `date` ": finished experiment1/00408_slsin0811116_x000_y000.ser" >> experiment1/log
echo `date` ": started experiment1/00408_slsin0811116_x000_y010.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0 -ystd 0.1 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 8765607495932905189 > experiment1/00408_slsin0811116_x000_y010.ser
echo `date` ": finished experiment1/00408_slsin0811116_x000_y010.ser" >> experiment1/log
echo `date` ": started experiment1/00408_slsin0811116_x000_y030.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0 -ystd 0.3 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 2147199994070559767 > experiment1/00408_slsin0811116_x000_y030.ser
echo `date` ": finished experiment1/00408_slsin0811116_x000_y030.ser" >> experiment1/log
echo `date` ": started experiment1/00408_slsin0811116_x010_y000.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.1 -ystd 0 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 680926494752940304 > experiment1/00408_slsin0811116_x010_y000.ser
echo `date` ": finished experiment1/00408_slsin0811116_x010_y000.ser" >> experiment1/log
echo `date` ": started experiment1/00408_slsin0811116_x010_y010.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.1 -ystd 0.1 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 531654797402396159 > experiment1/00408_slsin0811116_x010_y010.ser
echo `date` ": finished experiment1/00408_slsin0811116_x010_y010.ser" >> experiment1/log
echo `date` ": started experiment1/00408_slsin0811116_x010_y030.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.1 -ystd 0.3 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 6609114720356788696 > experiment1/00408_slsin0811116_x010_y030.ser
echo `date` ": finished experiment1/00408_slsin0811116_x010_y030.ser" >> experiment1/log
echo `date` ": started experiment1/00408_slsin0811116_x030_y000.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.3 -ystd 0 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 2863456037534983570 > experiment1/00408_slsin0811116_x030_y000.ser
echo `date` ": finished experiment1/00408_slsin0811116_x030_y000.ser" >> experiment1/log
echo `date` ": started experiment1/00408_slsin0811116_x030_y010.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.3 -ystd 0.1 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 9026968175205005099 > experiment1/00408_slsin0811116_x030_y010.ser
echo `date` ": finished experiment1/00408_slsin0811116_x030_y010.ser" >> experiment1/log
echo `date` ": started experiment1/00408_slsin0811116_x030_y030.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.3 -ystd 0.3 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 2429466941151283010 > experiment1/00408_slsin0811116_x030_y030.ser
echo `date` ": finished experiment1/00408_slsin0811116_x030_y030.ser" >> experiment1/log
echo `date` ": started experiment1/00421_slsin2105110_x000_y000.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0 -ystd 0 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 4949686616554583282 > experiment1/00421_slsin2105110_x000_y000.ser
echo `date` ": finished experiment1/00421_slsin2105110_x000_y000.ser" >> experiment1/log
echo `date` ": started experiment1/00421_slsin2105110_x000_y010.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0 -ystd 0.1 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 3194723399606958036 > experiment1/00421_slsin2105110_x000_y010.ser
echo `date` ": finished experiment1/00421_slsin2105110_x000_y010.ser" >> experiment1/log
echo `date` ": started experiment1/00421_slsin2105110_x000_y030.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0 -ystd 0.3 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 4597413810438431925 > experiment1/00421_slsin2105110_x000_y030.ser
echo `date` ": finished experiment1/00421_slsin2105110_x000_y030.ser" >> experiment1/log
echo `date` ": started experiment1/00421_slsin2105110_x010_y000.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.1 -ystd 0 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 726369449676849569 > experiment1/00421_slsin2105110_x010_y000.ser
echo `date` ": finished experiment1/00421_slsin2105110_x010_y000.ser" >> experiment1/log
echo `date` ": started experiment1/00421_slsin2105110_x010_y010.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.1 -ystd 0.1 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 4154444706491094021 > experiment1/00421_slsin2105110_x010_y010.ser
echo `date` ": finished experiment1/00421_slsin2105110_x010_y010.ser" >> experiment1/log
echo `date` ": started experiment1/00421_slsin2105110_x010_y030.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.1 -ystd 0.3 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 8055185955611276848 > experiment1/00421_slsin2105110_x010_y030.ser
echo `date` ": finished experiment1/00421_slsin2105110_x010_y030.ser" >> experiment1/log
echo `date` ": started experiment1/00421_slsin2105110_x030_y000.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.3 -ystd 0 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 8805383811750248412 > experiment1/00421_slsin2105110_x030_y000.ser
echo `date` ": finished experiment1/00421_slsin2105110_x030_y000.ser" >> experiment1/log
echo `date` ": started experiment1/00421_slsin2105110_x030_y010.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.3 -ystd 0.1 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 4371707433877027718 > experiment1/00421_slsin2105110_x030_y010.ser
echo `date` ": finished experiment1/00421_slsin2105110_x030_y010.ser" >> experiment1/log
echo `date` ": started experiment1/00421_slsin2105110_x030_y030.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.3 -ystd 0.3 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 3873526074565882136 > experiment1/00421_slsin2105110_x030_y030.ser
echo `date` ": finished experiment1/00421_slsin2105110_x030_y030.ser" >> experiment1/log
echo `date` ": started experiment1/00423_slsin2110106_x000_y000.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0 -ystd 0 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 5690574671717615256 > experiment1/00423_slsin2110106_x000_y000.ser
echo `date` ": finished experiment1/00423_slsin2110106_x000_y000.ser" >> experiment1/log
echo `date` ": started experiment1/00423_slsin2110106_x000_y010.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0 -ystd 0.1 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 1254177419139405575 > experiment1/00423_slsin2110106_x000_y010.ser
echo `date` ": finished experiment1/00423_slsin2110106_x000_y010.ser" >> experiment1/log
echo `date` ": started experiment1/00423_slsin2110106_x000_y030.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0 -ystd 0.3 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 5240084277120557367 > experiment1/00423_slsin2110106_x000_y030.ser
echo `date` ": finished experiment1/00423_slsin2110106_x000_y030.ser" >> experiment1/log
echo `date` ": started experiment1/00423_slsin2110106_x010_y000.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.1 -ystd 0 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 2527104729593818814 > experiment1/00423_slsin2110106_x010_y000.ser
echo `date` ": finished experiment1/00423_slsin2110106_x010_y000.ser" >> experiment1/log
echo `date` ": started experiment1/00423_slsin2110106_x010_y010.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.1 -ystd 0.1 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 5478645280387502972 > experiment1/00423_slsin2110106_x010_y010.ser
echo `date` ": finished experiment1/00423_slsin2110106_x010_y010.ser" >> experiment1/log
echo `date` ": started experiment1/00423_slsin2110106_x010_y030.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.1 -ystd 0.3 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 3152757224013149305 > experiment1/00423_slsin2110106_x010_y030.ser
echo `date` ": finished experiment1/00423_slsin2110106_x010_y030.ser" >> experiment1/log
echo `date` ": started experiment1/00423_slsin2110106_x030_y000.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.3 -ystd 0 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 3905713561856635082 > experiment1/00423_slsin2110106_x030_y000.ser
echo `date` ": finished experiment1/00423_slsin2110106_x030_y000.ser" >> experiment1/log
echo `date` ": started experiment1/00423_slsin2110106_x030_y010.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.3 -ystd 0.1 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 2571513251144023817 > experiment1/00423_slsin2110106_x030_y010.ser
echo `date` ": finished experiment1/00423_slsin2110106_x030_y010.ser" >> experiment1/log
echo `date` ": started experiment1/00423_slsin2110106_x030_y030.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.3 -ystd 0.3 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 4084125619902182498 > experiment1/00423_slsin2110106_x030_y030.ser
echo `date` ": finished experiment1/00423_slsin2110106_x030_y030.ser" >> experiment1/log
echo `date` ": started experiment1/00428_slsin2833033_x000_y000.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0 -ystd 0 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 1018647667099814704 > experiment1/00428_slsin2833033_x000_y000.ser
echo `date` ": finished experiment1/00428_slsin2833033_x000_y000.ser" >> experiment1/log
echo `date` ": started experiment1/00428_slsin2833033_x000_y010.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0 -ystd 0.1 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 3810457599095554039 > experiment1/00428_slsin2833033_x000_y010.ser
echo `date` ": finished experiment1/00428_slsin2833033_x000_y010.ser" >> experiment1/log
echo `date` ": started experiment1/00428_slsin2833033_x000_y030.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0 -ystd 0.3 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 7269624605402931167 > experiment1/00428_slsin2833033_x000_y030.ser
echo `date` ": finished experiment1/00428_slsin2833033_x000_y030.ser" >> experiment1/log
echo `date` ": started experiment1/00428_slsin2833033_x010_y000.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.1 -ystd 0 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 483958672769062557 > experiment1/00428_slsin2833033_x010_y000.ser
echo `date` ": finished experiment1/00428_slsin2833033_x010_y000.ser" >> experiment1/log
echo `date` ": started experiment1/00428_slsin2833033_x010_y010.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.1 -ystd 0.1 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 2469970859384374956 > experiment1/00428_slsin2833033_x010_y010.ser
echo `date` ": finished experiment1/00428_slsin2833033_x010_y010.ser" >> experiment1/log
echo `date` ": started experiment1/00428_slsin2833033_x010_y030.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.1 -ystd 0.3 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 7940306729872658373 > experiment1/00428_slsin2833033_x010_y030.ser
echo `date` ": finished experiment1/00428_slsin2833033_x010_y030.ser" >> experiment1/log
echo `date` ": started experiment1/00428_slsin2833033_x030_y000.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.3 -ystd 0 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 8074977002831977601 > experiment1/00428_slsin2833033_x030_y000.ser
echo `date` ": finished experiment1/00428_slsin2833033_x030_y000.ser" >> experiment1/log
echo `date` ": started experiment1/00428_slsin2833033_x030_y010.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.3 -ystd 0.1 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 2971959726514400368 > experiment1/00428_slsin2833033_x030_y010.ser
echo `date` ": finished experiment1/00428_slsin2833033_x030_y010.ser" >> experiment1/log
echo `date` ": started experiment1/00428_slsin2833033_x030_y030.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.3 -ystd 0.3 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 2765208225942956726 > experiment1/00428_slsin2833033_x030_y030.ser
echo `date` ": finished experiment1/00428_slsin2833033_x030_y030.ser" >> experiment1/log
echo `date` ": started experiment1/00431_slsin3137037_x000_y000.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0 -ystd 0 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 2383347027529624832 > experiment1/00431_slsin3137037_x000_y000.ser
echo `date` ": finished experiment1/00431_slsin3137037_x000_y000.ser" >> experiment1/log
echo `date` ": started experiment1/00431_slsin3137037_x000_y010.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0 -ystd 0.1 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 5947442695345963449 > experiment1/00431_slsin3137037_x000_y010.ser
echo `date` ": finished experiment1/00431_slsin3137037_x000_y010.ser" >> experiment1/log
echo `date` ": started experiment1/00431_slsin3137037_x000_y030.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0 -ystd 0.3 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 3174331015834332376 > experiment1/00431_slsin3137037_x000_y030.ser
echo `date` ": finished experiment1/00431_slsin3137037_x000_y030.ser" >> experiment1/log
echo `date` ": started experiment1/00431_slsin3137037_x010_y000.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.1 -ystd 0 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 7951626958264950066 > experiment1/00431_slsin3137037_x010_y000.ser
echo `date` ": finished experiment1/00431_slsin3137037_x010_y000.ser" >> experiment1/log
echo `date` ": started experiment1/00431_slsin3137037_x010_y010.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.1 -ystd 0.1 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 2746510608637471231 > experiment1/00431_slsin3137037_x010_y010.ser
echo `date` ": finished experiment1/00431_slsin3137037_x010_y010.ser" >> experiment1/log
echo `date` ": started experiment1/00431_slsin3137037_x010_y030.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.1 -ystd 0.3 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 4026841869155590377 > experiment1/00431_slsin3137037_x010_y030.ser
echo `date` ": finished experiment1/00431_slsin3137037_x010_y030.ser" >> experiment1/log
echo `date` ": started experiment1/00431_slsin3137037_x030_y000.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.3 -ystd 0 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 124897646175726879 > experiment1/00431_slsin3137037_x030_y000.ser
echo `date` ": finished experiment1/00431_slsin3137037_x030_y000.ser" >> experiment1/log
echo `date` ": started experiment1/00431_slsin3137037_x030_y010.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.3 -ystd 0.1 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 7746470911997386942 > experiment1/00431_slsin3137037_x030_y010.ser
echo `date` ": finished experiment1/00431_slsin3137037_x030_y010.ser" >> experiment1/log
echo `date` ": started experiment1/00431_slsin3137037_x030_y030.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.3 -ystd 0.3 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 1576087115703307562 > experiment1/00431_slsin3137037_x030_y030.ser
echo `date` ": finished experiment1/00431_slsin3137037_x030_y030.ser" >> experiment1/log
echo `date` ": started experiment1/10001_almostflat_x000_y000.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0 -ystd 0 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 1811016561307383269 > experiment1/10001_almostflat_x000_y000.ser
echo `date` ": finished experiment1/10001_almostflat_x000_y000.ser" >> experiment1/log
echo `date` ": started experiment1/10001_almostflat_x000_y010.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0 -ystd 0.1 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 1510560007263063760 > experiment1/10001_almostflat_x000_y010.ser
echo `date` ": finished experiment1/10001_almostflat_x000_y010.ser" >> experiment1/log
echo `date` ": started experiment1/10001_almostflat_x000_y030.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0 -ystd 0.3 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 8374041035938599461 > experiment1/10001_almostflat_x000_y030.ser
echo `date` ": finished experiment1/10001_almostflat_x000_y030.ser" >> experiment1/log
echo `date` ": started experiment1/10001_almostflat_x010_y000.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.1 -ystd 0 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 1543893180419166386 > experiment1/10001_almostflat_x010_y000.ser
echo `date` ": finished experiment1/10001_almostflat_x010_y000.ser" >> experiment1/log
echo `date` ": started experiment1/10001_almostflat_x010_y010.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.1 -ystd 0.1 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 2203880991809841336 > experiment1/10001_almostflat_x010_y010.ser
echo `date` ": finished experiment1/10001_almostflat_x010_y010.ser" >> experiment1/log
echo `date` ": started experiment1/10001_almostflat_x010_y030.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.1 -ystd 0.3 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 5799657903289662479 > experiment1/10001_almostflat_x010_y030.ser
echo `date` ": finished experiment1/10001_almostflat_x010_y030.ser" >> experiment1/log
echo `date` ": started experiment1/10001_almostflat_x030_y000.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.3 -ystd 0 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 6580892244242786593 > experiment1/10001_almostflat_x030_y000.ser
echo `date` ": finished experiment1/10001_almostflat_x030_y000.ser" >> experiment1/log
echo `date` ": started experiment1/10001_almostflat_x030_y010.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.3 -ystd 0.1 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 1391853875165718821 > experiment1/10001_almostflat_x030_y010.ser
echo `date` ": finished experiment1/10001_almostflat_x030_y010.ser" >> experiment1/log
echo `date` ": started experiment1/10001_almostflat_x030_y030.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.3 -ystd 0.3 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 6276082905348338498 > experiment1/10001_almostflat_x030_y030.ser
echo `date` ": finished experiment1/10001_almostflat_x030_y030.ser" >> experiment1/log
echo `date` ": started experiment1/10002_23halton_x000_y000.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0 -ystd 0 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 7235721252787527098 > experiment1/10002_23halton_x000_y000.ser
echo `date` ": finished experiment1/10002_23halton_x000_y000.ser" >> experiment1/log
echo `date` ": started experiment1/10002_23halton_x000_y010.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0 -ystd 0.1 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 1674320236144390656 > experiment1/10002_23halton_x000_y010.ser
echo `date` ": finished experiment1/10002_23halton_x000_y010.ser" >> experiment1/log
echo `date` ": started experiment1/10002_23halton_x000_y030.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0 -ystd 0.3 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 2831748452548312739 > experiment1/10002_23halton_x000_y030.ser
echo `date` ": finished experiment1/10002_23halton_x000_y030.ser" >> experiment1/log
echo `date` ": started experiment1/10002_23halton_x010_y000.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.1 -ystd 0 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 7191989813722723625 > experiment1/10002_23halton_x010_y000.ser
echo `date` ": finished experiment1/10002_23halton_x010_y000.ser" >> experiment1/log
echo `date` ": started experiment1/10002_23halton_x010_y010.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.1 -ystd 0.1 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 7663082403690741170 > experiment1/10002_23halton_x010_y010.ser
echo `date` ": finished experiment1/10002_23halton_x010_y010.ser" >> experiment1/log
echo `date` ": started experiment1/10002_23halton_x010_y030.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.1 -ystd 0.3 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 4493954100714805572 > experiment1/10002_23halton_x010_y030.ser
echo `date` ": finished experiment1/10002_23halton_x010_y030.ser" >> experiment1/log
echo `date` ": started experiment1/10002_23halton_x030_y000.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.3 -ystd 0 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 8545563863642413542 > experiment1/10002_23halton_x030_y000.ser
echo `date` ": finished experiment1/10002_23halton_x030_y000.ser" >> experiment1/log
echo `date` ": started experiment1/10002_23halton_x030_y010.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.3 -ystd 0.1 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 6612305376302199998 > experiment1/10002_23halton_x030_y010.ser
echo `date` ": finished experiment1/10002_23halton_x030_y010.ser" >> experiment1/log
echo `date` ": started experiment1/10002_23halton_x030_y030.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.3 -ystd 0.3 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 6330544617388581131 > experiment1/10002_23halton_x030_y030.ser
echo `date` ": finished experiment1/10002_23halton_x030_y030.ser" >> experiment1/log
echo `date` ": started experiment1/10003_sin2046pi_x000_y000.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0 -ystd 0 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 7933877201213946691 > experiment1/10003_sin2046pi_x000_y000.ser
echo `date` ": finished experiment1/10003_sin2046pi_x000_y000.ser" >> experiment1/log
echo `date` ": started experiment1/10003_sin2046pi_x000_y010.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0 -ystd 0.1 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 9149542672988564009 > experiment1/10003_sin2046pi_x000_y010.ser
echo `date` ": finished experiment1/10003_sin2046pi_x000_y010.ser" >> experiment1/log
echo `date` ": started experiment1/10003_sin2046pi_x000_y030.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0 -ystd 0.3 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 4141959598515580111 > experiment1/10003_sin2046pi_x000_y030.ser
echo `date` ": finished experiment1/10003_sin2046pi_x000_y030.ser" >> experiment1/log
echo `date` ": started experiment1/10003_sin2046pi_x010_y000.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.1 -ystd 0 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 6588270299173457972 > experiment1/10003_sin2046pi_x010_y000.ser
echo `date` ": finished experiment1/10003_sin2046pi_x010_y000.ser" >> experiment1/log
echo `date` ": started experiment1/10003_sin2046pi_x010_y010.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.1 -ystd 0.1 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 2433570733285094711 > experiment1/10003_sin2046pi_x010_y010.ser
echo `date` ": finished experiment1/10003_sin2046pi_x010_y010.ser" >> experiment1/log
echo `date` ": started experiment1/10003_sin2046pi_x010_y030.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.1 -ystd 0.3 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 5246170508347406765 > experiment1/10003_sin2046pi_x010_y030.ser
echo `date` ": finished experiment1/10003_sin2046pi_x010_y030.ser" >> experiment1/log
echo `date` ": started experiment1/10003_sin2046pi_x030_y000.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.3 -ystd 0 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 3832249434092517296 > experiment1/10003_sin2046pi_x030_y000.ser
echo `date` ": finished experiment1/10003_sin2046pi_x030_y000.ser" >> experiment1/log
echo `date` ": started experiment1/10003_sin2046pi_x030_y010.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.3 -ystd 0.1 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 3115743753173841477 > experiment1/10003_sin2046pi_x030_y010.ser
echo `date` ": finished experiment1/10003_sin2046pi_x030_y010.ser" >> experiment1/log
echo `date` ": started experiment1/10003_sin2046pi_x030_y030.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.3 -ystd 0.3 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 8353843855004345429 > experiment1/10003_sin2046pi_x030_y030.ser
echo `date` ": finished experiment1/10003_sin2046pi_x030_y030.ser" >> experiment1/log
echo `date` ": started experiment1/10004_steeppoly_x000_y000.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0 -ystd 0 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 1679544500407454518 > experiment1/10004_steeppoly_x000_y000.ser
echo `date` ": finished experiment1/10004_steeppoly_x000_y000.ser" >> experiment1/log
echo `date` ": started experiment1/10004_steeppoly_x000_y010.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0 -ystd 0.1 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 5528528632280209322 > experiment1/10004_steeppoly_x000_y010.ser
echo `date` ": finished experiment1/10004_steeppoly_x000_y010.ser" >> experiment1/log
echo `date` ": started experiment1/10004_steeppoly_x000_y030.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0 -ystd 0.3 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 2663233648879731400 > experiment1/10004_steeppoly_x000_y030.ser
echo `date` ": finished experiment1/10004_steeppoly_x000_y030.ser" >> experiment1/log
echo `date` ": started experiment1/10004_steeppoly_x010_y000.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.1 -ystd 0 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 8267962726634076060 > experiment1/10004_steeppoly_x010_y000.ser
echo `date` ": finished experiment1/10004_steeppoly_x010_y000.ser" >> experiment1/log
echo `date` ": started experiment1/10004_steeppoly_x010_y010.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.1 -ystd 0.1 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 2957116321081679131 > experiment1/10004_steeppoly_x010_y010.ser
echo `date` ": finished experiment1/10004_steeppoly_x010_y010.ser" >> experiment1/log
echo `date` ": started experiment1/10004_steeppoly_x010_y030.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.1 -ystd 0.3 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 7140959973391570799 > experiment1/10004_steeppoly_x010_y030.ser
echo `date` ": finished experiment1/10004_steeppoly_x010_y030.ser" >> experiment1/log
echo `date` ": started experiment1/10004_steeppoly_x030_y000.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.3 -ystd 0 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 901246972154121585 > experiment1/10004_steeppoly_x030_y000.ser
echo `date` ": finished experiment1/10004_steeppoly_x030_y000.ser" >> experiment1/log
echo `date` ": started experiment1/10004_steeppoly_x030_y010.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.3 -ystd 0.1 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 6498583887298364008 > experiment1/10004_steeppoly_x030_y010.ser
echo `date` ": finished experiment1/10004_steeppoly_x030_y010.ser" >> experiment1/log
echo `date` ": started experiment1/10004_steeppoly_x030_y030.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0.3 -ystd 0.3 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 512 -c 15 -seed 7593752045669181554 > experiment1/10004_steeppoly_x030_y030.ser
echo `date` ": finished experiment1/10004_steeppoly_x030_y030.ser" >> experiment1/log
