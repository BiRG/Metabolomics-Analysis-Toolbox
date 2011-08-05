
def get_deconv_for(bin, spectrum)
    if no_extant_deconv_for(bin, spectrum):
        calc_deconv_for(bin, spectrum)
        update_peak_locations_and_identifications_for(bin, spectrum)
        #Ensure that each identification ppm is an x0 for some peak
        #
        #Use an optimum assignment among earlier ppms and new ppms
        #solving linear assignment problem.  
        #
        #Choosing highest peak will not work because a small peak may
        #be completely under a larger peak but still distort it enough
        #to be seen.
    return deconv_for(bin, spectrum)

#Plotting:

if should_display_deconvolution:
    plot_deconvolution(get_deconvolution_for(bin, spectrum))

                       
#Output

c = handles.collection
c.processing += "; Extracted peaks for nulcei (insert list of bins here)"
num_x = 0
for bin in bins:
    num_x += bin.num_peaks + 1
c.x = zeros(1, num_x)
cur_idx = 1;
for bin in bins:
    c.x(cur_idx) = bin.id * 1000
    for i in 1..bin.num_peaks:
        c.x(cur_idx + i) = bin.id * 1000 + i
    cur_idx += 1 + bin.num_peaks 

for spectrum in spectra:
    y_idx = 1 #The index of the start of the next block of y values to fill
    for bin in bins:
        #Calculate the areas under the deconvolved, identified peaks
        d = get_deconv_for(bin, spectrum)
        update_handles() #So identifications are updated if necessary
        idents = get_idents_for(bin, spectrum)
        areas = zeros(1, length(idents))
        for i in 1..idents.size():
            p = d.get_peak_at(idents(i).ppm)
            a(i) = p.area
        #Fill in the y values using the areas
        c.Y(y_idx, spectrum) = sum(areas)
        for i = 1..length(areas):        
            c.Y(y_idx + i, spectrum) = areas(i)
        
        #Next block of y values
        y_idx += 1 + bin.num_peaks 

save_collection(c)
