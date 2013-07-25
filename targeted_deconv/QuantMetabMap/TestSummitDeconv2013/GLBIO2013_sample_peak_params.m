function [area, height, width, lorentzianness, location] = GLBIO2013_sample_peak_params( collision_prob, num_spectra )
% Sample the peak parameters in the original spectra generated as in the GLBIO2013 experiment
%
% Usage: [area, height, width, lorentzianness, location] = GLBIO2013_sample_peak_params( collision_prob, num_spectra )
%
% Generates num_spectra spectra with 7 peaks and a width that gives the
% given collision probability. Calculates the area for each peak, height,
% width, etc and returns these as vectors.
% -------------------------------------------------------------------------
% Input arguments
% -------------------------------------------------------------------------
% 
% collision_prob - (scalar) the probability that there will be a collision
%      between the peaks in a generated spectrum rounded to the nearest 0.1
%
% num_spectra - (non-negative integer) the number of spectra to generate
%
% -------------------------------------------------------------------------
% Output parameters
% -------------------------------------------------------------------------
% 
% [area, height, width, lorentzianness, location] - (row vectors) the area,
%      height, width, lorentzianness, and location parameters of each peak
%      in the generated spectra. Ordered in parallel: area(i), height(i),
%      etc all come from the same peak.
%
% -------------------------------------------------------------------------
% Examples
% -------------------------------------------------------------------------
% 
% -------------------------------------------------------------------------
% Authors
% -------------------------------------------------------------------------
% Eric Moyer (June 2013) eric_moyer@yahoo.com

n = num_spectra * 7; % Number of peaks generated

area = nan(1,n);
height = nan(1,n);
width = nan(1,n);
lorentzianness = nan(1,n);
location = nan(1,n);

resolution = 25/0.00453630122481774988; % copied from GLBIO2013Datum
spec_width = GLBIO2013_width_for_collision_prob(collision_prob);
spec_max = 1+spec_width;
num_pts = spec_width*resolution;

for i = 1:7:n
    [~,peaks] = random_spec_from_nssd_data(7,1,spec_max,num_pts,0);
    area(i:i+6) = [peaks.area];
    height(i:i+6) = [peaks.height];
    width(i:i+6) = [peaks.half_height_width];
    lorentzianness(i:i+6) = [peaks.lorentzianness];
    location(i:i+6) = [peaks.location];
end

