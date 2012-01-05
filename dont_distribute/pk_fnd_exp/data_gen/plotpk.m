function plotpk( spectrum, peak_idx)
%plot the given peak in a spectrum of synthetic data

idx = peak_idx;
params=spectrum.MGPX_BETA(4*idx-3:4*idx); 
g=params(2);
x=params(4);
width=g*4; 
lb=x-width; 
ub=x+width; 
sx=spectrum.x; 
range=sx>lb & sx<ub; 
plot(sx(range),spectrum.y(range));

end

