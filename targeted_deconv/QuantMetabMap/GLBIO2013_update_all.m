function updated_data = GLBIO2013_update_all( data )
% Return the effect of running update on every element of data
%
% Usage: updated_data = GLBIO2013_update_all( data )
%
% For each element in data (data(i)), returns an updated version in
% updated_data(i) that is the result of running update on data(i)
%
% -------------------------------------------------------------------------
% Input parameters
% -------------------------------------------------------------------------
%
% data - (vector of GLBIO2013Datum) the datum objects to edit. Must 
%     contain at least one object.
%
% -------------------------------------------------------------------------
% Output parameters
% -------------------------------------------------------------------------
%
% updated_data - the GLBIODatum objects in data after updating
%
% -------------------------------------------------------------------------
% Examples
% -------------------------------------------------------------------------
%
% -------------------------------------------------------------------------
% Authors
% -------------------------------------------------------------------------
%
% Eric Moyer (eric_moyer@yahoo.com) July 2013

updated_data(length(data)) = data(length(data));
for datum_idx = 1:length(data)
    updated_data(datum_idx) = data(datum_idx).updateDeconvolutions;
end

