echo `date` ": started experiment1/00000_random_x000_y000.ser" >> experiment1/log
java -jar distr.jar generate -xstd 0 -ystd 0 -rel random -nsamp 5,6,7,8,9,10,12,14,19,30,60,100 -inst 4608 -c 15 -seed 8074288588388036530 > experiment1/00000_random_x000_y000.ser
echo `date` ": finished experiment1/00000_random_x000_y000.ser" >> experiment1/log
